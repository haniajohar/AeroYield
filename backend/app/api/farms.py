"""Replacement for app/api/farms.py — Plan B owned-field endpoints."""

from __future__ import annotations

import json
import random
import secrets
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, Query, Response, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.database import Farm as FarmModel
from app.models.prediction import Prediction
from app.schemas.schemas import FarmResponse, WeatherSummary
from app.schemas.schemas_plan_b import FarmCreateRequest
from app.services.advisory_service import generate_audio, get_advisory_text
from app.services.ml_service import run_prediction
from app.services.weather_service import fetch_weather

router = APIRouter(prefix="/api/farms", tags=["farms"])


def _mock_soil_moisture() -> float:
    return round(random.uniform(40.0, 80.0), 1)


def _mock_ndvi() -> float:
    return round(random.uniform(0.3, 0.85), 2)


async def _build_farm_response(
    farm: FarmModel,
    prediction: dict | None = None,
    weather_features: dict | None = None,
    db: Session | None = None,
) -> FarmResponse:
    if prediction is None:
        if weather_features is None:
            weather_features = await fetch_weather(farm.latitude, farm.longitude)
        prediction = run_prediction(weather_features)

    if weather_features is None:
        weather_features = await fetch_weather(farm.latitude, farm.longitude)

    cls = prediction["predicted_class"]
    advisory = get_advisory_text(cls)
    audio_url = await generate_audio(advisory["ur"], farm.field_id, cls)

    if db is not None:
        db.add(
            Prediction(
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
        )
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
                0.0, min(weather_features.get("Rainfall", 0.0) * 10, 100.0)
            ),
        ),
        advisory_text_en=advisory["en"],
        advisory_text_ur=advisory["ur"],
        audio_url=audio_url,
        last_updated=datetime.now(timezone.utc),
    )


@router.get("", response_model=list[FarmResponse])
async def list_farms(
    response: Response,
    owner_phone: str | None = Query(default=None, max_length=20),
    db: Session = Depends(get_db),
):
    """Return all farms for admin, or only one phone's fields for mobile.

    Plan B limitation: owner_phone is a demo UX filter, not authorization.
    """
    query = db.query(FarmModel)
    if owner_phone:
        response.headers["X-AeroYield-Owner-Filter"] = "v1"
        query = query.filter(FarmModel.owner_phone == owner_phone)
    farms = query.all()

    results = []
    for farm in farms:
        weather_features = await fetch_weather(farm.latitude, farm.longitude)
        prediction = run_prediction(weather_features)
        results.append(
            await _build_farm_response(
                farm,
                prediction=prediction,
                weather_features=weather_features,
                db=db,
            )
        )
    return results


@router.post("", response_model=FarmResponse, status_code=status.HTTP_201_CREATED)
async def create_farm(
    body: FarmCreateRequest,
    db: Session = Depends(get_db),
):
    """Register a phone-owned demo field and immediately return its ML result."""
    field_id = f"uf_{secrets.token_hex(5)}"
    farm = FarmModel(
        field_id=field_id,
        owner_phone=body.owner_phone,
        farmer_name=body.farmer_name,
        district=body.district,
        district_ur=body.district_ur,
        crop_type=body.crop_type,
        crop_type_ur=body.crop_type_ur,
        latitude=body.latitude,
        longitude=body.longitude,
    )
    db.add(farm)
    db.commit()
    db.refresh(farm)

    weather_features = await fetch_weather(farm.latitude, farm.longitude)
    prediction = run_prediction(weather_features)
    return await _build_farm_response(
        farm,
        prediction=prediction,
        weather_features=weather_features,
        db=db,
    )


@router.get("/{field_id}", response_model=FarmResponse)
async def get_farm(field_id: str, db: Session = Depends(get_db)):
    farm = db.query(FarmModel).filter(FarmModel.field_id == field_id).first()
    if farm is None:
        raise HTTPException(status_code=404, detail=f"Farm '{field_id}' not found.")

    weather_features = await fetch_weather(farm.latitude, farm.longitude)
    prediction = run_prediction(weather_features)
    return await _build_farm_response(
        farm, prediction=prediction, weather_features=weather_features, db=db
    )
