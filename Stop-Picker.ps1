$ErrorActionPreference = 'Stop'

$scriptPath = Join-Path $PSScriptRoot 'ChromeProfilePicker.ahk'
$scriptName = Split-Path $scriptPath -Leaf
$processNames = @('AutoHotkey64.exe', 'AutoHotkey32.exe', 'AutoHotkey.exe')

$processIds = New-Object System.Collections.Generic.HashSet[int]

Get-CimInstance Win32_Process |
    Where-Object {
        $processNames -contains $_.Name -and
        $_.CommandLine -and
        ($_.CommandLine -like "*$scriptName*")
    } |
    ForEach-Object {
        [void]$processIds.Add([int]$_.ProcessId)
    }

Add-Type @'
using System;
using System.Text;
using System.Runtime.InteropServices;
public class ChromeProfilePickerWindowProbe {
  public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
  [DllImport("user32.dll")] public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);
  [DllImport("user32.dll")] public static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint processId);
}
'@ -ErrorAction SilentlyContinue

[ChromeProfilePickerWindowProbe]::EnumWindows({
    param($hWnd, $lParam)

    $titleBuilder = New-Object System.Text.StringBuilder 512
    [void][ChromeProfilePickerWindowProbe]::GetWindowText($hWnd, $titleBuilder, $titleBuilder.Capacity)
    $title = $titleBuilder.ToString()

    if ($title -like "*$scriptName*" -or $title -like '*ChromeProfilePicker*') {
        [uint32]$windowProcessId = 0
        [void][ChromeProfilePickerWindowProbe]::GetWindowThreadProcessId($hWnd, [ref]$windowProcessId)
        $process = Get-Process -Id $windowProcessId -ErrorAction SilentlyContinue
        if ($process -and $processNames -contains "$($process.ProcessName).exe") {
            [void]$processIds.Add([int]$windowProcessId)
        }
    }

    return $true
}, [IntPtr]::Zero) | Out-Null

if ($processIds.Count -eq 0) {
    Write-Host 'ChromeProfilePicker is not running.'
    exit 0
}

foreach ($processId in $processIds) {
    try {
        Stop-Process -Id $processId -Force -ErrorAction Stop
        Write-Host "Stopped ChromeProfilePicker process $processId."
    } catch {
        Write-Warning "Could not stop ChromeProfilePicker process $processId. It may be running elevated. Error: $($_.Exception.Message)"
    }
}
