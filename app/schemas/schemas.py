"""Pydantic schemas for farm data, predictions, and admin endpoints."""

from __future__ import annotations

from datetime import datetime
from typing import Any

from pydantic import BaseModel, Field


# ──────────────────────────────────────────────
# Weather sub-schema
# ──────────────────────────────────────────────
class WeatherSummary(BaseModel):
    temp_c: float = Field(..., description="Current temperature in °C")
    rain_risk_pct: float = Field(
        ..., ge=0, le=100, description="Rainfall probability percentage"
    )


# ──────────────────────────────────────────────
# ML prediction request body (17 features)
# ──────────────────────────────────────────────
class PredictionRequest(BaseModel):
    Temperature: float
    Rainfall: float
    Humidity: float
    Wind_Speed: float
    Temp_Min: float
    Temp_Max: float
    Pressure: float
    Dew_Point: float
    Cloud_Cover: float
    Temp_Range: float
    month: int = Field(..., ge=1, le=12)
    is_hot_day: int = Field(..., ge=0, le=1)
    is_cold_day: int = Field(..., ge=0, le=1)
    Weather_Condition: str
    Season: str
    Region: str
    wind_category: str


# ──────────────────────────────────────────────
# Farm response (matches Flutter contract)
# ──────────────────────────────────────────────
class FarmResponse(BaseModel):
    field_id: str
    farmer_name: str
    district: str
    district_ur: str
    crop_type: str
    crop_type_ur: str
    crop_vital_score: int
    status_label_en: str
    status_label_ur: str
    soil_moisture_pct: float = Field(
        ..., description="Placeholder until satellite data integration"
    )
    ndvi_index: float = Field(
        ..., description="Placeholder NDVI until satellite integration"
    )
    weather: WeatherSummary
    advisory_text_en: str
    advisory_text_ur: str
    audio_url: str | None = None
    last_updated: datetime

    model_config = {"from_attributes": True}


# ──────────────────────────────────────────────
# Admin dashboard
# ──────────────────────────────────────────────
class DashboardResponse(BaseModel):
    model_config = {"protected_namespaces": ()}

    total_farms: int
    healthy_count: int
    moderate_count: int
    critical_count: int
    avg_vital_score: float
    predictions_today: int
    model_version: str
    model_accuracy: float


# ──────────────────────────────────────────────
# Admin prediction history item
# ──────────────────────────────────────────────
class PredictionHistoryItem(BaseModel):
    id: int
    field_id: str
    predicted_class: int
    crop_vital_score: int
    status_label_en: str
    status_label_ur: str
    probability_healthy: float
    probability_moderate: float
    probability_severe: float
    advisory_text_en: str
    advisory_text_ur: str
    weather_json: str
    created_at: datetime

    model_config = {"from_attributes": True}


# ──────────────────────────────────────────────
# Model metrics (passthrough from JSON)
# ──────────────────────────────────────────────
class ModelMetricsResponse(BaseModel):
    model_config = {"protected_namespaces": ()}

    model_name: str
    model_type: str
    model_version: str
    framework: str
    metrics: dict[str, float]
    classes: dict[str, dict[str, Any]]
    features: list[str]
    feature_types: dict[str, list[str]]
    training_data: dict[str, Any]
    artifact: str
    serialised_with: str
    python_version: str
    sklearn_version: str
    created_by: str
    created_at: str


# ──────────────────────────────────────────────
# Generic error
# ──────────────────────────────────────────────
class ErrorDetail(BaseModel):
    detail: str
