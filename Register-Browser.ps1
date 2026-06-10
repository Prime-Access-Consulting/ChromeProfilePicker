param(
    [switch]$NoSettings
)

$ErrorActionPreference = 'Stop'

$appName = 'ChromeProfilePicker'
$legacyAppName = 'Chrome Profile Picker'
$appId = 'ChromeProfilePicker'
$progId = 'ChromeProfilePicker.Url'
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

if (-not (Test-Path -LiteralPath $scriptPath)) {
    throw "Picker script was not found: $scriptPath"
}

function Ensure-Key {
    param([Parameter(Mandatory)][string]$Path)
    New-Item -Path $Path -Force | Out-Null
}

function Set-DefaultValue {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Value
    )
    Ensure-Key -Path $Path
    $subKey = $Path -replace '^Registry::HKEY_CURRENT_USER\\', ''
    $key = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey($subKey, $true)
    try {
        $key.SetValue('', $Value, [Microsoft.Win32.RegistryValueKind]::String)
    } finally {
        $key.Dispose()
    }
}

$appCommand = "`"$ahkPath`" `"$scriptPath`""
$urlCommand = "`"$ahkPath`" `"$scriptPath`" `"%1`""
$icon = "$ahkPath,0"

$registeredAppsKey = 'Registry::HKEY_CURRENT_USER\Software\RegisteredApplications'
$clientKey = "Registry::HKEY_CURRENT_USER\Software\Clients\StartMenuInternet\$appId"
$capabilitiesKey = "$clientKey\Capabilities"
$urlAssociationsKey = "$capabilitiesKey\URLAssociations"
$startMenuKey = "$capabilitiesKey\Startmenu"
$progIdKey = "Registry::HKEY_CURRENT_USER\Software\Classes\$progId"
$chromeHtmlCommandKey = 'Registry::HKEY_CURRENT_USER\Software\Classes\ChromeHTML\shell\open\command'

Ensure-Key -Path $registeredAppsKey
Remove-ItemProperty -Path $registeredAppsKey -Name $legacyAppName -ErrorAction SilentlyContinue
New-ItemProperty -Path $registeredAppsKey -Name $appName -Value "Software\Clients\StartMenuInternet\$appId\Capabilities" -PropertyType String -Force | Out-Null

Set-DefaultValue -Path $clientKey -Value $appName
Set-DefaultValue -Path "$clientKey\DefaultIcon" -Value $icon
Set-DefaultValue -Path "$clientKey\shell\open\command" -Value $appCommand

Ensure-Key -Path $capabilitiesKey
New-ItemProperty -Path $capabilitiesKey -Name 'ApplicationName' -Value $appName -PropertyType String -Force | Out-Null
New-ItemProperty -Path $capabilitiesKey -Name 'ApplicationDescription' -Value 'Choose a Chrome profile before opening web links.' -PropertyType String -Force | Out-Null
New-ItemProperty -Path $capabilitiesKey -Name 'ApplicationIcon' -Value $icon -PropertyType String -Force | Out-Null

Ensure-Key -Path $urlAssociationsKey
New-ItemProperty -Path $urlAssociationsKey -Name 'http' -Value $progId -PropertyType String -Force | Out-Null
New-ItemProperty -Path $urlAssociationsKey -Name 'https' -Value $progId -PropertyType String -Force | Out-Null

Ensure-Key -Path $startMenuKey
New-ItemProperty -Path $startMenuKey -Name 'StartMenuInternet' -Value $appId -PropertyType String -Force | Out-Null

Set-DefaultValue -Path $progIdKey -Value "$appName URL"
New-ItemProperty -Path $progIdKey -Name 'URL Protocol' -Value '' -PropertyType String -Force | Out-Null
Set-DefaultValue -Path "$progIdKey\DefaultIcon" -Value $icon
Set-DefaultValue -Path "$progIdKey\shell\open\command" -Value $urlCommand

# Some Windows shell paths, including Win+R with scheme-less URLs like
# www.example.com, resolve through ChromeHTML instead of the http/https
# UserChoice handler. A per-user ChromeHTML command keeps those paths routed
# through the picker without changing machine-wide Chrome registration.
Set-DefaultValue -Path $chromeHtmlCommandKey -Value $urlCommand

Write-Host "Registered $appName as an http/https browser candidate for this Windows user."
Write-Host 'Registered per-user ChromeHTML fallback for scheme-less Windows shell URLs.'

if (-not $NoSettings) {
    Start-Process 'ms-settings:defaultapps'
    Write-Host 'Opened Windows Default apps. Set http and https to ChromeProfilePicker.'
}
