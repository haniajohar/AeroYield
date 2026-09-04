"""API route for triggering a fresh ML prediction."""

from __future__ import annotations

import json
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.database import Farm as FarmModel
from app.models.prediction import Prediction
from app.schemas.schemas import FarmResponse, PredictionRequest, WeatherSummary
from app.services.advisory_service import generate_audio, get_advisory_text
from app.services.ml_service import run_prediction

router = APIRouter(prefix="/api/predict", tags=["predict"])


@router.post("/{field_id}", response_model=FarmResponse)
async def predict_farm(
    field_id: str,
    body: PredictionRequest,
    db: Session = Depends(get_db),
):
    """Trigger a fresh ML prediction with the supplied weather features."""
    farm = db.query(FarmModel).filter(FarmModel.field_id == field_id).first()
    if farm is None:
        raise HTTPException(status_code=404, detail=f"Farm '{field_id}' not found.")

    features = body.model_dump()
    prediction = run_prediction(features)

    cls = prediction["predicted_class"]
    advisory = get_advisory_text(cls)
    audio_url = await generate_audio(advisory["ur"], farm.field_id, cls)

    # Persist
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
        weather_json=json.dumps(features),
    )
    db.add(record)
    db.commit()

    import random

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
        soil_moisture_pct=round(random.uniform(40.0, 80.0), 1),
        ndvi_index=round(random.uniform(0.3, 0.85), 2),
        weather=WeatherSummary(
            temp_c=features.get("Temperature", 25.0),
            rain_risk_pct=max(
                0.0, min(features.get("Rainfall", 0.0) * 10, 100.0)
            ),
        ),
        advisory_text_en=advisory["en"],
        advisory_text_ur=advisory["ur"],
        audio_url=audio_url,
        last_updated=datetime.now(timezone.utc),
    )
