"""API routes for farm endpoints."""

from __future__ import annotations

import json
import random
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.database import Farm as FarmModel
from app.models.prediction import Prediction
from app.schemas.schemas import FarmResponse, WeatherSummary
from app.services.advisory_service import generate_audio, get_advisory_text
from app.services.ml_service import run_prediction
from app.services.weather_service import fetch_weather

router = APIRouter(prefix="/api/farms", tags=["farms"])


def _mock_soil_moisture() -> float:
    """Placeholder until satellite data integration."""
    return round(random.uniform(40.0, 80.0), 1)


def _mock_ndvi() -> float:
    """Placeholder NDVI until satellite data integration."""
    return round(random.uniform(0.3, 0.85), 2)


async def _build_farm_response(
    farm: FarmModel,
    prediction: dict | None = None,
    weather_features: dict | None = None,
    db: Session | None = None,
) -> FarmResponse:
    """Build the full FarmResponse, running prediction if needed."""

    # If we don't have a prediction yet, run it
    if prediction is None:
        if weather_features is None:
            weather_features = await fetch_weather(farm.latitude, farm.longitude)
        prediction = run_prediction(weather_features)

    if weather_features is None:
        weather_features = await fetch_weather(farm.latitude, farm.longitude)

    cls = prediction["predicted_class"]
    advisory = get_advisory_text(cls)
    audio_url = await generate_audio(advisory["ur"], farm.field_id, cls)

    # Persist prediction to DB if session available
    if db is not None:
        record = Prediction(
            field_id=farm.field_id,
            predicted_class=cls,
            crop_vital_score=prediction["crop_vital_score"],
            status_label_en=prediction["status_label_en"],
            status_label_ur=prediction["status_label_ur"],
            probability_healthy=prediction["probabilities"][0],
            probability_moderate=prediction["probabilities"][1],
            probability_severe=prediction["probabilities"][2],
            advisory_text_en=advisory["en"],
            advisory_text_ur=advisory["ur"],
            weather_json=json.dumps(weather_features),
        )
        db.add(record)
        db.commit()

    return FarmResponse(
        field_id=farm.field_id,
        farmer_name=farm.farmer_name,
        district=farm.district,
        district_ur=farm.district_ur,
        crop_type=farm.crop_type,
        crop_type_ur=farm.crop_type_ur,
        crop_vital_score=prediction["crop_vital_score"],
        status_label_en=prediction["status_label_en"],
        status_label_ur=prediction["status_label_ur"],
        coordinates=[farm.latitude, farm.longitude],
        soil_moisture_pct=_mock_soil_moisture(),
        ndvi_index=_mock_ndvi(),
        weather=WeatherSummary(
            temp_c=weather_features.get("Temperature", 25.0),
            rain_risk_pct=max(
                0.0,
                min(weather_features.get("Rainfall", 0.0) * 10, 100.0),
            ),
        ),
        advisory_text_en=advisory["en"],
        advisory_text_ur=advisory["ur"],
        audio_url=audio_url,
        last_updated=datetime.now(timezone.utc),
    )


@router.get("", response_model=list[FarmResponse])
async def list_farms(db: Session = Depends(get_db)):
    """Return all farm plots with fresh predictions."""
    farms = db.query(FarmModel).all()
    if not farms:
        return []

    results = []
    for farm in farms:
        weather_features = await fetch_weather(farm.latitude, farm.longitude)
        prediction = run_prediction(weather_features)
        resp = await _build_farm_response(
            farm, prediction=prediction, weather_features=weather_features, db=db
        )
        results.append(resp)
    return results


@router.get("/{field_id}", response_model=FarmResponse)
async def get_farm(field_id: str, db: Session = Depends(get_db)):
    """Return a single farm plot with a fresh prediction."""
    farm = db.query(FarmModel).filter(FarmModel.field_id == field_id).first()
    if farm is None:
        raise HTTPException(status_code=404, detail=f"Farm '{field_id}' not found.")

    weather_features = await fetch_weather(farm.latitude, farm.longitude)
    prediction = run_prediction(weather_features)
    return await _build_farm_response(
        farm, prediction=prediction, weather_features=weather_features, db=db
    )
