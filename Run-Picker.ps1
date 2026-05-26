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

Start-Process -FilePath $ahkPath -ArgumentList "`"$scriptPath`"" -WorkingDirectory $PSScriptRoot -WindowStyle Hidden
