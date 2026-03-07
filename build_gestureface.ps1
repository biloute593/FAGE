<#
.SYNOPSIS
    Build GestureFace APK for Android.
.DESCRIPTION
    Generates the Android project files if missing, installs dependencies,
    and compiles GestureFace into a release APK ready to sideload on Android.
.NOTES
    Requires Flutter SDK (>=3.3.0) installed and available in PATH.
#>

$ErrorActionPreference = "Stop"

Write-Host "=== GestureFace Android Build ===" -ForegroundColor Cyan

# Check Flutter is installed
try {
    $flutterVersion = flutter --version 2>&1
    Write-Host "[OK] Flutter found" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Flutter SDK not found. Install it from https://docs.flutter.dev/get-started/install/windows" -ForegroundColor Red
    exit 1
}

# Generate Android project files if missing
if (-not (Test-Path "android")) {
    Write-Host "[...] Generating Android project files..." -ForegroundColor Yellow
    flutter create . --org com.gestureface --platforms android
}

# Install dependencies
Write-Host "[...] Installing dependencies..." -ForegroundColor Yellow
flutter pub get

# Build APK
Write-Host "[...] Building release APK..." -ForegroundColor Yellow
flutter build apk --release

# Copy APK to project root
$apkSource = "build\app\outputs\flutter-apk\app-release.apk"
$apkDest = "GestureFace.apk"

if (Test-Path $apkSource) {
    Copy-Item $apkSource $apkDest -Force
    Write-Host ""
    Write-Host "=== BUILD SUCCESSFUL ===" -ForegroundColor Green
    Write-Host "APK: $((Get-Item $apkDest).FullName)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Pour installer sur Android:" -ForegroundColor Yellow
    Write-Host "  1. Transferez $apkDest sur votre telephone Android (USB, email, etc.)" -ForegroundColor White
    Write-Host "  2. Ouvrez le fichier sur le telephone" -ForegroundColor White
    Write-Host "  3. Autorisez 'Sources inconnues' si demande" -ForegroundColor White
} else {
    Write-Host "[ERROR] APK not found at $apkSource" -ForegroundColor Red
    exit 1
}
