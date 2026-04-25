import os
import requests
from datetime import datetime
from dotenv import load_dotenv
from commodities import COMMODITIES

load_dotenv()

API_KEY = os.getenv("DATA_GOV_API_KEY")

BASE_URL = "https://api.data.gov.in/resource/"
RESOURCE_ID = "9ef84268-d588-465a-a308-a864a43d0070"


def _to_int(value):
    try:
        return int(float(value))
    except Exception:
        return 0


def _parse_date(value):
    try:
        return datetime.strptime(value, "%d/%m/%Y")
    except Exception:
        return None


def fetch_market_prices(commodity: str, state: str) -> dict:
    if not API_KEY:
        return {"success": False, "message": "Market service not configured"}

    url = BASE_URL + RESOURCE_ID
    params = {
        "api-key": API_KEY,
        "format": "json",
        "limit": 10000,
        "filters[commodity]": commodity.strip().title(),
        "filters[state]": state.strip().title(),
    }

    response = None
    last_error = "Unknown error"

    for attempt in range(3):
        try:
            response = requests.get(url, params=params, timeout=30)
            if response.status_code == 200:
                break
            last_error = f"HTTP {response.status_code}"
            response = None
        except requests.Timeout:
            last_error = "Request timed out"
        except requests.RequestException as exc:
            last_error = str(exc)

    if response is None:
        return {"success": False, "message": "Live market service unavailable"}

    try:
        data = response.json()
    except Exception:
        return {"success": False, "message": "Invalid response from market service"}

    records = data.get("records", [])

    latest_by_market: dict = {}

    for row in records:
        market_name = row.get("market", "").strip()
        if not market_name:
            continue

        row_date = _parse_date(row.get("arrival_date", ""))

        item = {
            "market": market_name,
            "district": row.get("district", "").strip(),
            "modal_price": _to_int(row.get("modal_price")),
            "min_price": _to_int(row.get("min_price")),
            "max_price": _to_int(row.get("max_price")),
            "arrival_date": row.get("arrival_date", ""),
            "_date": row_date or datetime.min,
        }

        if market_name not in latest_by_market:
            latest_by_market[market_name] = item
        elif item["_date"] > latest_by_market[market_name]["_date"]:
            latest_by_market[market_name] = item

    markets = []
    for m in latest_by_market.values():
        del m["_date"]
        markets.append(m)

    if not markets:
        return {"success": False, "message": "No market data found"}

    markets.sort(key=lambda x: x["modal_price"], reverse=True)

    modal_prices = [m["modal_price"] for m in markets if m["modal_price"] > 0]
    avg_modal_price = round(sum(modal_prices) / len(modal_prices), 2) if modal_prices else 0

    highest = markets[0]
    lowest = markets[-1]

    return {
        "success": True,
        "results": {
            "commodity": commodity.strip().title(),
            "state": state.strip().title(),
            "summary": {
                "avg_modal_price": avg_modal_price,
                "highest_market": {
                    "market": highest["market"],
                    "price": highest["modal_price"],
                },
                "lowest_market": {
                    "market": lowest["market"],
                    "price": lowest["modal_price"],
                },
            },
            "markets": markets,
        },
    }


def search_commodities(query: str = "") -> list:
    items = COMMODITIES

    if not query.strip():
        return items[:20]

    q = query.lower().strip()
    starts = []
    contains = []

    for item in items:
        name = item.lower()
        if name.startswith(q):
            starts.append(item)
        elif q in name:
            contains.append(item)

    return (starts + contains)[:20]
