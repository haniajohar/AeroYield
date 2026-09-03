"""Weather service — fetches data from NASA POWER API for a given lat/lon."""

from __future__ import annotations

import logging
from datetime import date, timedelta
from typing import Any

import httpx

from app.config import settings

logger = logging.getLogger(__name__)

# NASA POWER parameter keys
POWER_PARAMS = [
    "T2M",       # Temperature at 2 m
    "T2M_MIN",   # Min temperature
    "T2M_MAX",   # Max temperature
    "T2MDEW",    # Dew point
    "PRECTOTCORR",  # Precipitation
    "RH2M",      # Relative humidity
    "WS2M",      # Wind speed at 2 m
    "PS",        # Surface pressure
    "CLRSKY_SFC_PAR_TOT",  # Proxy for cloud cover
    "ALLSKY_SFC_SW_DWN",   # Solar radiation
]


async def fetch_weather(latitude: float, longitude: float) -> dict[str, Any]:
    """Fetch latest daily weather from NASA POWER and return a dict
    matching the 17 features expected by the ML model.

    Falls back to synthetic defaults on any error.
    """
    end = date.today() - timedelta(days=2)  # POWER has ~2-day lag
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
            resp = await client.get(settings.nasa_power_base_url, params=params)
            resp.raise_for_status()
            data = resp.json()

        props = data.get("properties", {}).get("parameter", {})
        date_key = list(props.get("T2M", {}).keys())[-1]  # latest date

        def _val(key: str, fallback: float = 0.0) -> float:
            v = float(props.get(key, {}).get(date_key, fallback))
            # NASA POWER uses -999 as a fill value for missing data
            return fallback if v == -999.0 or v == -999 else v

        temp = _val("T2M", 28.0)
        temp_min = _val("T2M_MIN", 22.0)
        temp_max = _val("T2M_MAX", 34.0)
        rainfall = _val("PRECTOTCORR", 0.0)
        humidity = _val("RH2M", 55.0)
        wind = _val("WS2M", 8.0)
        pressure = _val("PS", 1005.0)
        dew = _val("T2MDEW", 18.0)
        cloud = _val("CLRSKY_SFC_PAR_TOT", 20.0)

        # Derive engineered features
        temp_range = temp_max - temp_min
        month = int(date_key[4:6]) if len(date_key) >= 6 else end.month
        is_hot = 1 if temp_max > 38 else 0
        is_cold = 1 if temp_min < 5 else 0

        # Heuristic weather condition
        if rainfall > 10:
            condition = "Heavy Rain"
        elif rainfall > 1:
            condition = "Light Rain"
        elif cloud > 60:
            condition = "Overcast"
        else:
            condition = "No Rain"

        # Season from month
        if month in (12, 1, 2):
            season = "Winter"
        elif month in (3, 4, 5):
            season = "Spring"
        elif month in (6, 7, 8):
            season = "Summer"
        else:
            season = "Autumn"

        # Wind category
        if wind < 3:
            wind_cat = "calm"
        elif wind < 10:
            wind_cat = "breeze"
        elif wind < 20:
            wind_cat = "windy"
        else:
            wind_cat = "storm"

        # Default region (KPK for Mardan farms)
        region = "KPK"

        return {
            "Temperature": temp,
            "Rainfall": rainfall,
            "Humidity": humidity,
            "Wind_Speed": wind,
            "Temp_Min": temp_min,
            "Temp_Max": temp_max,
            "Pressure": pressure,
            "Dew_Point": dew,
            "Cloud_Cover": cloud,
            "Temp_Range": temp_range,
            "month": month,
            "is_hot_day": is_hot,
            "is_cold_day": is_cold,
            "Weather_Condition": condition,
            "Season": season,
            "Region": region,
            "wind_category": wind_cat,
        }

    except Exception as exc:
        logger.warning("NASA POWER fetch failed (%s). Using defaults.", exc)
        return _default_weather()


def _default_weather() -> dict[str, Any]:
    """Synthetic fallback weather for Mardan in summer."""
    from datetime import datetime

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
        "month": datetime.now().month,
        "is_hot_day": 0,
        "is_cold_day": 0,
        "Weather_Condition": "No Rain",
        "Season": "Summer",
        "Region": "KPK",
        "wind_category": "windy",
    }
