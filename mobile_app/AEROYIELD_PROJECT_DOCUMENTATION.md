# AeroYield — Complete Project Documentation

## 1. Executive Summary

AeroYield is a bilingual farm-intelligence platform for smallholder farmers in Pakistan. It combines field location, weather-derived features, a deployed machine-learning model, practical crop advisories, audio guidance, and a simple mobile experience.

The product was designed around one central problem: farmers need understandable, field-specific crop-health guidance without needing to interpret technical weather or machine-learning data. The final delivery includes:

- A Flutter mobile application for farmers.
- A FastAPI backend that retrieves weather features, runs crop-vital predictions, produces advisories, and exposes APIs.
- A deployed real scikit-learn crop-vital model.
- A phone-linked demo ownership flow so farmers see only fields registered from their own device profile.
- English and Urdu support, including right-to-left Urdu layouts.
- GPS/manual field-location entry, voice questions with typed fallback, audio advisories, and visible support actions.
- A separate live admin-panel integration for monitoring farms, predictions, metrics, and map coordinates.
- A release APK ready for installation and manual demonstration.

AeroYield is a working university/demo product. Its ownership mechanism is intentionally described as demo-level privacy filtering, not production-grade authentication or authorization.

---

## 2. Problem Statement

Smallholder farmers commonly face the following challenges:

1. Crop-health information is scattered across weather reports, local observation, and informal advice.
2. Technical indicators such as temperature, rainfall, humidity, vegetation health, and model scores are difficult to convert into a practical irrigation or crop-care action.
3. English-first applications can exclude users who are more comfortable with Urdu.
4. A dashboard that shows generic or another farmer’s field data is not useful or trustworthy.
5. Farmers may have limited digital confidence, limited typing ability, weak connectivity, or difficulty completing registration forms.

AeroYield addresses these problems by turning farm coordinates and weather conditions into a concise crop-vital status, a bilingual recommendation, and an optional audio or voice-based interaction.

---

## 3. Product Vision and Goals

### Vision

Make farm intelligence understandable and accessible for every field, particularly for smallholder farmers in Pakistan.

### Product Goals

- Show a farmer the status of their own registered fields.
- Convert machine-learning output into simple actions such as irrigation, monitoring, or urgent intervention.
- Support both English and Urdu.
- Allow field registration through GPS or manually entered latitude/longitude.
- Make voice interaction useful instead of decorative.
- Keep a support route visible during onboarding.
- Keep the app usable when a network connection is temporarily unavailable.
- Provide a live API and admin-view data contract for monitoring and demonstration.

### Non-goals of the Current Demo

- This version is not a full production farm-management system.
- It does not implement real mobile OTP delivery, JWT sessions, or server-enforced authorization.
- It does not ingest real satellite NDVI or real soil-moisture imagery yet.
- It does not use persistent production-grade database storage on the current Render setup.

---

## 4. Target Users

| User | Primary Need | AeroYield Support |
| --- | --- | --- |
| Farmer | Understand field health and next action | Crop-vital score, status, advisory, audio, voice questions |
| Farmer with limited literacy/digital confidence | Complete setup and obtain help | Urdu UI, GPS assistance, typed fallback, WhatsApp/call support |
| Project demonstrator | Show a complete end-to-end workflow | Quick demo login, deployed API, live model, APK |
| Admin/project team | Observe farm and prediction activity | Admin endpoints and the connected web admin panel |

---

## 5. Final Product Scope

### Farmer Mobile Application

The mobile application provides:

- Language selection: English or Urdu.
- Simulated phone/OTP sign-in and quick-demo access.
- Required first-time onboarding for the farmer’s name and one or more fields.
- Field data entry: label, crop, district, latitude, and longitude.
- GPS capture with manual-coordinate fallback.
- Pakistan coordinate validation.
- Phone-linked local field storage and background synchronization.
- Field-specific dashboard values: crop-vital score, health status, soil-moisture display, NDVI display, weather, rain risk, advisory, and audio.
- Voice/typed questions about water, weather, field health, advice, and help.
- WhatsApp/call helpline controls visible during setup and through the dashboard.
- Light/dark themes, navigation drawer, and bottom navigation.

