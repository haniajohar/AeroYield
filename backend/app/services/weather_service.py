"""Weather service — fetches NASA POWER data and infers ML Region by location."""

from __future__ import annotations

import logging
from datetime import date, datetime, timedelta
from typing import Any

import httpx

from app.config import settings

logger = logging.getLogger(__name__)

POWER_PARAMS = [
    "T2M", "T2M_MIN", "T2M_MAX", "T2MDEW", "PRECTOTCORR", "RH2M",
    "WS2M", "PS", "CLRSKY_SFC_PAR_TOT", "ALLSKY_SFC_SW_DWN",
]


def province_for_coordinates(latitude: float, longitude: float) -> str:
    """Coarse offline province lookup for the ML Region categorical feature."""
    if latitude >= 31.0 and longitude <= 74.8:
        return "KPK"
    if latitude >= 29.0 and longitude >= 69.0:
        return "Punjab"
    if latitude < 29.0 and longitude >= 66.0:
        return "Sindh"
    return "Balochistan"


async def fetch_weather(latitude: float, longitude: float) -> dict[str, Any]:
    """Fetch latest daily weather matching the model's 17 input features."""
    end = date.today() - timedelta(days=2)
    start = end - timedelta(days=1)
    params = {
        "start": start.strftime("%Y%m%d"),
        "end": end.strftime("%Y%m%d"),
        "latitude": latitude,
        "longitude": longitude,
        "community": "AG",
        "parameters": ",".join(POWER_PARAMS),
        "format": "JSON",
    }

    try:
        async with httpx.AsyncClient(timeout=15.0) as client:
            response = await client.get(settings.nasa_power_base_url, params=params)
            response.raise_for_status()
            data = response.json()

        parameters = data.get("properties", {}).get("parameter", {})
        date_key = list(parameters.get("T2M", {}).keys())[-1]

        def value(key: str, fallback: float = 0.0) -> float:
            result = float(parameters.get(key, {}).get(date_key, fallback))
            return fallback if result == -999.0 else result

        temperature = value("T2M", 28.0)
        temp_min = value("T2M_MIN", 22.0)
        temp_max = value("T2M_MAX", 34.0)
        rainfall = value("PRECTOTCORR", 0.0)
        humidity = value("RH2M", 55.0)
        wind = value("WS2M", 8.0)
        cloud = value("CLRSKY_SFC_PAR_TOT", 20.0)
        month = int(date_key[4:6]) if len(date_key) >= 6 else end.month

        if rainfall > 10:
            condition = "Heavy Rain"
        elif rainfall > 1:
            condition = "Light Rain"
        elif cloud > 60:
            condition = "Overcast"
        else:
            condition = "No Rain"

        if month in (12, 1, 2):
            season = "Winter"
        elif month in (3, 4, 5):
            season = "Spring"
        elif month in (6, 7, 8):
            season = "Summer"
        else:
            season = "Autumn"

        wind_category = "calm" if wind < 3 else "breeze" if wind < 10 else "windy" if wind < 20 else "storm"
        return {
            "Temperature": temperature,
            "Rainfall": rainfall,
            "Humidity": humidity,
            "Wind_Speed": wind,
            "Temp_Min": temp_min,
            "Temp_Max": temp_max,
            "Pressure": value("PS", 1005.0),
            "Dew_Point": value("T2MDEW", 18.0),
            "Cloud_Cover": cloud,
            "Temp_Range": temp_max - temp_min,
            "month": month,
            "is_hot_day": 1 if temp_max > 38 else 0,
            "is_cold_day": 1 if temp_min < 5 else 0,
            "Weather_Condition": condition,
            "Season": season,
            "Region": province_for_coordinates(latitude, longitude),
            "wind_category": wind_category,
        }
    except Exception as error:
        logger.warning("NASA POWER fetch failed (%s). Using defaults.", error)
        return _default_weather(latitude, longitude)


def _default_weather(latitude: float = 34.2, longitude: float = 72.0) -> dict[str, Any]:
    """Synthetic fallback weather retaining the registered field's province."""
    month = datetime.now().month
    return {
        "Temperature": 28.0,
        "Rainfall": 0.0,
        "Humidity": 55.0,
        "Wind_Speed": 8.5,
        "Temp_Min": 22.0,
        "Temp_Max": 34.0,
        "Pressure": 1005.0,
        "Dew_Point": 18.0,
        "Cloud_Cover": 20.0,
        "Temp_Range": 12.0,
        "month": month,
        "is_hot_day": 0,
        "is_cold_day": 0,
        "Weather_Condition": "No Rain",
        "Season": "Summer",
        "Region": province_for_coordinates(latitude, longitude),
        "wind_category": "windy",
    }
