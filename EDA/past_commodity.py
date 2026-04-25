import pandas as pd
import numpy as np

# ===============================
# LOAD DATA
# ===============================
file_path = r"D:\mandi_commodity_past_year_data\agmarknet-india-commodity-prices-2024-2025\agmarknet_india_historical_prices_2024_2025.csv"

df = pd.read_csv(file_path)

# ===============================
# BASIC OVERVIEW
# ===============================
print("\n===== DATASET SHAPE =====")
print(df.shape)

print("\n===== COLUMN NAMES =====")
print(df.columns.tolist())

print("\n===== FIRST 5 ROWS =====")
print(df.head())

print("\n===== LAST 5 ROWS =====")
print(df.tail())

print("\n===== DATA TYPES =====")
print(df.dtypes)

print("\n===== NULL VALUES =====")
print(df.isnull().sum())

print("\n===== DUPLICATE ROWS =====")
print(df.duplicated().sum())


# ===============================
# CLEAN COLUMN NAMES
# ===============================
df.columns = df.columns.str.strip()

# ===============================
# DATE COLUMN HANDLING
# ===============================
# Adjust this if actual column name differs
date_col = "Price Date"

df[date_col] = pd.to_datetime(df[date_col], errors="coerce", dayfirst=True)

print("\n===== DATE RANGE =====")
print("Min Date:", df[date_col].min())
print("Max Date:", df[date_col].max())

print("\n===== INVALID DATES =====")
print(df[date_col].isnull().sum())


# ===============================
# ROW COUNT
# ===============================
print("\n===== TOTAL ROW COUNT =====")
print(len(df))


# ===============================
# UNIQUE COUNTS
# ===============================
print("\n===== UNIQUE COMMODITIES COUNT =====")
print(df["Commodity"].nunique())

print("\n===== UNIQUE DISTRICTS COUNT =====")
print(df["District Name"].nunique())

print("\n===== UNIQUE MARKETS COUNT =====")
print(df["Market Name"].nunique())

print("\n===== UNIQUE VARIETIES COUNT =====")
print(df["Variety"].nunique())


# ===============================
# TOP VALUES
# ===============================
print("\n===== TOP 20 COMMODITIES =====")
print(df["Commodity"].value_counts().head(20))

print("\n===== TOP 20 DISTRICTS =====")
print(df["District Name"].value_counts().head(20))

print("\n===== TOP 20 MARKETS =====")
print(df["Market Name"].value_counts().head(20))


# ===============================
# PRICE COLUMN CLEANING
# ===============================
price_cols = [
    "Min Price (Rs./Quintal)",
    "Max Price (Rs./Quintal)",
    "Modal Price (Rs./Quintal)"
]

for col in price_cols:
    df[col] = pd.to_numeric(df[col], errors="coerce")

print("\n===== PRICE NULLS AFTER CONVERSION =====")
print(df[price_cols].isnull().sum())

print("\n===== PRICE STATS =====")
print(df[price_cols].describe())


# ===============================
# ZERO PRICE CHECK
# ===============================
print("\n===== ZERO PRICE COUNTS =====")
for col in price_cols:
    print(col, ":", (df[col] == 0).sum())


# ===============================
# DATE FREQUENCY
# ===============================
print("\n===== RECORDS PER MONTH =====")
print(df[date_col].dt.to_period("M").value_counts().sort_index())

print("\n===== RECORDS PER DAY (TOP 10 DAYS) =====")
print(df[date_col].value_counts().head(10))


# ===============================
# COMMODITY DATE COVERAGE
# ===============================
print("\n===== TOP 20 COMMODITIES WITH MOST RECORDS =====")
print(df.groupby("Commodity").size().sort_values(ascending=False).head(20))


# ===============================
# SAMPLE COMMODITY CHECK
# ===============================
sample_crop = "Tomato"

crop_df = df[df["Commodity"].str.lower() == sample_crop.lower()]

print(f"\n===== {sample_crop.upper()} RECORD COUNT =====")
print(len(crop_df))

if len(crop_df) > 0:
    print(f"\n===== {sample_crop.upper()} DATE RANGE =====")
    print(crop_df[date_col].min(), "to", crop_df[date_col].max())

    print(f"\n===== {sample_crop.upper()} TOP DISTRICTS =====")
    print(crop_df["District Name"].value_counts().head(10))

    print(f"\n===== {sample_crop.upper()} PRICE STATS =====")
    print(crop_df["Modal Price (Rs./Quintal)"].describe())


# ===============================
# MISSING DATA PERCENTAGE
# ===============================
print("\n===== MISSING DATA % =====")
print((df.isnull().mean() * 100).round(2))


# ===============================
# SAVE CLEAN COPY (OPTIONAL)
# ===============================
# df.to_csv("cleaned_mandi_dataset.csv", index=False)

print("\n===== EDA COMPLETE =====")

print(sorted([x for x in df["Commodity"].unique() if "tom" in x.lower()]))



# Print all unique commodity names sorted alphabetically
commodities = sorted(df["State"].dropna().unique())

print("Total Unique Commodities:", len(commodities))
print("\n===== ALL UNIQUE COMMODITIES =====\n")

for item in commodities:
    print(item)