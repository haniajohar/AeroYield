"""AeroYield FastAPI entry point with Plan B ownership migration."""

from __future__ import annotations

import logging
from contextlib import asynccontextmanager
from pathlib import Path

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles
from slowapi import Limiter
from slowapi.errors import RateLimitExceeded
from slowapi.util import get_remote_address

from app.api import admin, farms, predict
from app.config import settings
from app.database import Base, SessionLocal, engine
from app.services.ml_service import get_model
from app.services.plan_b_migration import migrate_owner_phone_column
from app.services.seed_service import seed_farms

logger = logging.getLogger("aeroyield")
logging.basicConfig(
    level=logging.DEBUG if settings.debug else logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
)

limiter = Limiter(key_func=get_remote_address, default_limits=["120/minute"])


@asynccontextmanager
async def lifespan(application: FastAPI):
    logger.info("Creating database tables …")
    Base.metadata.create_all(bind=engine)
    migrate_owner_phone_column()

    logger.info("Seeding demo farms …")
    db = SessionLocal()
    try:
        seed_farms(db)
    finally:
        db.close()

    logger.info("Pre-loading ML model …")
    get_model()
    logger.info("AeroYield backend ready ✓")
    yield
    logger.info("Shutting down AeroYield backend …")


app = FastAPI(
    title="AeroYield API",
    description="Satellite + AI-driven farm intelligence platform for smallholder farmers in Pakistan.",
    version="1.0.0",
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc",
)
app.state.limiter = limiter


@app.exception_handler(RateLimitExceeded)
async def rate_limit_handler(request: Request, exc: RateLimitExceeded):
    return JSONResponse(
        status_code=429,
        content={"detail": f"Rate limit exceeded: {exc.detail}"},
    )


PUBLIC_PATHS = {"/docs", "/redoc", "/openapi.json", "/health"}


@app.middleware("http")
async def api_key_middleware(request: Request, call_next):
    path = request.url.path
    if (
        path in PUBLIC_PATHS
        or path.startswith("/static")
        or request.method == "OPTIONS"
    ):
        return await call_next(request)

    key = request.headers.get("X-API-Key")
    if key not in settings.api_key_list:
        return JSONResponse(
            status_code=401,
            content={"detail": "Invalid or missing API key. Send X-API-Key header."},
        )
    return await call_next(request)


app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origin_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

audio_dir = Path(settings.audio_cache_dir)
audio_dir.mkdir(parents=True, exist_ok=True)
app.mount("/static/audio", StaticFiles(directory=str(audio_dir)), name="audio")

app.include_router(farms.router)
app.include_router(predict.router)
app.include_router(admin.router)


@app.get("/health", tags=["meta"])
async def health():
    return {"status": "ok", "service": settings.app_name, "version": "1.0.0"}
