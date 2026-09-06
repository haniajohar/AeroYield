# =============================================================================
# deploy_real_model.ps1 — Deploy the ML team's REAL crop_vital_model.pkl
#
# What it does:
#   1. Backs up the dev mock model (crop_vital_model.mock.bak.pkl)
#   2. Copies the REAL model from OneDrive Downloads into the backend
#   3. Copies the patched ml_service.py / requirements.txt / metadata JSON
#   4. Upgrades the local backend venv to the new dependency pins
#   5. Verifies the real model loads and predicts correctly
#   6. Stages everything in git (pkl force-added — it is gitignored)
#
# It does NOT commit or push — review with `git diff --cached`, then commit.
#
# Usage:  powershell -ExecutionPolicy Bypass -File deploy_real_model.ps1
# =============================================================================
$ErrorActionPreference = "Stop"

$backendRoot = "C:\Users\ALH\Desktop\backend"
$backend     = "$backendRoot\backend"
$venvPython  = "$backendRoot\.venv\Scripts\python.exe"
$realModel   = "C:\Users\ALH\OneDrive\Documents\Downloads\crop_vital_model.pkl"
$pkg         = $PSScriptRoot

# ── 1. Verify the real artifact exists ──────────────────────────────────────
if (-not (Test-Path $realModel)) {
    throw "REAL model not found at: $realModel"
}
$sizeMb = [math]::Round((Get-Item $realModel).Length / 1MB, 1)
Write-Host "[1/6] Real model found ($sizeMb MB)"

# ── 2. Back up the mock ─────────────────────────────────────────────────────
if (Test-Path "$backend\crop_vital_model.pkl") {
    Copy-Item "$backend\crop_vital_model.pkl" "$backend\crop_vital_model.mock.bak.pkl" -Force
    Write-Host "[2/6] Dev mock backed up -> crop_vital_model.mock.bak.pkl"
} else {
    Write-Host "[2/6] No existing model file (skipped backup)"
}

# ── 3. Copy real model + patched files ──────────────────────────────────────
Copy-Item $realModel "$backend\crop_vital_model.pkl" -Force
Copy-Item "$pkg\ml_service.py" "$backend\app\services\ml_service.py" -Force
Copy-Item "$pkg\requirements.txt" "$backend\requirements.txt" -Force
Copy-Item "$pkg\crop_vital_model_metadata.json" "$backend\crop_vital_model_metadata.json" -Force
Write-Host "[3/6] Real model + patched ml_service.py / requirements.txt / metadata copied"

# ── 4. Upgrade the backend venv to the new pins ─────────────────────────────
Write-Host "[4/6] Upgrading backend venv (scikit-learn 1.9.0, numpy 2.x) ..."
& $venvPython -m pip install --quiet --disable-pip-version-check -r "$backend\requirements.txt"
if ($LASTEXITCODE -ne 0) { throw "pip install failed — resolve dependency errors before deploying" }

# ── 5. Verify the model loads and predicts ──────────────────────────────────
Write-Host "[5/6] Verifying model load + prediction ..."
& $venvPython -c "
import joblib, pandas as pd
m = joblib.load(r'$backend\crop_vital_model.pkl')
assert hasattr(m, 'steps'), 'expected a sklearn Pipeline'
X = pd.DataFrame([{
    'Temperature': 38.0, 'Rainfall': 0.0, 'Humidity': 85.0, 'Wind_Speed': 12.0,
    'Temp_Min': 30.0, 'Temp_Max': 42.0, 'Pressure': 1002.0, 'Dew_Point': 25.0,
    'Cloud_Cover': 10.0, 'Temp_Range': 12.0, 'month': 6, 'is_hot_day': 1, 'is_cold_day': 0,
    'Weather_Condition': 'No Rain', 'Season': 'Summer', 'Region': 'KPK', 'wind_category': 'windy'}])
cls = int(m.predict(X)[0]); p = m.predict_proba(X)[0]
print(f'    Pipeline loaded OK. Severe-weather test -> class {cls}, p(severe)={p[2]:.2%}')
assert cls == 2, 'severe payload should classify as class 2 (Critical)'
print('    PASSED: real model is live')
"
if ($LASTEXITCODE -ne 0) { throw "Model verification failed — see output above" }

# ── 6. Stage in git (pkl is gitignored -> force-add) ────────────────────────
Set-Location $backendRoot
git add -f "backend/crop_vital_model.pkl"
git add "backend/app/services/ml_service.py" "backend/requirements.txt" "backend/crop_vital_model_metadata.json"
Write-Host "[6/6] Staged. Review with:  git diff --cached"
git status --short
Write-Host ""
Write-Host "When ready, deploy with:"
Write-Host "  git commit -m 'Deploy real ML model (sklearn Pipeline) + raw-feature encoding fix + sklearn/numpy bump'"
Write-Host "  git push   # Render auto-deploys"
Write-Host ""
Write-Host "After Render finishes, verify production with the severe-weather discriminator:"
Write-Host "  curl -X POST -H 'X-API-Key: <prod key>' -H 'Content-Type: application/json' ^"
Write-Host "       --data '@.temp_severe.json' https://aeroyield-api.onrender.com/api/predict/mardan_plot_01"
Write-Host "  Expected: crop_vital_score = 30, status = Critical (NOT 60 / Moderate Stress)"