### FastAPI Backend

The backend provides:

- Health endpoint and OpenAPI documentation.
- API-key middleware and rate limiting.
- Farm list and detail endpoints.
- Owner-phone filtered farm listing for the mobile demo flow.
- Farm creation endpoint for newly registered fields.
- Weather-feature retrieval from NASA POWER.
- Machine-learning prediction and score-to-status mapping.
- Bilingual advice and generated advisory audio.
- Prediction persistence and admin metrics/history endpoints.
- SQLite schema migration for the `owner_phone` field.

### Admin Panel Integration

A separate admin web panel is connected to the same backend contract. Its live integration was updated so farm tables, dashboard KPIs, and map coordinates use API data rather than only hard-coded demo records.

---

## 6. Solution Architecture

```text
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

### Deployment Components

| Component | Technology | Purpose |
| --- | --- | --- |
| Farmer app | Flutter/Dart | Android/iOS user interface |
| State management | Provider | Auth, farm, locale, theme, and audio state |
| Backend | Python/FastAPI | APIs, prediction orchestration, audio, admin data |
| ORM/database | SQLAlchemy + SQLite | Farm and prediction records |
| Weather source | NASA POWER | Weather data used to prepare model features |
| ML runtime | scikit-learn / pandas / NumPy | Crop-vital inference |
| Backend hosting | Render | Public backend deployment |
| Admin web deployment | Vercel | Live browser-based admin interface |

---

## 7. End-to-End Farmer Journey

1. The user opens AeroYield and selects English or Urdu.
2. The user signs in with the demo phone/OTP flow, or uses the quick-demo entry point.
3. A first-time farmer is routed to onboarding rather than seeing shared seed fields.
4. The farmer enters their name and adds at least one field.
5. The farmer selects crop and district, then either:
   - captures GPS coordinates after granting location permission, or
   - enters latitude and longitude manually.
6. Coordinates are checked to ensure they are inside Pakistan.
7. The field is saved locally immediately, so registration is not lost if the API is unavailable.
8. The app sends the field to the backend when possible.
9. The backend stores the field, fetches weather features for its coordinates, runs the ML model, creates advice/audio, and returns the resulting farm record.
10. The dashboard displays only fields associated with the active phone-linked demo profile.
11. The farmer can read, listen to, or ask questions about the selected field.
12. If speech recognition is unavailable, the farmer can type the same question.
13. If the farmer needs assistance, visible WhatsApp and call actions are available.

---

## 8. Mobile Application Implementation

### Application Structure

The Flutter entry point is `lib/main.dart`. It creates a `MultiProvider` application for:

- `AuthProvider`
- `FarmProvider`
- `LocaleProvider`
- `ThemeProvider`
- `AudioProvider`

The named route flow includes splash, language selection, login, onboarding, and the farm home dashboard.

### Localization and Accessibility

- English and Urdu are supported by the in-app localization tables.
- Urdu uses right-to-left layout support.
- The UI uses bilingual crop, district, status, and advisory values.
- Google Fonts support English and Urdu typography.
- A visible helpline reduces dependence on successful form completion.

### Field Onboarding

`lib/screens/onboarding_screen.dart` handles first-time field registration.

The form requires:

- Farmer name
- At least one field
- Field label
- Crop type and Urdu crop type
- District and Urdu district
- Latitude and longitude

The mobile app validates Pakistan coordinate bounds:

- Latitude: `23.5` to `37.5`
- Longitude: `60.5` to `77.5`

The location picker supports:

- GPS acquisition through `geolocator`
- Manual coordinate entry
- Clear error handling for location service disabled, permission denied, permanently denied, or unavailable GPS

### Phone-Linked Demo Ownership

The original prototype exposed shared seeded fields to every user. This was changed after identifying that a farmer should not see another farmer’s field information.

The final demo flow works as follows:

- The login profile retains a phone number and farmer name in `SharedPreferences`.
- Field registrations are stored locally per phone number.
- `FarmProvider` starts with no shared farm list.
- The app requests `GET /api/farms?owner_phone=<phone>`.
- The app accepts that response only when the backend sends `X-AeroYield-Owner-Filter: v1`.
- If that contract is absent, the app fails closed: it does not show shared seed farms.
- Pending local fields are shown as `Awaiting sync` until backend synchronization succeeds.
- If a Render database reset removes remote records, the app can mark retained local registrations as pending and re-create them once the owner-filter endpoint is available.

This avoids accidental shared-data display in the demo client.

### Dashboard

The farm dashboard includes:

- Active field selection
- Crop-vital gauge
- Crop health/status label
- Soil-moisture and NDVI cards
- Temperature and rain-risk data
- Bilingual advisory text
- Advisory audio playback
- Voice assistant action
- Helpline modal
- Profile, language, theme, and logout controls

### Voice Assistant

The old microphone animation was replaced with functional speech input.

Implementation details:

- `speech_to_text` captures speech where device recognition support is available.
- The app selects a suitable English or Urdu recognition locale when available.
- A typed-question field is always available as a fallback.
- Questions are evaluated against the currently selected `FarmData`, not a hard-coded demonstration field.
- Supported intent groups include:
  - irrigation/water/soil moisture
  - weather/rain/temperature
  - crop health/status/score
  - advisory/recommendation
  - help/helpline
- English, Urdu script, and common Roman Urdu keywords are supported.

### Offline-First Behavior

A newly added field is saved on the device before remote synchronization. The UI can display a local placeholder with:

- `Awaiting sync` status
- the registered crop/district/coordinates
- a message that the field will synchronize when connectivity returns

This prevents field details from disappearing when mobile data or the Render service is unavailable.

### Mobile Permissions

Android configuration includes:

- Internet access for release builds
- Microphone access
- Coarse and fine location access
- Speech-recognition service query support

The iOS configuration includes purpose strings for:

- Location while in use
- Microphone access
- Speech recognition

---

## 9. Backend Implementation

### Core Services

The backend is implemented with FastAPI and is organized around farm, prediction, and admin routes. During startup it:

1. Creates database tables.
2. Runs the idempotent `owner_phone` schema migration.
3. Seeds baseline demo farms when appropriate.
4. Preloads the ML model.
5. Serves static audio files from `/static/audio`.

### API Protection and Reliability

- API routes require an `X-API-Key` header, except public health/docs/static paths.
- Requests are rate-limited at `120/minute` by IP address.
- CORS uses configured allowed origins.
- The backend exposes `/health`, `/docs`, and `/redoc`.
- Mobile requests use generous timeouts and retry logic to accommodate Render cold starts.

### Field Ownership Schema Change

The `farms` table now has an indexed nullable `owner_phone` value. The startup migration safely adds the column to existing SQLite deployments because `create_all()` alone does not alter an existing table.

### Mobile Ownership Endpoints

| Endpoint | Purpose | Important Behavior |
| --- | --- | --- |
| `GET /api/farms` | Admin/all-farm list | Returns all farms for permitted admin-style usage |
| `GET /api/farms?owner_phone=<phone>` | Mobile field list | Filters farms by phone and returns `X-AeroYield-Owner-Filter: v1` |
| `POST /api/farms` | Register field | Creates a field, runs weather/ML/advisory processing, returns `201 Created` |
| `GET /api/farms/{field_id}` | Individual field | Returns one field’s current response |
| `POST /api/predict/{field_id}` | Manual prediction | Runs prediction using submitted or fetched weather features |
| `GET /api/admin/dashboard` | Admin KPI data | Returns farm/prediction/model summary |
| `GET /api/admin/predictions` | History | Returns prediction records |
| `GET /api/admin/model-metrics` | Model metadata | Returns model details and metrics |
| `GET /health` | Service health | Public liveness check |

### Field-Creation Request Contract

The create-field request contains:

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

Server-side validation:

- Normalizes Pakistani phone numbers.
- Rejects blank required fields.
- Requires latitude and longitude within the Pakistan bounds used by the mobile app.
- Generates a unique server field ID.

### Weather Processing

The weather service requests recent NASA POWER agricultural weather data for the field coordinates. It obtains raw values including temperature, temperature range, precipitation, humidity, wind speed, pressure, dew point, and cloud/solar indicators, then builds the feature values expected by the model.

A coarse coordinate-based province function derives the `Region` categorical model feature as KPK, Punjab, Sindh, or Balochistan. This corrected the earlier behavior where all fields were treated as KPK regardless of their location.

---

## 10. Machine-Learning Implementation

### Model

The production backend uses the deployed real `AeroYield Crop Vital Classifier`, a scikit-learn `GradientBoostingClassifier` pipeline.

The model metadata reports:

| Metric | Value |
| --- | --- |
| Accuracy | 0.9541 |
| F1 score | 0.9536 |
| Precision | 0.9543 |
| Recall | 0.9541 |

### Input Features

The model expects 17 weather/context features:

- Temperature
- Rainfall
- Humidity
- Wind speed
- Minimum temperature
- Maximum temperature
- Pressure
- Dew point
- Cloud cover
- Temperature range
- Month
- Hot-day indicator
- Cold-day indicator
- Weather condition
- Season
- Region
- Wind category

Categorical values are encoded to match the training pipeline before prediction.

### Crop-Vital Mapping

The classifier returns one of three classes. AeroYield converts it into a simple farmer-facing score and bilingual status.

| Model class | Crop Vital Score | English status | Urdu status |
| --- | ---: | --- | --- |
| 0 | 85 | Healthy | صحت مند |
| 1 | 60 | Moderate Stress | پانی کی ضرورت |
| 2 | 30 | Critical | خطرہ |

The score is deliberately simple. It lets the dashboard and voice assistant communicate an understandable status without requiring a farmer to interpret raw probabilities.

### Advisories and Audio

After prediction, the backend:

1. Chooses an English and Urdu advisory appropriate to the predicted class.
2. Stores a prediction record, including probabilities and the weather-feature JSON.
3. Generates/caches Urdu advisory audio.
4. Returns a static audio URL with the normal farm response.

The mobile app resolves relative audio paths against the backend base URL before streaming them.

### Important Data Transparency

The ML prediction is driven by real deployed model inference and NASA POWER weather features. However, the current `soil_moisture_pct` and `ndvi_index` fields are generated mock/demo values in the backend response. They are not yet derived from field sensors or satellite-imagery processing. This must be stated accurately in any academic presentation or public demonstration.

---

## 11. Data Contract

A farm API response contains the following main fields:

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

The Flutter `FarmData` model parses and serializes this contract, including `[latitude, longitude]` coordinates for onboarding and mapping use cases.

---

## 12. Development Evolution

### Phase 1 — Initial Farmer Dashboard

The initial Flutter implementation established the main dashboard, bilingual visual design, farm cards, crop-vital gauge, advisory information, audio controls, and simulated data.

### Phase 2 — Live Backend Integration

The app was connected to the public Render backend. The implementation added:

- Production base URL configuration
- API-key request header support
- Cold-start-aware timeouts/retry behavior
- Relative audio URL resolution
- Fixture-based API contract tests

The web admin experience was also corrected so tables, KPIs, and map data used live API responses instead of hard-coded browser demo plots.

### Phase 3 — Real ML Model Deployment

A real serialized scikit-learn pipeline was deployed to replace the earlier fallback prediction behavior. The implementation included:

- Updated ML service model loading and feature encoding
- Compatible Python package versions
- Model metadata and class mappings
- Production verification using severe-weather input that produces the critical class rather than the fallback heuristic’s moderate result

### Phase 4 — API-Key Rotation

An exposed key was rotated. Mobile configuration was updated to support build-time override through a Dart define rather than requiring a source-code change for future rotations.

### Phase 5 — Farmer-Centered Ownership and Voice Redesign

Farmer feedback identified several product gaps:

- The microphone icon was decorative rather than functional.
- The app displayed other farmers’ seeded fields.
- Farmer name and location were not collected before dashboard use.
- Help was not prominent during setup.

Two options were considered:

- **Plan A:** production multi-farmer authentication and server-side ownership with JWT/OTP flows.
- **Plan B:** a faster phone-linked demo flow with local-first field registration and transparent security limits.

Plan B was selected for the university demo timeline. It delivered functional onboarding, phone-linked filtering, voice recognition, typed fallback, location collection, and a visible helpline.

### Phase 6 — Backend Deployment and Release Packaging

The backend ownership patch was applied, tested, committed, and deployed. The release APK was rebuilt after the Render backend was verified to return the owner-filter response header.

---

## 13. Verification Performed

### Backend Local Validation

The backend test suite completed successfully for:

- Health check
- Missing-key rejection
- Farm listing
- Single-farm response
- Prediction endpoint
- Admin dashboard
- Prediction history
- Model metrics
- Unknown-farm `404` response

The new ownership flow was also tested locally:

- Owner-filtered list returned `200 OK` and `X-AeroYield-Owner-Filter: v1`.
- Creating a field returned `201 Created`.
- The creating phone saw exactly its field.
- A different phone saw an empty list.

### Deployment Validation

After the backend commit was pushed to `main`, the Render deployment was checked directly. The live owner-filter endpoint returned the expected `X-AeroYield-Owner-Filter: v1` header.

### Flutter Validation

The current mobile source passed:

```text
flutter analyze
# No issues found

