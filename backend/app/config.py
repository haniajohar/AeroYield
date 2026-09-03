"""AeroYield backend configuration loaded from environment / .env file."""

from __future__ import annotations

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    app_name: str = "AeroYield"
    app_env: str = "development"
    debug: bool = False

    # Server
    host: str = "0.0.0.0"
    port: int = 8000

    # Database
    database_url: str = "sqlite:///./aeroyield.db"

    # Security
    api_keys: str = "dev-key-aeroyield-2026"

    # NASA POWER
    nasa_power_base_url: str = (
        "https://power.larc.nasa.gov/api/temporal/daily/point"
    )

    # Audio
    audio_cache_dir: str = "./audio_cache"

    # CORS
    cors_origins: str = (
        "http://localhost:3000,http://localhost:8080,"
        "https://aeroyield-one.vercel.app"
    )

    # Model
    model_path: str = "./crop_vital_model.pkl"
    model_version: str = "1.0"
    model_metadata_path: str = "./crop_vital_model_metadata.json"

    @property
    def api_key_list(self) -> list[str]:
        return [k.strip() for k in self.api_keys.split(",") if k.strip()]

    @property
    def cors_origin_list(self) -> list[str]:
        return [o.strip() for o in self.cors_origins.split(",") if o.strip()]

    model_config = {
        "env_file": ".env",
        "env_file_encoding": "utf-8",
        "protected_namespaces": ("settings_",),
    }


settings = Settings()
