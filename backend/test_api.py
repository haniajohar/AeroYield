"""Quick test script for all AeroYield API endpoints."""

import httpx
import json

BASE = "http://127.0.0.1:8000"
HEADERS = {"X-API-Key": "dev-key-aeroyield-2026"}


def test(name, response):
    ok = "✓" if response.status_code == 200 else "✗"
    print(f"  {ok} {name}: {response.status_code}")
    return response.json() if response.status_code == 200 else None


print("═══ AeroYield API Test Suite ═══\n")

# 1. Health check (no API key needed)
print("[1] Health Check")
r = httpx.get(f"{BASE}/health")
test("GET /health", r)

# 2. Auth — no key should fail
print("\n[2] Auth — missing key")
r = httpx.get(f"{BASE}/api/farms")
print(f"  {'✓' if r.status_code == 401 else '✗'} No key → 401: {r.status_code}")

# 3. List farms
print("\n[3] List Farms")
r = httpx.get(f"{BASE}/api/farms", headers=HEADERS, timeout=30)
data = test("GET /api/farms", r)
if data:
    print(f"  → {len(data)} farms returned")
    for f in data:
        print(f"    • {f['field_id']}: {f['status_label_en']} "
              f"(score={f['crop_vital_score']}, "
              f"ur={f['status_label_ur']})")

# 4. Single farm
print("\n[4] Single Farm")
r = httpx.get(f"{BASE}/api/farms/mardan_plot_01", headers=HEADERS, timeout=30)
data = test("GET /api/farms/mardan_plot_01", r)
if data:
    print(f"  → {data['field_id']}: {data['advisory_text_en']}")
    print(f"  → UR: {data['advisory_text_ur']}")
    print(f"  → Weather: temp={data['weather']['temp_c']}°C, "
          f"rain_risk={data['weather']['rain_risk_pct']}%")
    print(f"  → Soil: {data['soil_moisture_pct']}%, "
          f"NDVI: {data['ndvi_index']}")
    print(f"  → Audio: {data['audio_url']}")

# 5. POST prediction
print("\n[5] POST Prediction")
payload = {
    "Temperature": 28.0, "Rainfall": 0.0, "Humidity": 55.0,
    "Wind_Speed": 8.5, "Temp_Min": 22.0, "Temp_Max": 34.0,
    "Pressure": 1005.0, "Dew_Point": 18.0, "Cloud_Cover": 20.0,
    "Temp_Range": 12.0, "month": 7, "is_hot_day": 0, "is_cold_day": 0,
    "Weather_Condition": "No Rain", "Season": "Summer",
    "Region": "KPK", "wind_category": "windy"
}
r = httpx.post(
    f"{BASE}/api/predict/mardan_plot_01",
    headers=HEADERS,
    json=payload,
    timeout=30,
)
data = test("POST /api/predict/mardan_plot_01", r)
if data:
    print(f"  → Prediction: {data['status_label_en']} "
          f"(score={data['crop_vital_score']})")

# 6. Admin dashboard
print("\n[6] Admin Dashboard")
r = httpx.get(f"{BASE}/api/admin/dashboard", headers=HEADERS, timeout=15)
data = test("GET /api/admin/dashboard", r)
if data:
    print(f"  → Total farms: {data['total_farms']}")
    print(f"  → Healthy: {data['healthy_count']}, "
          f"Moderate: {data['moderate_count']}, "
          f"Critical: {data['critical_count']}")
    print(f"  → Avg vital score: {data['avg_vital_score']}")
    print(f"  → Predictions today: {data['predictions_today']}")
    print(f"  → Model: v{data['model_version']} "
          f"(accuracy={data['model_accuracy']})")

# 7. Prediction history
print("\n[7] Prediction History")
r = httpx.get(f"{BASE}/api/admin/predictions", headers=HEADERS, timeout=15)
data = test("GET /api/admin/predictions", r)
if data:
    print(f"  → {len(data)} prediction records")

# 8. Model metrics
print("\n[8] Model Metrics")
r = httpx.get(f"{BASE}/api/admin/model-metrics", headers=HEADERS, timeout=15)
data = test("GET /api/admin/model-metrics", r)
if data:
    print(f"  → {data['model_name']} v{data['model_version']}")
    print(f"  → Type: {data['model_type']}")
    print(f"  → Features: {len(data['features'])}")
    print(f"  → Accuracy: {data['metrics'].get('accuracy')}")

# 9. 404 for unknown farm
print("\n[9] 404 — unknown farm")
r = httpx.get(f"{BASE}/api/farms/nonexistent", headers=HEADERS, timeout=15)
print(f"  {'✓' if r.status_code == 404 else '✗'} "
      f"GET /api/farms/nonexistent → {r.status_code}")

print("\n═══ All tests complete ═══")
