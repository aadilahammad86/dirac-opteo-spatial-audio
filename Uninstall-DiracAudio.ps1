<#
.SYNOPSIS
    Uninstalls Dirac Opteo & 3D Spatial Audio configurations from Equalizer APO.
#>

[CmdletBinding()]
param()

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Start-Process powershell.exe -Verb RunAs -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"")
    exit 0
}

$ApoConfigDir = "C:\Program Files\EqualizerAPO\config"
$diracTxt = Join-Path $ApoConfigDir "dirac_opteo.txt"
$masterConfig = Join-Path $ApoConfigDir "config.txt"

Write-Host "Reverting Equalizer APO master config..." -ForegroundColor Yellow
if (Test-Path $masterConfig) {
    $content = Get-Content $masterConfig -Raw
    $newContent = $content -replace "Include: dirac_opteo\.txt`r?`n?", ""
    Set-Content -Path $masterConfig -Value $newContent -Force
}

if (Test-Path $diracTxt) {
    Remove-Item -Path $diracTxt -Force
}

Write-Host "Dirac Opteo profile successfully removed." -ForegroundColor Green
pause
