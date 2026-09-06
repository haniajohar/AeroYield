param(
    [string]$BackendRoot = "C:\Users\ALH\Desktop\backend\backend"
)

$ErrorActionPreference = "Stop"
$patchRoot = Split-Path -Parent $PSCommandPath

$required = @(
    "$BackendRoot\app\main.py",
    "$BackendRoot\app\models\database.py",
    "$BackendRoot\app\api\farms.py",
    "$BackendRoot\app\services\weather_service.py"
)
foreach ($path in $required) {
    if (-not (Test-Path $path)) {
        throw "Backend file not found: $path"
    }
}

$backupRoot = Join-Path $BackendRoot (".plan_b_backup_" + (Get-Date -Format "yyyyMMdd_HHmmss"))
New-Item -ItemType Directory -Path $backupRoot | Out-Null
Copy-Item "$BackendRoot\app\main.py" $backupRoot
Copy-Item "$BackendRoot\app\models\database.py" $backupRoot
Copy-Item "$BackendRoot\app\api\farms.py" $backupRoot
Copy-Item "$BackendRoot\app\services\weather_service.py" $backupRoot

Copy-Item "$patchRoot\main.py" "$BackendRoot\app\main.py" -Force
Copy-Item "$patchRoot\database.py" "$BackendRoot\app\models\database.py" -Force
Copy-Item "$patchRoot\farms.py" "$BackendRoot\app\api\farms.py" -Force
Copy-Item "$patchRoot\weather_service.py" "$BackendRoot\app\services\weather_service.py" -Force
Copy-Item "$patchRoot\schemas_plan_b.py" "$BackendRoot\app\schemas\schemas_plan_b.py" -Force
Copy-Item "$patchRoot\plan_b_migration.py" "$BackendRoot\app\services\plan_b_migration.py" -Force

$python = "$BackendRoot\.venv\Scripts\python.exe"
if (-not (Test-Path $python)) { $python = "python" }
& $python -m compileall -q "$BackendRoot\app"
if ($LASTEXITCODE -ne 0) { throw "Python compile check failed." }

Write-Host "Plan B backend files installed. Backup: $backupRoot"
Write-Host "Next: inspect git diff, run the backend test suite, then commit and push."