flutter test
# 7 tests passed
```

The test suite covers:

- Parsing full live-captured farm API payloads
- Single-farm parsing and audio URL resolution
- JSON round-trip behavior
- Pakistan coordinate contract checks
- English irrigation/soil-moisture voice replies
- Urdu crop-health voice replies
- Helpline intent behavior
- App launch/splash behavior

### Release Artifact

A release build completed successfully:

```text
flutter build apk --release
```

Artifact:

```text
build/app/outputs/flutter-apk/app-release.apk
```

The generated APK size is approximately 50.9 MB.

---

## 14. Manual Demonstration Script

Use this sequence to present the system clearly.

1. Install the release APK on an Android phone.
2. Open AeroYield and choose Urdu or English.
3. Sign in with a new phone number.
4. Show that onboarding requests the farmer name and field information.
5. Demonstrate GPS capture, or enter a valid Pakistan latitude/longitude manually.
6. Add a crop and district, then continue to the dashboard.
7. Show that only the newly registered field is shown for that phone profile.
8. Explain the crop-vital score, status, temperature, rain risk, advisory, and audio card.
9. Tap the microphone and ask a question such as:
   - “Do I need water today?”
   - “What is my crop health?”
   - “What is the weather?”
10. Deny microphone permission if needed and show the typed-question fallback.
11. Tap the helpline option and show the WhatsApp/call support actions.
12. Sign out, use a different phone number, and show that it does not receive the first profile’s field list.
13. Open the admin panel and show aggregate farms, predictions, metrics, and mapped coordinates.

---

## 15. Setup and Build Guide

### Flutter App

From the mobile project root:

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

The release APK is created at:

```text
build\app\outputs\flutter-apk\app-release.apk
```

### Backend Local Server

The backend virtual environment is located at the backend repository root. Start the application using the backend source directory as the app directory:

```powershell
& "<backend-root>\.venv\Scripts\python.exe" -m uvicorn app.main:app `
  --app-dir "<backend-root>\backend" --host 127.0.0.1 --port 8000
```

