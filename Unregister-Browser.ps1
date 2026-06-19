$ErrorActionPreference = 'Stop'

$appName = 'ChromeProfilePicker'
$legacyAppName = 'Chrome Profile Picker'
$appId = 'ChromeProfilePicker'
$progId = 'ChromeProfilePicker.Url'

$registeredAppsKey = 'Registry::HKEY_CURRENT_USER\Software\RegisteredApplications'
$clientKey = "Registry::HKEY_CURRENT_USER\Software\Clients\StartMenuInternet\$appId"
$progIdKey = "Registry::HKEY_CURRENT_USER\Software\Classes\$progId"
$chromeHtmlCommandKey = 'Registry::HKEY_CURRENT_USER\Software\Classes\ChromeHTML\shell\open\command'

if (Test-Path -LiteralPath $registeredAppsKey) {
    Remove-ItemProperty -Path $registeredAppsKey -Name $appName -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path $registeredAppsKey -Name $legacyAppName -ErrorAction SilentlyContinue
}

Remove-Item -LiteralPath $clientKey -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath $progIdKey -Recurse -Force -ErrorAction SilentlyContinue

if (Test-Path -LiteralPath $chromeHtmlCommandKey) {
    $chromeHtmlCommand = (Get-Item -LiteralPath $chromeHtmlCommandKey).GetValue('')
    if ($chromeHtmlCommand -match 'ChromeProfilePicker(-Url)?\.ahk') {
        Remove-Item -LiteralPath $chromeHtmlCommandKey -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host 'Removed per-user ChromeHTML fallback.'
    }
}

Write-Host "Unregistered $appName. If it was selected as your default app, choose another default for http and https in Windows Settings."
