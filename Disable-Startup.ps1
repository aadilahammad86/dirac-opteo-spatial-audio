<#
.SYNOPSIS
    Disables automatic startup for Dirac Opteo & 3D Spatial Audio on Windows.
.DESCRIPTION
    Removes the startup shortcut and scheduled task if present.
#>

[CmdletBinding()]
param()

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "  Dirac Opteo & 3D Spatial Audio - Disable Windows Startup            " -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Remove Startup Folder Shortcut
$startupDir = [Environment]::GetFolderPath('Startup')
$shortcutPath = Join-Path $startupDir "DiracAudio-Startup.lnk"

if (Test-Path $shortcutPath) {
    Remove-Item -Path $shortcutPath -Force
    Write-Host "[1/2] Removed startup shortcut from Windows Startup folder." -ForegroundColor Green
} else {
    Write-Host "[1/2] No startup shortcut found in Windows Startup folder." -ForegroundColor Gray
}

# 2. Remove Scheduled Task (if exists)
$taskName = "DiracAudio-Startup"
$existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
if ($existingTask) {
    try {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false | Out-Null
        Write-Host "[2/2] Removed scheduled task: $taskName." -ForegroundColor Green
    } catch {
        Write-Warning "Could not remove scheduled task (run as Administrator if needed): $_"
    }
} else {
    Write-Host "[2/2] No scheduled task found." -ForegroundColor Gray
}

Write-Host ""
Write-Host "Automatic startup has been disabled." -ForegroundColor Green
Write-Host ""