To avoid Windows console encoding errors in the API test script:

```powershell
$env:PYTHONIOENCODING='utf-8'
& "<backend-root>\.venv\Scripts\python.exe" "<backend-root>\backend\test_api.py"
```

### Environment and Secret Handling

- Configure backend API keys in the backend hosting environment.
- Send the key as `X-API-Key` from trusted clients.
- Supply mobile keys with a build-time Dart define for release distribution.
- Do not place production secrets in public repositories, screenshots, documentation, or presentation slides.
- Rotate any key immediately if it is exposed.

---

## 16. Important Limitations and Honest Scope

### Plan B Is Not Production Security

The `owner_phone` flow is a demo UX privacy filter, not secure authorization.

Why:

- The user identity is not cryptographically verified.
- A phone value can be supplied by the client.
- The API currently does not bind a signed token to a specific owner.
- Direct server endpoints need true role/ownership checks before public production use.

The app protects its own UX by refusing a farm-list response that lacks the explicit ownership header, but this does not replace backend authorization.

### Database Persistence

The current Render configuration uses ephemeral SQLite storage. A service redeploy can reset stored farm and prediction data. The app’s local field queue reduces the impact for the same phone by re-synchronizing field registrations, but a production rollout requires durable managed storage such as PostgreSQL.

### Data Quality

