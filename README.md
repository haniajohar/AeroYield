# AeroYield

**A bilingual farm-intelligence platform for smallholder farmers in Pakistan.**

AeroYield turns a farmer's field location and live weather conditions into a simple, understandable crop-health status — delivered in English or Urdu, with optional voice interaction and audio guidance. It combines a Flutter mobile app, a FastAPI backend, a deployed scikit-learn ML model, and a connected admin panel into one end-to-end demo product.

> **Status:** University/demo project. The ownership mechanism described below is a demo-level privacy filter, not production-grade authentication or authorization. See [Limitations](#limitations--honest-scope) before treating this as production-ready.

**🔗 Live links:**
- **Admin Web Panel:** [aeroyield-one.vercel.app](https://aeroyield-one.vercel.app/)
- **Backend API Docs (Swagger):** [aeroyield-api.onrender.com/docs](https://aeroyield-api.onrender.com/docs)

> Note: the backend is hosted on Render's free tier, so the first request after a period of inactivity may take a few seconds while the service cold-starts.

---

## Table of Contents

- [Why AeroYield](#why-aeroyield)
- [Features](#features)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Data Contract](#data-contract)
- [Machine Learning Model](#machine-learning-model)
- [Getting Started](#getting-started)
- [API Reference](#api-reference)
- [Testing & Verification](#testing--verification)
- [Demo Script](#demo-script)
- [Project Structure](#project-structure)
- [Limitations & Honest Scope](#limitations--honest-scope)
- [Roadmap](#roadmap)
- [License](#license)

---

## Why AeroYield

Smallholder farmers commonly face:

- Crop-health information scattered across weather reports, local observation, and informal advice.
- Technical indicators (temperature, rainfall, humidity, vegetation health, model scores) that are hard to turn into a practical action.
- English-first apps that exclude Urdu-first users.
- Dashboards that show generic or someone else's field data.
- Limited digital confidence, weak connectivity, or difficulty completing registration forms.

AeroYield addresses this by converting farm coordinates and weather data into a concise crop-vital score, a bilingual recommendation, and an optional audio/voice interaction — with nothing shown that isn't the farmer's own field.

## Features

- 🌐 **Bilingual UI** — full English and Urdu support, including right-to-left Urdu layouts.
- 📍 **Field onboarding** — GPS capture with manual lat/long fallback, validated against Pakistan's coordinate bounds.
- 🤖 **Real ML inference** — a deployed scikit-learn crop-vital classifier, not a mocked heuristic.
- 🌦️ **Live weather features** — pulled from NASA POWER for each field's coordinates.
- 🔊 **Voice + typed assistant** — ask about water, weather, crop health, or advice; typed fallback when speech recognition isn't available.
- 🔒 **Phone-linked demo ownership** — a farmer only ever sees fields registered from their own device profile.
- 📴 **Offline-first registration** — new fields save locally first and sync when connectivity returns.
- 🆘 **Visible support** — WhatsApp/call helpline actions during onboarding and on the dashboard.
- 📊 **Live admin panel** — farms, predictions, model metrics, and map coordinates driven by the same API contract.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Farmer Mobile App                        │
│ Flutter + Provider + English/Urdu + Local Field Queue            │
│                                                                   │
│ Login → Onboarding → GPS/manual location → Dashboard → Voice     │
└───────────────────────┬─────────────────────────────────────────┘
                        │ HTTPS + X-API-Key
                        │
┌───────────────────────▼─────────────────────────────────────────┐
│                         FastAPI Backend                          │
│ API key middleware · rate limiting · SQLite · migrations         │
│ farms API · prediction API · admin API · advisory audio          │
└───────┬───────────────────────┬───────────────────────┬─────────┘
        │                       │                       │
┌───────▼─────────┐   ┌─────────▼────────────┐  ┌───────▼────────┐
│ NASA POWER      │   │ scikit-learn model    │  │ Audio/static   │
│ weather data    │   │ Crop Vital Classifier │  │ advisory files │
└─────────────────┘   └──────────────────────┘  └────────────────┘
                        │
             ┌──────────▼──────────┐
             │ Admin Web Panel     │
             │ KPIs, plots, map    │
             └─────────────────────┘
```

### Deployment components

| Component | Technology | Purpose |
|---|---|---|
| Farmer app | Flutter/Dart | Android/iOS user interface |
| State management | Provider | Auth, farm, locale, theme, and audio state |
| Backend | Python/FastAPI | APIs, prediction orchestration, audio, admin data |
| ORM/database | SQLAlchemy + SQLite | Farm and prediction records |
| Weather source | NASA POWER | Weather data used to prepare model features |
| ML runtime | scikit-learn / pandas / NumPy | Crop-vital inference |
| Backend hosting | Render | Public backend deployment |
| Admin web deployment | Vercel | Live browser-based admin interface |

## Tech Stack

- **Mobile:** Flutter, Dart, Provider, `geolocator`, `speech_to_text`, Google Fonts
- **Backend:** FastAPI, SQLAlchemy, SQLite, Uvicorn
- **ML:** scikit-learn (`GradientBoostingClassifier`), pandas, NumPy
- **Weather:** NASA POWER API
- **Hosting:** Render (backend), Vercel (admin panel)

## Data Contract

A farm API response looks like this:

```json
{
  "field_id": "uf_example",
  "farmer_name": "Farmer name",
  "district": "Mardan",
  "district_ur": "مردان",
  "crop_type": "Wheat",
  "crop_type_ur": "گندم",
  "crop_vital_score": 60,
  "status_label_en": "Moderate Stress",
  "status_label_ur": "پانی کی ضرورت",
  "coordinates": [34.2, 72.0],
  "soil_moisture_pct": 42.5,
  "ndvi_index": 0.51,
  "weather": {
    "temp_c": 31.0,
    "rain_risk_pct": 20.0
  },
  "advisory_text_en": "Irrigate within 24 hours.",
  "advisory_text_ur": "24 گھنٹے کے اندر آبپاشی کریں۔",
  "audio_url": "/static/audio/example.mp3",
  "last_updated": "ISO-8601 timestamp"
}
```

> ⚠️ `soil_moisture_pct` and `ndvi_index` are currently **generated demo values**, not real sensor or satellite data. Everything else in the response is driven by live weather data and real model inference.

## Machine Learning Model

The backend uses a deployed **AeroYield Crop Vital Classifier** — a scikit-learn `GradientBoostingClassifier` pipeline.

| Metric | Value |
|---|---|
| Accuracy | 0.9541 |
| F1 score | 0.9536 |
| Precision | 0.9543 |
| Recall | 0.9541 |

**17 input features:** temperature, rainfall, humidity, wind speed, min/max temperature, pressure, dew point, cloud cover, temperature range, month, hot-day indicator, cold-day indicator, weather condition, season, region, wind category.

**Class → status mapping:**

| Model class | Crop Vital Score | English status | Urdu status |
|---|---|---|---|
| 0 | 85 | Healthy | صحت مند |
| 1 | 60 | Moderate Stress | پانی کی ضرورت |
| 2 | 30 | Critical | خطرہ |

Region (`KPK`, `Punjab`, `Sindh`, `Balochistan`) is derived from a coarse coordinate-based function — not an official GIS boundary service.

## Getting Started

### Live deployments

| Component | URL |
|---|---|
| Admin Web Panel | https://aeroyield-one.vercel.app/ |
| Backend API (Swagger/OpenAPI docs) | https://aeroyield-api.onrender.com/docs |

### Flutter app

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

Release APK output:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Backend (local)

```powershell
& "<backend-root>\.venv\Scripts\python.exe" -m uvicorn app.main:app `
  --app-dir "<backend-root>\backend" --host 127.0.0.1 --port 8000
```

To avoid Windows console encoding errors when running the API test script:

```powershell
$env:PYTHONIOENCODING='utf-8'
& "<backend-root>\.venv\Scripts\python.exe" "<backend-root>\backend\test_api.py"
```

### Environment & secrets

- Configure backend API keys in the backend hosting environment.
- Send the key as `X-API-Key` from trusted clients.
- Supply mobile keys via a build-time Dart define for release builds.
- Never commit production secrets to source, screenshots, docs, or slides.
- Rotate any exposed key immediately.

## API Reference

| Endpoint | Purpose | Notes |
|---|---|---|
| `GET /api/farms` | Admin/all-farm list | Returns all farms for admin-style usage |
| `GET /api/farms?owner_phone=<phone>` | Mobile field list | Filters by phone; returns `X-AeroYield-Owner-Filter: v1` |
| `POST /api/farms` | Register field | Runs weather/ML/advisory processing; returns `201 Created` |
| `GET /api/farms/{field_id}` | Individual field | Returns one field's current response |
| `POST /api/predict/{field_id}` | Manual prediction | Runs prediction using submitted or fetched weather features |
| `GET /api/admin/dashboard` | Admin KPI data | Farm/prediction/model summary |
| `GET /api/admin/predictions` | History | Prediction records |
| `GET /api/admin/model-metrics` | Model metadata | Model details and metrics |
| `GET /health` | Service health | Public liveness check |

All routes except `/health`, `/docs`, `/redoc`, and static paths require an `X-API-Key` header. Requests are rate-limited at 120/minute per IP.

### Field-creation request

```json
{
  "owner_phone": "+92...",
  "farmer_name": "Farmer name",
  "field_label": "My field",
  "crop_type": "Wheat",
  "crop_type_ur": "گندم",
  "district": "Mardan",
  "district_ur": "مردان",
  "latitude": 34.2,
  "longitude": 72.0
}
```

Server-side validation normalizes Pakistani phone numbers, rejects blank required fields, enforces Pakistan coordinate bounds, and generates a unique server field ID.

**Pakistan coordinate bounds (also validated client-side):**
- Latitude: `23.5` to `37.5`
- Longitude: `60.5` to `77.5`

## Testing & Verification

**Backend** — test suite passes for health check, missing-key rejection, farm listing, single-farm response, prediction endpoint, admin dashboard, prediction history, model metrics, and unknown-farm 404. Ownership flow tested for correct 200/201 responses, header presence, and per-phone isolation.

**Flutter:**

```bash
flutter analyze
# No issues found

flutter test
# 7 tests passed
```

Covers: farm API payload parsing, audio URL resolution, JSON round-trip, Pakistan coordinate contract checks, English/Urdu voice replies, helpline intent behavior, and app launch/splash behavior.

**Deployment** — the live Render owner-filter endpoint was confirmed to return `X-AeroYield-Owner-Filter: v1`.

## Demo Script

1. Install the release APK on an Android phone.
2. Open AeroYield and choose Urdu or English.
3. Sign in with a new phone number.
4. Show onboarding requesting farmer name and field information.
5. Demonstrate GPS capture, or enter a valid Pakistan lat/long manually.
6. Add a crop and district, then continue to the dashboard.
7. Show that only the newly registered field appears for that phone profile.
8. Explain the crop-vital score, status, temperature, rain risk, advisory, and audio card.
9. Tap the microphone and ask: *"Do I need water today?"* / *"What is my crop health?"* / *"What is the weather?"*
10. Deny microphone permission and show the typed-question fallback.
11. Tap the helpline option and show WhatsApp/call actions.
12. Sign out, use a different phone number, and confirm it doesn't see the first profile's fields.
13. Open the admin panel and show aggregate farms, predictions, metrics, and mapped coordinates.

## Project Structure

**Flutter**

| Area | Main files |
|---|---|
| App bootstrap/routes | `lib/main.dart` |
| Auth/profile state | `lib/providers/auth_provider.dart` |
| Field ownership/sync state | `lib/providers/farm_provider.dart` |
| API client | `lib/services/api_service.dart` |
| Onboarding | `lib/screens/onboarding_screen.dart` |
| Dashboard | `lib/screens/farm_home_screen.dart` |
| GPS/manual location | `lib/widgets/field_location_picker.dart` |
| Voice interaction | `lib/widgets/voice_assistant_modal.dart` |
| Field-aware replies | `lib/services/farm_voice_assistant.dart` |
| Local pending fields | `lib/services/local_field_store.dart` |
| Support controls | `lib/widgets/helpline_footer.dart` |
| API model | `lib/models/farm_data.dart` |
| Registration model | `lib/models/field_registration.dart` |
| Tests | `test/backend_contract_test.dart`, `test/farm_voice_assistant_test.dart`, `test/widget_test.dart` |

**Backend**

| Area | Main files |
|---|---|
| FastAPI bootstrap | `backend/app/main.py` |
| Farm endpoints | `backend/app/api/farms.py` |
| Farm ORM model | `backend/app/models/database.py` |
| Field-create validation | `backend/app/schemas/schemas_plan_b.py` |
| Owner-phone migration | `backend/app/services/plan_b_migration.py` |
| Weather features/region | `backend/app/services/weather_service.py` |
| ML model service | `backend/app/services/ml_service.py` |
| ML metadata | `backend/crop_vital_model_metadata.json` |

## Limitations & Honest Scope

**Plan B is not production security.** The `owner_phone` flow is a demo UX privacy filter, not secure authorization:
- User identity is not cryptographically verified.
- The phone value is client-supplied.
- No signed token is bound to a specific owner.
- Direct server endpoints still need real role/ownership checks before public production use.

The app fails closed at the UX layer (it refuses a farm list without the ownership header), but this does not replace backend authorization.

**Other known limitations:**
- **Database persistence:** Render uses ephemeral SQLite — a redeploy can reset stored data. The local field queue mitigates this for the same phone, but production needs durable storage (e.g., PostgreSQL).
- **Data quality:** weather features are real (NASA POWER) and the ML model is real and deployed, but `soil_moisture_pct` and `ndvi_index` are currently generated demo values, not sensor/satellite data. Region is a coarse coordinate-based classification, not an official GIS service.
- **Voice recognition:** depends on device support, installed language packs, and granted permissions — the typed fallback is intended behavior, not a failure mode.
- **Authentication:** login simulates OTP for demonstration purposes; production requires a verified SMS/WhatsApp OTP provider, backend-issued tokens, secure session expiry, and account recovery.

## Roadmap

Recommended next phase ("Production Plan A"):

1. Verified phone authentication via SMS/WhatsApp OTP.
2. Short-lived JWT access + refresh tokens.
3. Associate farms with a server-side authenticated user ID, not a submitted phone string.
4. Ownership checks on every farm detail/prediction/update/delete endpoint.
5. Replace SQLite with managed PostgreSQL and migrations.
6. Move all API configuration to secure build/deployment config — no secrets in source.
7. Server-side audit logs, request validation, role-based admin access.
8. Replace simulated soil-moisture/NDVI with a documented sensor or satellite-imagery pipeline.
9. Map-based coordinate picker and field boundary polygons.
10. Notifications for critical predictions and pending sync failures.
11. Model monitoring: drift, prediction outcomes, farmer feedback.
12. User testing with farmers across multiple districts; refine Urdu wording.

## License

Add your license here (e.g., MIT, Apache 2.0) — none specified in current project documentation.
