"""Pydantic schemas for Plan B owned-farm creation."""

from __future__ import annotations

from pydantic import BaseModel, Field, field_validator


class FarmCreateRequest(BaseModel):
    """Mobile field-registration body for the device-linked demo flow."""

    owner_phone: str = Field(..., min_length=8, max_length=20)
    farmer_name: str = Field(..., min_length=2, max_length=200)
    field_label: str = Field(..., min_length=1, max_length=100)
    crop_type: str = Field(..., min_length=2, max_length=80)
    crop_type_ur: str = Field(..., min_length=1, max_length=80)
    district: str = Field(..., min_length=2, max_length=100)
    district_ur: str = Field(..., min_length=1, max_length=100)
    latitude: float = Field(..., ge=23.5, le=37.5)
    longitude: float = Field(..., ge=60.5, le=77.5)

    @field_validator("owner_phone")
    @classmethod
    def normalize_phone(cls, value: str) -> str:
        digits = "".join(character for character in value if character.isdigit())
        if digits.startswith("92"):
            return f"+{digits}"
        if digits.startswith("0"):
            return f"+92{digits[1:]}"
        return f"+92{digits}"

    @field_validator(
        "farmer_name", "field_label", "crop_type", "crop_type_ur",
        "district", "district_ur",
    )
    @classmethod
    def strip_text(cls, value: str) -> str:
        value = value.strip()
        if not value:
            raise ValueError("must not be blank")
        return value