- Weather features are fetched from NASA POWER.
- The ML model is real and deployed.
- Soil moisture and NDVI are currently generated demo values, not sensor/satellite products.
- The region calculation is a coarse coordinate-based classification, not an official GIS boundary service.

### Voice Recognition

Speech recognition depends on device support, installed language packs, and granted permissions. The typed fallback is part of the intended product behavior, not a failure mode.

### Real Mobile Authentication

Login currently simulates the OTP experience for a controlled demonstration. A production system requires a verified SMS/WhatsApp OTP provider, backend-issued tokens, secure session expiry, and account recovery.

---

## 17. Recommended Next Phase: Production Plan A

To evolve AeroYield from a strong demo into a deployable production product:

1. Implement verified phone authentication with SMS/WhatsApp OTP.
2. Issue short-lived JWT access tokens and refresh tokens.
3. Associate each farm with a server-side authenticated user ID rather than a submitted phone string.
4. Require ownership checks on every farm detail, prediction, update, and delete endpoint.
5. Replace Render SQLite with managed PostgreSQL and migrations.
6. Move mobile API configuration entirely to secure build/deployment configuration; never ship a reusable production secret in source.
7. Add server-side audit logs, request validation, and role-based admin access.
8. Replace simulated soil-moisture and NDVI values with a documented sensor or satellite-imagery pipeline.
9. Add a map-based coordinate picker and field boundary polygons.
10. Add notifications for critical predictions and pending sync failures.
11. Track model monitoring metrics, data drift, prediction outcomes, and farmer feedback.
12. Conduct user testing with farmers in multiple districts and refine Urdu wording accordingly.

