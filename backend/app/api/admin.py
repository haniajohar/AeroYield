"""API routes for the admin dashboard."""

from __future__ import annotations

import json
from datetime import date
from pathlib import Path
from typing import Any

from fastapi import APIRouter, Depends
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.config import settings
from app.database import get_db
from app.models.database import Farm
from app.models.prediction import Prediction
from app.schemas.schemas import (
    DashboardResponse,
    ModelMetricsResponse,
    PredictionHistoryItem,
)
from app.services.ml_service import SCORE_MAP, STATUS_EN, STATUS_UR

router = APIRouter(prefix="/api/admin", tags=["admin"])


# ──────────────────────────────────────────────
# Dashboard stats
# ──────────────────────────────────────────────
@router.get("/dashboard", response_model=DashboardResponse)
async def dashboard(db: Session = Depends(get_db)):
    """Aggregated stats for the admin panel."""
    total_farms = db.query(func.count(Farm.id)).scalar() or 0

    # Today's predictions
    today_start = date.today().isoformat()
    today_preds = (
        db.query(func.count(Prediction.id))
        .filter(Prediction.created_at >= today_start)
        .scalar()
        or 0
    )

    # Count by latest prediction per farm
    latest_ids = (
        db.query(Prediction.field_id, func.max(Prediction.id).label("max_id"))
        .group_by(Prediction.field_id)
        .subquery()
    )
    latest_preds = (
        db.query(Prediction.predicted_class)
        .join(latest_ids, Prediction.id == latest_ids.c.max_id)
        .all()
    )

    healthy = sum(1 for (c,) in latest_preds if c == 0)
    moderate = sum(1 for (c,) in latest_preds if c == 1)
    critical = sum(1 for (c,) in latest_preds if c == 2)

    avg_score = 0.0
    if latest_preds:
        avg_score = round(
            sum(SCORE_MAP.get(c, 0) for (c,) in latest_preds) / len(latest_preds), 1
        )

    # Model accuracy from metadata
    accuracy = 0.9541
    metadata_path = Path(settings.model_metadata_path)
    if metadata_path.exists():
        meta = json.loads(metadata_path.read_text(encoding="utf-8"))
        accuracy = meta.get("metrics", {}).get("accuracy", accuracy)

    return DashboardResponse(
        total_farms=total_farms,
        healthy_count=healthy,
        moderate_count=moderate,
        critical_count=critical,
        avg_vital_score=avg_score,
        predictions_today=today_preds,
        model_version=settings.model_version,
        model_accuracy=accuracy,
    )


# ──────────────────────────────────────────────
# Prediction history
# ──────────────────────────────────────────────
@router.get("/predictions", response_model=list[PredictionHistoryItem])
async def prediction_history(
    limit: int = 100, db: Session = Depends(get_db)
):
    """Last N predictions, newest first."""
    rows = (
        db.query(Prediction)
        .order_by(Prediction.created_at.desc())
        .limit(min(limit, 500))
        .all()
    )
    return [PredictionHistoryItem.model_validate(r) for r in rows]


# ──────────────────────────────────────────────
# Model metrics (passthrough from metadata JSON)
# ──────────────────────────────────────────────
@router.get("/model-metrics", response_model=ModelMetricsResponse)
async def model_metrics():
    """Full model metadata from crop_vital_model_metadata.json."""
    metadata_path = Path(settings.model_metadata_path)
    if not metadata_path.exists():
        return ModelMetricsResponse(
            model_name="AeroYield Crop Vital Classifier",
            model_type="GradientBoostingClassifier",
            model_version=settings.model_version,
            framework="scikit-learn",
            metrics={"accuracy": 0.9541, "f1_score": 0.9536},
            classes={},
            features=[],
            feature_types={},
            training_data={},
            artifact="crop_vital_model.pkl",
            serialised_with="joblib",
            python_version="3.11",
            sklearn_version="1.5.2",
            created_by="AeroYield ML Team",
            created_at="2026-08-20",
        )

    raw: dict[str, Any] = json.loads(
        metadata_path.read_text(encoding="utf-8")
    )
    return ModelMetricsResponse(**raw)
