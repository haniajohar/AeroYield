"""ML prediction service — loads the model once at startup and serves predictions."""

from __future__ import annotations

import logging
import os
from pathlib import Path
from typing import Any

import numpy as np
import pandas as pd

from app.config import settings

logger = logging.getLogger(__name__)

# ──────────────────────────────────────────────
# Class → score / label mappings
# ──────────────────────────────────────────────
SCORE_MAP: dict[int, int] = {0: 85, 1: 60, 2: 30}

STATUS_EN: dict[int, str] = {
    0: "Healthy",
    1: "Moderate Stress",
    2: "Critical",
}

STATUS_UR: dict[int, str] = {
    0: "صحت مند",
    1: "پانی کی ضرورت",
    2: "خطرہ",
}

# Categorical encodings — must match the training pipeline
CATEGORICAL_ENCODINGS: dict[str, dict[str, int]] = {
    "Weather_Condition": {
        "Clear": 0,
        "Heavy Rain": 1,
        "Light Rain": 2,
        "No Rain": 3,
        "Overcast": 4,
    },
    "Season": {"Autumn": 0, "Spring": 1, "Summer": 2, "Winter": 3},
    "Region": {
        "Balochistan": 0,
        "KPK": 1,
        "Punjab": 2,
        "Sindh": 3,
    },
    "wind_category": {
        "breeze": 0,
        "calm": 1,
        "storm": 2,
        "windy": 3,
    },
}

FEATURE_COLUMNS: list[str] = [
    "Temperature", "Rainfall", "Humidity", "Wind_Speed",
    "Temp_Min", "Temp_Max", "Pressure", "Dew_Point",
    "Cloud_Cover", "Temp_Range", "month", "is_hot_day", "is_cold_day",
    "Weather_Condition", "Season", "Region", "wind_category",
]

# ──────────────────────────────────────────────
# Singleton model holder
# ──────────────────────────────────────────────
_model: Any = None


def get_model():
    """Lazy-load and cache the ML model."""
    global _model
    if _model is not None:
        return _model

    model_path = Path(settings.model_path)
    if not model_path.exists():
        logger.warning(
            "Model file %s not found — predictions will use fallback.",
            model_path,
        )
        _model = None
        return _model

    try:
        import joblib

        _model = joblib.load(str(model_path))
        logger.info("Loaded ML model from %s", model_path)
    except Exception as exc:
        logger.error("Failed to load model: %s", exc)
        _model = None

    return _model


def _encode_features(features: dict[str, Any]) -> dict[str, Any]:
    """Encode categorical string values to integer codes."""
    encoded = dict(features)
    for col, mapping in CATEGORICAL_ENCODINGS.items():
        val = encoded.get(col)
        if isinstance(val, str):
            encoded[col] = mapping.get(val, 0)
    return encoded


def run_prediction(features: dict[str, Any]) -> dict[str, Any]:
    """Run the ML model on a single feature dict and return structured result.

    Returns a dict with keys:
        predicted_class, crop_vital_score, status_label_en, status_label_ur,
        probabilities (list of 3 floats)
    """
    model = get_model()

    encoded = _encode_features(features)
    input_df = pd.DataFrame([encoded])[FEATURE_COLUMNS]

    if model is None:
        # Fallback: deterministic mock based on temperature
        temp = features.get("Temperature", 25)
        if temp < 20 or temp > 40:
            cls = 2
        elif temp < 25 or temp > 35:
            cls = 1
        else:
            cls = 0
        probs = [0.0, 0.0, 0.0]
        probs[cls] = 0.85
        remaining = 0.15 / 2
        for i in range(3):
            if i != cls:
                probs[i] = remaining
    else:
        cls = int(model.predict(input_df)[0])
        raw_probs = model.predict_proba(input_df)[0]
        probs = [round(float(p), 4) for p in raw_probs]

    return {
        "predicted_class": cls,
        "crop_vital_score": SCORE_MAP[cls],
        "status_label_en": STATUS_EN[cls],
        "status_label_ur": STATUS_UR[cls],
        "probabilities": probs,
    }