---

## 18. Key Source Map

### Flutter

| Area | Main Files |
| --- | --- |
| App bootstrap/routes | `lib/main.dart` |
| Authentication/profile state | `lib/providers/auth_provider.dart` |
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

### Backend

| Area | Main Files |
| --- | --- |
| FastAPI bootstrap | `backend/app/main.py` |
| Farm endpoints | `backend/app/api/farms.py` |
| Farm ORM model | `backend/app/models/database.py` |
| Field-create validation | `backend/app/schemas/schemas_plan_b.py` |
| Owner-phone migration | `backend/app/services/plan_b_migration.py` |
| Weather features/region | `backend/app/services/weather_service.py` |
| ML model service | `backend/app/services/ml_service.py` |
| ML metadata | `backend/crop_vital_model_metadata.json` |

---

## 19. Final Deliverables

The completed AeroYield delivery consists of:

- Flutter mobile application source code.
- Android release APK.
- Bilingual English/Urdu farmer experience.
- GPS/manual field onboarding.
- Phone-linked demo field filtering with local-first synchronization.
- Functional microphone-driven/typed farm question assistant.
- Visible WhatsApp and call support.
- FastAPI backend with API-key middleware, rate limiting, owner-filter endpoint, farm creation endpoint, prediction endpoints, admin endpoints, and audio serving.
- Deployed real crop-vital machine-learning model.
- NASA POWER weather-feature integration.
- Connected live admin-panel data contract.
- Test coverage and successful validation results.
- A documented production roadmap that distinguishes working demo behavior from production requirements.

---

## 20. Conclusion

AeroYield progressed from a visual agricultural dashboard into an end-to-end farm-intelligence demonstration. The final system accepts a farmer’s field location, obtains weather-based features, uses a deployed ML model to classify crop condition, converts the result into bilingual advice, supports audio and voice interaction, and presents a field-specific dashboard.

The most important user-centered improvements were ensuring that farmers do not automatically see shared demo fields, collecting farmer/field information before the dashboard, making the microphone functional, offering a typed fallback, and exposing helpline actions throughout the experience.

The current result is suitable for a project demonstration, academic evaluation, and further development. Its remaining limitations are explicit: production authentication, durable database storage, secure server authorization, and real sensor/satellite vegetation data are the next steps required for a public production deployment.
