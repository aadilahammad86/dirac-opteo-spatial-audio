<#
.SYNOPSIS
    Enables automatic silent startup for Dirac Opteo & 3D Spatial Audio on Windows logon.
.DESCRIPTION
    Creates a silent startup shortcut in the user's Startup folder and registers
    a Windows Scheduled Task for maximum reliability across reboots.
#>

[CmdletBinding()]
param()

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$LauncherVbs = Join-Path $ScriptRoot "Startup-Launcher.vbs"
$WatcherPs1 = Join-Path $ScriptRoot "Startup-Watcher.ps1"

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "  Dirac Opteo & 3D Spatial Audio - Enable Windows Startup Integration " -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $LauncherVbs) -or -not (Test-Path $WatcherPs1)) {
    Write-Error "Required startup scripts (Startup-Launcher.vbs / Startup-Watcher.ps1) are missing in $ScriptRoot."
    exit 1
}

# --- 1. User Startup Folder Integration (No Admin / UAC Required) ---
Write-Host "[1/2] Creating silent startup shortcut in Windows Startup folder..." -ForegroundColor Green
$startupDir = [Environment]::GetFolderPath('Startup')
$shortcutPath = Join-Path $startupDir "DiracAudio-Startup.lnk"

try {
    $wsh = New-Object -ComObject WScript.Shell
    $shortcut = $wsh.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = "wscript.exe"
    $shortcut.Arguments = "`"$LauncherVbs`""
    $shortcut.WorkingDirectory = $ScriptRoot
    $shortcut.Description = "Dirac Opteo & 3D Spatial Audio Background Watcher"
    $shortcut.WindowStyle = 7 # Minimized
    $shortcut.Save()
    Write-Host "      Created: $shortcutPath" -ForegroundColor White
} catch {
    Write-Warning "Failed to create startup shortcut: $_"
}

# --- 2. Scheduled Task Integration (If Running as Administrator) ---
Write-Host "[2/2] Checking Windows Task Scheduler integration..." -ForegroundColor Green
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$taskName = "DiracAudio-Startup"

if ($isAdmin) {
    try {
        $action = New-ScheduledTaskAction -Execute "wscript.exe" -Argument "`"$LauncherVbs`"" -WorkingDirectory $ScriptRoot
        $trigger = New-ScheduledTaskTrigger -AtLogOn
        $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest
        $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
        $task = New-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -Settings $settings

        Register-ScheduledTask -TaskName $taskName -InputObject $task -Force | Out-Null
        Write-Host "      Registered Scheduled Task: $taskName (Runs with Highest Privileges)" -ForegroundColor White
    } catch {
        Write-Warning "Could not register scheduled task: $_"
    }
} else {
    Write-Host "      User shortcut active. (For elevated Scheduled Task, run this script as Administrator)." -ForegroundColor Gray
}

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "  SUCCESS! Dirac Opteo & 3D Spatial Audio will start with Windows.    " -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "On every boot/login, the system will silently:" -ForegroundColor White
Write-Host "  * Verify Equalizer APO has Dirac Opteo and HeSuVi linked." -ForegroundColor White
Write-Host "  * Launch HeSuVi minimized into the system tray." -ForegroundColor White
Write-Host ""
