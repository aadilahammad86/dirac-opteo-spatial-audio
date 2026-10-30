# ==============================================================================
# Dirac Opteo & 3D Spatial Audio - Startup Watcher
# Runs silently on Windows logon to verify audio pipeline & launch HeSuVi minimized
# ==============================================================================

param(
    [switch]$NoDelay
)

# Allow Windows Audio Service (audiosrv) to initialize after logon
if (-not $NoDelay) {
    Start-Sleep -Seconds 4
}

$ApoDir = "C:\Program Files\EqualizerAPO"
$ApoConfigDir = Join-Path $ApoDir "config"
$MasterConfig = Join-Path $ApoConfigDir "config.txt"
$DiracTxt = Join-Path $ApoConfigDir "dirac_opteo.txt"
$HesuviExe = Join-Path $ApoConfigDir "HeSuVi\HeSuVi.exe"

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoConfigDir = Join-Path $ScriptRoot "config"

# --- 1. Verify and Restore Dirac Opteo EQ File if missing ---
if (Test-Path $ApoConfigDir) {
    if (-not (Test-Path $DiracTxt)) {
        $sourceDirac = Join-Path $RepoConfigDir "dirac_opteo.txt"
        if (Test-Path $sourceDirac) {
            Copy-Item -Path $sourceDirac -Destination $DiracTxt -Force
        }
    }

    # --- 2. Verify Master config.txt has both pipelines enabled ---
    $needsUpdate = $false
    if (Test-Path $MasterConfig) {
        $content = Get-Content $MasterConfig -Raw
        if ($content -notmatch "HeSuVi\\hesuvi\.txt" -or $content -notmatch "dirac_opteo\.txt") {
            $needsUpdate = $true
        }
    } else {
        $needsUpdate = $true
    }

    if ($needsUpdate) {
        $configBody = @"
# ==============================================================================
# Equalizer APO Master Configuration
# 1. 3D Spatial Audio Virtualizer (HeSuVi HRIR Engine)
# 2. Dirac Opteo Acoustic Enhancement Profile
# ==============================================================================

Include: HeSuVi\hesuvi.txt
Include: dirac_opteo.txt
"@
        Set-Content -Path $MasterConfig -Value $configBody -Force
    }
}

# --- 3. Launch HeSuVi into System Tray / Minimized (if not already running) ---
if (Test-Path $HesuviExe) {
    $existing = Get-Process -Name "HeSuVi" -ErrorAction SilentlyContinue
    if (-not $existing) {
        Start-Process -FilePath $HesuviExe -WindowStyle Minimized
    }
}
