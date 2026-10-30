' ==============================================================================
' Dirac Opteo & 3D Spatial Audio - Silent Background Launcher
' Launches Startup-Watcher.ps1 with window style 0 (completely invisible, no console window)
' ==============================================================================

Set WshShell = CreateObject("WScript.Shell")
Set FSO = CreateObject("Scripting.FileSystemObject")

ScriptDir = FSO.GetParentFolderName(WScript.ScriptFullName)
PsScript = ScriptDir & "\Startup-Watcher.ps1"

If FSO.FileExists(PsScript) Then
    Cmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & PsScript & """"
    WshShell.Run Cmd, 0, False
End If
