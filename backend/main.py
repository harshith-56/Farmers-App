from fastapi import FastAPI, Depends, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import Response
from sqlalchemy.orm import Session
from schemas import ProfileResponse, ProfileUpdateRequest
from auth import get_user_profile, update_user_profile
from database import SessionLocal
from schemas import SignupRequest, LoginRequest
from auth import signup_user, login_user
from schemas import ChangePasswordRequest
from auth import change_user_password
from deepseek_service import ask_deepseek
import pickle
from market_service import fetch_market_prices, search_commodities
import numpy as np
from crop_translations import CROP_TRANSLATIONS,MESSAGES
from schemas import CropRecommendationRequest
app = FastAPI()
with open("ml_models/crop_recommendation_model.pkl", "rb") as f:
    crop_model = pickle.load(f)
@app.middleware("http")
async def cors_preflight_handler(request: Request, call_next):
    if request.method == "OPTIONS":
        return Response(
            status_code=200,
            headers={
                "Access-Control-Allow-Origin": request.headers.get("origin", "*"),
                "Access-Control-Allow-Methods": "GET,POST,PUT,DELETE,OPTIONS",
                "Access-Control-Allow-Headers": "*",
            },
        )
    return await call_next(request)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.get("/health")
def health():
    return {"status": "ok"}

@app.post("/signup")
def signup(data: SignupRequest, db: Session = Depends(get_db)):
    try:
        signup_user(db, data.name, data.phone, data.password)
        return {"message": "Signup successful"}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.post("/login")
def login(data: LoginRequest, db: Session = Depends(get_db)):
    try:
        login_user(db, data.phone, data.password)
        return {"message": "Login successful"}
    except ValueError as e:
        raise HTTPException(status_code=401, detail=str(e))



@app.get("/profile/{phone}", response_model=ProfileResponse)
def fetch_profile(phone: str, db: Session = Depends(get_db)):
    try:
        return get_user_profile(db, phone)
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))

@app.put("/profile/{phone}", response_model=ProfileResponse)
def edit_profile(
    phone: str,
    data: ProfileUpdateRequest,
    db: Session = Depends(get_db)
):
    try:
        return update_user_profile(
            db,
            phone,
            data.name,
            data.language
        )
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))



@app.put("/profile/{phone}/change-password")
def update_password(
    phone: str,
    data: ChangePasswordRequest,
    db: Session = Depends(get_db)
):
    try:
        change_user_password(
            db,
            phone,
            data.current_password,
            data.new_password
        )
        return {"message": "Password updated successfully"}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

from pydantic import BaseModel

class ChatRequest(BaseModel):
    phone: str
    message: str


@app.post("/chat")
def chat(data: ChatRequest):
    try:
        reply = ask_deepseek(data.message)
        return {"reply": reply}
    except Exception:
        raise HTTPException(status_code=500, detail="AI service unavailable")

@app.post("/recommend-crop")
def recommend_crop(data: CropRecommendationRequest, db: Session = Depends(get_db)):

    # -------------------------
    # Fetch user language
    # -------------------------
    try:
        user = get_user_profile(db, data.phone)
        language = user["language"]
    except:
        language = "en"

    if language not in ["en", "te", "hi"]:
        language = "en"

    # -------------------------
    # Prepare model input
    # -------------------------
    features = np.array([[
        data.N,
        data.P,
        data.K,
        data.temperature,
        data.humidity,
        data.ph,
        data.rainfall
    ]])

    # -------------------------
    # Predict probabilities
    # -------------------------
    probabilities = crop_model.predict_proba(features)[0]
    crops = crop_model.classes_

    crop_probs = list(zip(crops, probabilities))
    crop_probs.sort(key=lambda x: x[1], reverse=True)

    top5 = crop_probs[:5]

    # -------------------------
    # Translate crop names
    # -------------------------
    recommendations = []

    for crop, prob in top5:

        translated_crop = CROP_TRANSLATIONS[crop][language]

        recommendations.append({
            "crop": translated_crop,
            "confidence": round(prob * 100, 2)
        })
    best_crop_key = top5[0][0]
    best_crop = CROP_TRANSLATIONS[best_crop_key][language]
    best_confidence = round(top5[0][1] * 100, 2)
    message = MESSAGES[language].format(crop=best_crop)
    # -------------------------
    # Response
    # -------------------------
    return {
        "recommended_crop": best_crop,
        "confidence": best_confidence,
        "message": message,
        "top_5_recommendations": recommendations
    }

@app.get("/market/commodities")
def market_commodities(q: str = ""):
    try:
        results = search_commodities(q)

        return {
            "success": True,
            "results": results
        }

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=str(e)
        )
    
@app.get("/market/prices")
def market_prices(commodity: str, state: str):
    return fetch_market_prices(commodity=commodity, state=state)