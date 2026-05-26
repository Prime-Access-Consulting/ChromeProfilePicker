$ErrorActionPreference = 'Stop'

$scriptPath = Join-Path $PSScriptRoot 'ChromeProfilePicker.ahk'
$ahkPath = Join-Path $env:LOCALAPPDATA 'Programs\AutoHotkey\v2\AutoHotkey64.exe'

if (-not (Test-Path -LiteralPath $ahkPath)) {
    $command = Get-Command AutoHotkey64.exe -ErrorAction SilentlyContinue
    if ($command) {
        $ahkPath = $command.Source
    }
}

if (-not (Test-Path -LiteralPath $ahkPath)) {
    throw 'AutoHotkey v2 was not found. Install it with: winget install --exact --id AutoHotkey.AutoHotkey'
}

$startupDir = [Environment]::GetFolderPath('Startup')
$shortcutPath = Join-Path $startupDir 'ChromeProfilePicker.lnk'

$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $ahkPath
$shortcut.Arguments = "`"$scriptPath`""
$shortcut.WorkingDirectory = $PSScriptRoot
$shortcut.IconLocation = "$ahkPath,0"
$shortcut.Description = 'Runs the ChromeProfilePicker AutoHotkey script.'
$shortcut.Save()

Write-Host "Created startup shortcut: $shortcutPath"
