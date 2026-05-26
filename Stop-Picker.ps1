$ErrorActionPreference = 'Stop'

$scriptPath = Join-Path $PSScriptRoot 'ChromeProfilePicker.ahk'
$scriptName = Split-Path $scriptPath -Leaf
$processNames = @('AutoHotkey64.exe', 'AutoHotkey32.exe', 'AutoHotkey.exe')

$processes = Get-CimInstance Win32_Process |
    Where-Object {
        $processNames -contains $_.Name -and
        $_.CommandLine -and
        ($_.CommandLine -like "*$scriptName*")
    }

if (-not $processes) {
    Write-Host 'ChromeProfilePicker is not running.'
    exit 0
}

foreach ($process in $processes) {
    Stop-Process -Id $process.ProcessId -Force
    Write-Host "Stopped ChromeProfilePicker process $($process.ProcessId)."
}
