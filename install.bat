@echo off
:: ==============================================================================
:: Dirac Opteo & 3D Spatial Audio 1-Click Installer
:: Requests administrator privileges and launches Setup-DiracAudio.ps1
:: ==============================================================================

net session >nul 2>&1
if %errorLevel% == 0 (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Setup-DiracAudio.ps1"
) else (
    echo Requesting Administrator privileges...
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process powershell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"\"%~dp0Setup-DiracAudio.ps1\"\"' -Verb RunAs"
)
