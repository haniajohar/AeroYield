"""Quick test script for live AeroYield API on Render."""

import httpx

BASE = "https://aeroyield-api.onrender.com"
HEADERS = {"X-API-Key": "aeroyield-prod-key-2026"}


def test(name, response):
    ok = "PASS" if response.status_code == 200 else "FAIL"
    print(f"  [{ok}] {name}: {response.status_code}")
    return response.json() if response.status_code == 200 else None


print("=== AeroYield LIVE API Test ===\n")

# 1. Health
print("[1] Health Check")
r = httpx.get(f"{BASE}/health", timeout=30)
test("GET /health", r)

# 2. Auth - no key
print("\n[2] Auth - missing key")
r = httpx.get(f"{BASE}/api/farms", timeout=30)
print(f"  [{'PASS' if r.status_code == 401 else 'FAIL'}] No key -> 401: {r.status_code}")

# 3. List farms
print("\n[3] List Farms")
r = httpx.get(f"{BASE}/api/farms", headers=HEADERS, timeout=60)
data = test("GET /api/farms", r)
if data:
    print(f"  -> {len(data)} farms")
    for f in data:
        print(f"     {f['field_id']}: {f['status_label_en']} (score={f['crop_vital_score']})")

# 4. Single farm
print("\n[4] Single Farm")
r = httpx.get(f"{BASE}/api/farms/mardan_plot_01", headers=HEADERS, timeout=60)
data = test("GET /api/farms/mardan_plot_01", r)
if data:
    print(f"  -> {data['field_id']}: {data['advisory_text_en']}")
    print(f"  -> Weather: temp={data['weather']['temp_c']}C, rain={data['weather']['rain_risk_pct']}%")

# 5. POST prediction
print("\n[5] POST Prediction")
payload = {
    "Temperature": 38.0, "Rainfall": 0.0, "Humidity": 30.0,
    "Wind_Speed": 15.0, "Temp_Min": 28.0, "Temp_Max": 42.0,
    "Pressure": 1000.0, "Dew_Point": 15.0, "Cloud_Cover": 10.0,
    "Temp_Range": 14.0, "month": 7, "is_hot_day": 1, "is_cold_day": 0,
    "Weather_Condition": "No Rain", "Season": "Summer",
    "Region": "KPK", "wind_category": "windy"
}
r = httpx.post(f"{BASE}/api/predict/mardan_plot_01", headers=HEADERS, json=payload, timeout=60)
data = test("POST /api/predict/mardan_plot_01", r)
if data:
    print(f"  -> {data['status_label_en']} (score={data['crop_vital_score']})")

# 6. Admin dashboard
print("\n[6] Admin Dashboard")
r = httpx.get(f"{BASE}/api/admin/dashboard", headers=HEADERS, timeout=30)
data = test("GET /api/admin/dashboard", r)
if data:
    print(f"  -> Farms: {data['total_farms']}, H:{data['healthy_count']} M:{data['moderate_count']} C:{data['critical_count']}")
    print(f"  -> Avg score: {data['avg_vital_score']}, Model acc: {data['model_accuracy']}")

# 7. Prediction history
print("\n[7] Prediction History")
r = httpx.get(f"{BASE}/api/admin/predictions", headers=HEADERS, timeout=30)
data = test("GET /api/admin/predictions", r)
if data:
    print(f"  -> {len(data)} records")

# 8. Model metrics
print("\n[8] Model Metrics")
r = httpx.get(f"{BASE}/api/admin/model-metrics", headers=HEADERS, timeout=30)
data = test("GET /api/admin/model-metrics", r)
if data:
    print(f"  -> {data['model_name']} v{data['model_version']}, {len(data['features'])} features")

# 9. CORS on error
print("\n[9] CORS on 401 error")
r = httpx.get(f"{BASE}/api/farms", headers={"Origin": "https://aeroyield-one.vercel.app"}, timeout=30)
cors = r.headers.get("access-control-allow-origin", "MISSING")
print(f"  -> Status: {r.status_code}, CORS header: {cors}")

print("\n=== All tests complete ===")
