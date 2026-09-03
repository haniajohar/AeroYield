"""Generate a mock GradientBoostingClassifier and save with joblib.

Run this once to create crop_vital_model.pkl for development when the
real model artifact is not yet available.

Usage:
    python generate_mock_model.py
"""

import numpy as np
import pandas as pd
from sklearn.ensemble import GradientBoostingClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import f1_score, accuracy_score
import joblib

np.random.seed(42)
N = 3000

# Synthetic feature generation
data = {
    "Temperature": np.random.uniform(5, 45, N),
    "Rainfall": np.random.exponential(2, N),
    "Humidity": np.random.uniform(20, 95, N),
    "Wind_Speed": np.random.uniform(0, 30, N),
    "Temp_Min": np.random.uniform(0, 30, N),
    "Temp_Max": np.random.uniform(20, 50, N),
    "Pressure": np.random.uniform(990, 1025, N),
    "Dew_Point": np.random.uniform(5, 28, N),
    "Cloud_Cover": np.random.uniform(0, 100, N),
    "Temp_Range": np.random.uniform(3, 25, N),
    "month": np.random.randint(1, 13, N),
    "is_hot_day": np.random.choice([0, 1], N),
    "is_cold_day": np.random.choice([0, 1], N),
}

df = pd.DataFrame(data)

# Derive categorical features
conditions = ["No Rain", "Light Rain", "Heavy Rain", "Overcast", "Clear"]
seasons = ["Winter", "Spring", "Summer", "Autumn"]
regions = ["KPK", "Punjab", "Sindh", "Balochistan"]
wind_cats = ["calm", "breeze", "windy", "storm"]

df["Weather_Condition"] = np.random.choice(conditions, N)
df["Season"] = np.random.choice(seasons, N)
df["Region"] = np.random.choice(regions, N)
df["wind_category"] = np.random.choice(wind_cats, N)

# Encode categoricals for the mock (LabelEncoder-like)
for col in ["Weather_Condition", "Season", "Region", "wind_category"]:
    df[col] = df[col].astype("category").cat.codes

# Synthetic labels: stress more likely with extreme temps + low rain
stress_score = (
    (df["Temperature"] - 25).abs() / 20
    + (1 - df["Rainfall"] / df["Rainfall"].max())
    + (df["Humidity"] - 50).abs() / 50
)
labels = pd.cut(
    stress_score,
    bins=[-np.inf, stress_score.quantile(0.45), stress_score.quantile(0.8), np.inf],
    labels=[0, 1, 2],
).astype(int)

X_train, X_test, y_train, y_test = train_test_split(
    df, labels, test_size=0.2, random_state=42
)

model = GradientBoostingClassifier(
    n_estimators=100, max_depth=4, learning_rate=0.1, random_state=42
)
model.fit(X_train, y_train)

preds = model.predict(X_test)
print(f"F1:        {f1_score(y_test, preds, average='weighted'):.4f}")
print(f"Accuracy:  {accuracy_score(y_test, preds):.4f}")

joblib.dump(model, "crop_vital_model.pkl")
print("Saved crop_vital_model.pkl")
