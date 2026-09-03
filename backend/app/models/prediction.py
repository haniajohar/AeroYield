"""SQLAlchemy ORM model for a prediction record."""

from __future__ import annotations

from datetime import datetime

from sqlalchemy import DateTime, Float, Integer, String, Text, func
from sqlalchemy.orm import Mapped, mapped_column

from app.database import Base


class Prediction(Base):
    __tablename__ = "predictions"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    field_id: Mapped[str] = mapped_column(String(120), index=True, nullable=False)
    predicted_class: Mapped[int] = mapped_column(Integer, nullable=False)
    crop_vital_score: Mapped[int] = mapped_column(Integer, nullable=False)
    status_label_en: Mapped[str] = mapped_column(String(40), nullable=False)
    status_label_ur: Mapped[str] = mapped_column(String(80), nullable=False)
    probability_healthy: Mapped[float] = mapped_column(Float, nullable=False)
    probability_moderate: Mapped[float] = mapped_column(Float, nullable=False)
    probability_severe: Mapped[float] = mapped_column(Float, nullable=False)
    advisory_text_en: Mapped[str] = mapped_column(Text, nullable=False)
    advisory_text_ur: Mapped[str] = mapped_column(Text, nullable=False)
    weather_json: Mapped[str] = mapped_column(Text, nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
