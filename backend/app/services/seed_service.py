"""Seed the database with demo farm plots on first run."""

from __future__ import annotations

import logging

from sqlalchemy.orm import Session

from app.models.database import Farm

logger = logging.getLogger(__name__)

SEED_FARMS = [
    {
        "field_id": "mardan_plot_01",
        "farmer_name": "Khan Muhammad",
        "district": "Mardan",
        "district_ur": "مردان",
        "crop_type": "Maize",
        "crop_type_ur": "مکئی",
        "latitude": 34.1989,
        "longitude": 72.0421,
    },
    {
        "field_id": "mardan_plot_02",
        "farmer_name": "Gul Zaman",
        "district": "Mardan",
        "district_ur": "مردان",
        "crop_type": "Sugarcane",
        "crop_type_ur": "گنا",
        "latitude": 34.2100,
        "longitude": 72.0550,
    },
    {
        "field_id": "swabi_plot_01",
        "farmer_name": "Sher Ali Khan",
        "district": "Swabi",
        "district_ur": "صوابی",
        "crop_type": "Tobacco",
        "crop_type_ur": "تمباکو",
        "latitude": 34.1200,
        "longitude": 72.4700,
    },
    {
        "field_id": "charsadda_plot_01",
        "farmer_name": "Bakht Nawaz",
        "district": "Charsadda",
        "district_ur": "چارسدہ",
        "crop_type": "Wheat",
        "crop_type_ur": "گندم",
        "latitude": 34.1490,
        "longitude": 71.7410,
    },
]


def seed_farms(db: Session) -> None:
    """Insert seed farms if the table is empty."""
    existing = db.query(Farm).first()
    if existing is not None:
        logger.info("Database already seeded — skipping.")
        return

    for data in SEED_FARMS:
        db.add(Farm(**data))

    db.commit()
    logger.info("Seeded %d farm plots.", len(SEED_FARMS))
