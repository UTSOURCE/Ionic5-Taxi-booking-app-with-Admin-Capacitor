<#
.SYNOPSIS
    Sanitizes the Ride-Share Pro repository for public distribution.
    Removes all source code, API keys, and sensitive configuration
    while preserving assets, package manifests, and config files.

.DESCRIPTION
    ⚠️  BUILD YOUR DEMO APK FIRST before running this script!
    This script permanently deletes source code and cannot be undone.

.EXAMPLE
    .\sanitize.ps1
#>

param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Ride-Share Pro — Repository Sanitizer" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

if (-not $Force) {
    Write-Host "⚠️  WARNING: This will PERMANENTLY DELETE all source code!" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Make sure you have ALREADY:" -ForegroundColor Yellow
    Write-Host "    1. Built your demo APK (see README for instructions)" -ForegroundColor Yellow
    Write-Host "    2. Committed/pushed your full source to a PRIVATE backup" -ForegroundColor Yellow
    Write-Host ""
    $confirm = Read-Host "Type 'YES' to proceed"
    if ($confirm -ne "YES") {
        Write-Host "Aborted." -ForegroundColor Gray
        exit 0
    }
}

Write-Host ""

# ─── 1. Delete src/app (all application logic) ──────────────────────────
$srcApp = Join-Path $Root "src\app"
if (Test-Path $srcApp) {
    Remove-Item -Recurse -Force $srcApp
    Write-Host "✅ Deleted src/app/" -ForegroundColor Green
} else {
    Write-Host "⏭️  src/app/ already removed" -ForegroundColor DarkGray
}

# ─── 2. Delete src/environments (API keys) ──────────────────────────────
$srcEnv = Join-Path $Root "src\environments"
if (Test-Path $srcEnv) {
    Remove-Item -Recurse -Force $srcEnv
    Write-Host "✅ Deleted src/environments/" -ForegroundColor Green
} else {
    Write-Host "⏭️  src/environments/ already removed" -ForegroundColor DarkGray
}

# ─── 3. Delete google-services.json ─────────────────────────────────────
$googleServices = Join-Path $Root "google-services.json"
if (Test-Path $googleServices) {
    Remove-Item -Force $googleServices
    Write-Host "✅ Deleted google-services.json" -ForegroundColor Green
} else {
    Write-Host "⏭️  google-services.json already removed" -ForegroundColor DarkGray
}

# ─── 4. Delete www/ (pre-compiled build output) ─────────────────────────
$www = Join-Path $Root "www"
if (Test-Path $www) {
    Remove-Item -Recurse -Force $www
    Write-Host "✅ Deleted www/" -ForegroundColor Green
} else {
    Write-Host "⏭️  www/ already removed" -ForegroundColor DarkGray
}

# ─── 5. Delete e2e/ (test scaffold) ─────────────────────────────────────
$e2e = Join-Path $Root "e2e"
if (Test-Path $e2e) {
    Remove-Item -Recurse -Force $e2e
    Write-Host "✅ Deleted e2e/" -ForegroundColor Green
} else {
    Write-Host "⏭️  e2e/ already removed" -ForegroundColor DarkGray
}

# ─── 6. Delete misc non-essential files ──────────────────────────────────
$miscFiles = @(
    "karma.conf.js",
    "src\test.ts",
    "src\polyfills.ts",
    "src\zone-flags.ts",
    "src\global.scss",
    "src\main.ts",
    "src\index.html",
    "src\manifest.webmanifest",
    "package-lock.json"
)
foreach ($file in $miscFiles) {
    $path = Join-Path $Root $file
    if (Test-Path $path) {
        Remove-Item -Force $path
        Write-Host "✅ Deleted $file" -ForegroundColor Green
    }
}

# ─── 7. Delete .DS_Store files (macOS artifacts) ────────────────────────
Get-ChildItem -Path $Root -Filter ".DS_Store" -Recurse -Force -ErrorAction SilentlyContinue |
    ForEach-Object {
        Remove-Item -Force $_.FullName
    }
Write-Host "✅ Cleaned up .DS_Store files" -ForegroundColor Green

# ─── 8. Sanitize capacitor.config.json (strip OAuth client ID) ──────────
$capConfig = Join-Path $Root "capacitor.config.json"
if (Test-Path $capConfig) {
    $content = Get-Content $capConfig -Raw
    $content = $content -replace '"serverClientId":\s*"[^"]*"', '"serverClientId": "YOUR_GOOGLE_OAUTH_CLIENT_ID"'
    Set-Content -Path $capConfig -Value $content -NoNewline
    Write-Host "✅ Sanitized capacitor.config.json (replaced serverClientId)" -ForegroundColor Green
}

# ─── 9. Update .gitignore for sales repo ────────────────────────────────
$gitignore = Join-Path $Root ".gitignore"
$gitignoreContent = @"
/android
/node_modules
/.angular
resources/android/**/*
www/
*.apk
"@
Set-Content -Path $gitignore -Value $gitignoreContent
Write-Host "✅ Updated .gitignore" -ForegroundColor Green

# ─── Done ────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "=============================================" -ForegroundColor Green
Write-Host "  ✅ Sanitization complete!" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host ""
Write-Host "What's left in your repo:" -ForegroundColor Cyan
Write-Host "  📄 README.md          (sales page)" -ForegroundColor White
Write-Host "  📄 package.json       (shows dependencies)" -ForegroundColor White
Write-Host "  📄 capacitor.config   (sanitized)" -ForegroundColor White
Write-Host "  📄 ionic.config.json  (framework config)" -ForegroundColor White
Write-Host "  📄 angular.json       (build config)" -ForegroundColor White
Write-Host "  📄 tsconfig*.json     (TypeScript config)" -ForegroundColor White
Write-Host "  🖼️  src/assets/        (images & icons)" -ForegroundColor White
Write-Host "  🖼️  resources/         (app icon & splash)" -ForegroundColor White
Write-Host "  📄 src/theme/          (Ionic theme file)" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Review the repo to make sure nothing sensitive remains" -ForegroundColor Yellow
Write-Host "  2. Upload your demo APK to GitHub Releases" -ForegroundColor Yellow
Write-Host "  3. Push to GitHub:  git add -A && git commit -m 'Sales page' && git push" -ForegroundColor Yellow
Write-Host ""
