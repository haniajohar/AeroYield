"""Advisory service — bilingual text generation and Urdu TTS audio."""

from __future__ import annotations

import hashlib
import logging
import os
from pathlib import Path
from typing import Any

from app.config import settings

logger = logging.getLogger(__name__)

# ──────────────────────────────────────────────
# Advisory text templates per prediction class
# ──────────────────────────────────────────────
ADVISORY_TEXT: dict[int, dict[str, str]] = {
    0: {
        "en": "Conditions are optimal. Continue current practices.",
        "ur": "حالات بہترین ہیں۔ موجودہ طریقہ کار جاری رکھیں۔",
    },
    1: {
        "en": "Stress detected. Consider irrigation within 48 hours.",
        "ur": "فصل میں تناؤ۔ 48 گھنٹوں میں آبپاشی پر غور کریں۔",
    },
    2: {
        "en": "Critical stress. Immediate intervention required.",
        "ur": "شدید تناؤ۔ فوری مداخلت ضروری ہے۔",
    },
}


def get_advisory_text(predicted_class: int) -> dict[str, str]:
    """Return EN and UR advisory text for a given prediction class."""
    return ADVISORY_TEXT.get(predicted_class, ADVISORY_TEXT[0])


async def generate_audio(
    text_ur: str, field_id: str, predicted_class: int
) -> str | None:
    """Generate Urdu TTS audio for advisory text and return a local URL path.

    In production this would upload to S3/Cloudflare R2 and return a CDN URL.
    For local dev, we serve from /static/audio/.
    """
    cache_dir = Path(settings.audio_cache_dir)
    cache_dir.mkdir(parents=True, exist_ok=True)

    # Create a deterministic filename
    text_hash = hashlib.md5(text_ur.encode("utf-8")).hexdigest()[:8]
    filename = f"{field_id}_{text_hash}.mp3"
    filepath = cache_dir / filename

    if filepath.exists():
        return f"/static/audio/{filename}"

    try:
        from gtts import gTTS

        tts = gTTS(text=text_ur, lang="ur", slow=False)
        tts.save(str(filepath))
        logger.info("Generated audio: %s", filepath)
        return f"/static/audio/{filename}"
    except Exception as exc:
        logger.warning("TTS generation failed: %s", exc)
        return None
