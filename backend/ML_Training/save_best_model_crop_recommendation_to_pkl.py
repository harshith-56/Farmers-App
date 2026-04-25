import pandas as pd
import pickle
from sklearn.ensemble import RandomForestClassifier
# -----------------------
# Load Dataset
# -----------------------
data = pd.read_csv("ML_Training/crop_recommendation_dataset.csv")
X = data.drop("label", axis=1)
y = data["label"]
# -----------------------
# Best Model (from GridSearch)
# -----------------------
model = RandomForestClassifier(
    n_estimators=50,
    max_depth=10,
    criterion="entropy",
    random_state=42
)
# -----------------------
# Train on Full Dataset
# -----------------------

model.fit(X, y)
# -----------------------
# Save Model
# -----------------------
with open("ML_Models/crop_recommendation_model.pkl", "wb") as f:
    pickle.dump(model, f)
print("Model trained and saved successfully.")