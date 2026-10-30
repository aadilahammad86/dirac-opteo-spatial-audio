<#
.SYNOPSIS
    All-In-One Automated Installer for Dirac Opteo EQ & 3D Spatial Audio Engine.
.DESCRIPTION
    Installs Equalizer APO, HeSuVi, configures Dirac Opteo 7-band acoustic tuning,
    and deploys the Dirac 3D spatial audio convolution impulse response.
#>

[CmdletBinding()]
param()

# --- 1. Require Administrator Privileges ---
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[*] Requesting Administrator privileges..." -ForegroundColor Yellow
    Start-Process powershell.exe -Verb RunAs -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"")
    exit 0
}

Clear-Host
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "   Dirac Opteo & 3D Spatial Audio - All-In-One Automated Installer    " -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$InstallersDir = Join-Path $ScriptRoot "installers"
$ConfigDir = Join-Path $ScriptRoot "config"

$ApoDir = "C:\Program Files\EqualizerAPO"
$ApoConfigDir = Join-Path $ApoDir "config"
$HesuviDir = Join-Path $ApoConfigDir "HeSuVi"

# --- 2. Step 1: Install Equalizer APO ---
Write-Host "[1/5] Checking Equalizer APO installation..." -ForegroundColor Green
if (-not (Test-Path $ApoDir)) {
    $apoInstaller = Join-Path $InstallersDir "EqualizerAPO-x64-1.4.2.exe"
    if (Test-Path $apoInstaller) {
        Write-Host "      Launching Equalizer APO installer..." -ForegroundColor White
        Write-Host "      NOTE: Select your audio playback device(s) when the Configurator appears." -ForegroundColor Yellow
        $proc = Start-Process -FilePath $apoInstaller -Wait -PassThru
    } else {
        Write-Error "Installer not found at $apoInstaller"
        exit 1
    }
} else {
    Write-Host "      Equalizer APO is already installed." -ForegroundColor Gray
}

# --- 3. Step 2: Install HeSuVi ---
Write-Host "[2/5] Checking HeSuVi 3D Virtualization engine..." -ForegroundColor Green
if (-not (Test-Path $HesuviDir)) {
    $hesuviInstaller = Join-Path $InstallersDir "HeSuVi_2.0.0.1.exe"
    if (Test-Path $hesuviInstaller) {
        Write-Host "      Launching HeSuVi installer..." -ForegroundColor White
        $proc = Start-Process -FilePath $hesuviInstaller -Wait -PassThru
    } else {
        Write-Error "Installer not found at $hesuviInstaller"
        exit 1
    }
} else {
    Write-Host "      HeSuVi is already installed." -ForegroundColor Gray
}

# Stop HeSuVi if running to allow file updates
Get-Process -Name "HeSuVi" -ErrorAction SilentlyContinue | Stop-Process -Force

# --- 4. Step 3: Deploy Dirac Opteo EQ Profile ---
Write-Host "[3/5] Deploying Dirac Opteo 7-Band Acoustic Tuning Profile..." -ForegroundColor Green
$targetDiracTxt = Join-Path $ApoConfigDir "dirac_opteo.txt"
Copy-Item -Path (Join-Path $ConfigDir "dirac_opteo.txt") -Destination $targetDiracTxt -Force
Write-Host "      Installed to: $targetDiracTxt" -ForegroundColor White

# --- 5. Step 4: Deploy Dirac 3D Spatial Audio Profiles (48kHz & 44.1kHz) ---
Write-Host "[4/5] Deploying Dirac 3D Spatial Convolution Impulse Profiles..." -ForegroundColor Green
$hrirDir = Join-Path $HesuviDir "hrir"
$hrir44Dir = Join-Path $hrirDir "44"

if (Test-Path $hrirDir) {
    Copy-Item -Path (Join-Path $ConfigDir "dirac_spatial.wav") -Destination (Join-Path $hrirDir "dirac_spatial.wav") -Force
    if (Test-Path $hrir44Dir) {
        Copy-Item -Path (Join-Path $ConfigDir "dirac_spatial_44.wav") -Destination (Join-Path $hrir44Dir "dirac_spatial.wav") -Force
    }

    # Register in HeSuVi info.csv
    $infoCsv = Join-Path $hrirDir "info.csv"
    if (Test-Path $infoCsv) {
        $infoContent = Get-Content $infoCsv -Raw
        if ($infoContent -notmatch "dirac_spatial") {
            "dirac_spatial;Dirac 3D Spatial Audio (Binaural 7.1 Virtualization)`n" + $infoContent | Set-Content $infoCsv -NoNewline
        }
    }

    # Set default convolution to dirac_spatial
    Set-Content -Path (Join-Path $HesuviDir "conv.txt") -Value "Convolution: hrir\dirac_spatial.wav"
    Set-Content -Path (Join-Path $HesuviDir "conv44.txt") -Value "Convolution: hrir\44\dirac_spatial.wav"
    Write-Host "      Deployed 48kHz and 44.1kHz Dirac 3D spatial profiles." -ForegroundColor White
}

# --- 6. Step 5: Configure Master Equalizer APO Config ---
Write-Host "[5/6] Configuring Equalizer APO Master Routing Pipeline..." -ForegroundColor Green
$masterConfig = Join-Path $ApoConfigDir "config.txt"
$configBody = @"
# ==============================================================================
# Equalizer APO Master Configuration
# 1. 3D Spatial Audio Virtualizer (HeSuVi HRIR Engine)
# 2. Dirac Opteo Acoustic Enhancement Profile
# ==============================================================================

Include: HeSuVi\hesuvi.txt
Include: dirac_opteo.txt
"@
Set-Content -Path $masterConfig -Value $configBody -Force
Write-Host "      Master configuration updated successfully." -ForegroundColor White

# --- 7. Step 6: Enable Automatic Startup on Windows ---
Write-Host "[6/6] Configuring Windows Startup Integration..." -ForegroundColor Green
$enableStartup = Join-Path $ScriptRoot "Enable-Startup.ps1"
if (Test-Path $enableStartup) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $enableStartup
}

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "                   INSTALLATION COMPLETE!                             " -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "1. Put on your earphones (wired 3.5mm, USB DAC, or Bluetooth)." -ForegroundColor White
Write-Host "2. Windows Sonic for Headphones should be set to OFF in Windows Sound." -ForegroundColor White
Write-Host "3. Open HeSuVi from Start Menu to customize or click '7.1 Test'." -ForegroundColor White
Write-Host ""
pause
