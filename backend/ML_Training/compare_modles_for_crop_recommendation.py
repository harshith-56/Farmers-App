import pandas as pd

from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.metrics import accuracy_score

from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler

from sklearn.linear_model import LogisticRegression
from sklearn.neighbors import KNeighborsClassifier
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import RandomForestClassifier


# -----------------------
# Load Dataset
# -----------------------

data = pd.read_csv("ML_Training/crop_recommendation_dataset.csv")

X = data.drop("label", axis=1)
y = data["label"]


# -----------------------
# Train Test Split
# -----------------------

X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.2,
    random_state=42
)


# -----------------------
# Logistic Regression Pipeline
# -----------------------

logistic_pipeline = Pipeline([
    ("scaler", StandardScaler()),
    ("model", LogisticRegression(max_iter=5000))
])


# -----------------------
# Models + Parameters
# -----------------------

models = {

    "Logistic Regression": (
        logistic_pipeline,
        {
            "model__C": [0.01, 0.1, 1, 10]
        }
    ),

    "KNN": (
        KNeighborsClassifier(),
        {
            "n_neighbors": [3,5,7,9],
            "weights": ["uniform","distance"]
        }
    ),

    "Decision Tree": (
        DecisionTreeClassifier(),
        {
            "max_depth": [None,5,10,15],
            "criterion": ["gini","entropy"]
        }
    ),

    "Random Forest": (
        RandomForestClassifier(),
        {
            "n_estimators": [50,100,200],
            "max_depth": [None,10,20],
            "criterion": ["gini","entropy"]
        }
    )

}


# -----------------------
# Training Loop
# -----------------------

for name, (model, params) in models.items():

    print("\n======================================")
    print("Training Model:", name)
    print("======================================")

    grid = GridSearchCV(
        model,
        params,
        cv=5,
        scoring="accuracy",
        verbose=2,
        n_jobs=1
    )

    grid.fit(X_train, y_train)

    results = pd.DataFrame(grid.cv_results_)

    print("\nAll Parameter Combinations:")

    for i in range(len(results)):
        print(
            "Params:", results["params"][i],
            "| Mean CV Accuracy:", round(results["mean_test_score"][i],4)
        )

    print("\nBest Parameters:", grid.best_params_)
    print("Best CV Accuracy:", round(grid.best_score_,4))

    best_model = grid.best_estimator_

    y_pred = best_model.predict(X_test)

    test_accuracy = accuracy_score(y_test, y_pred)

    print("Test Accuracy:", round(test_accuracy,4))