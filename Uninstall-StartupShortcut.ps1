$ErrorActionPreference = 'Stop'

$startupDir = [Environment]::GetFolderPath('Startup')
$shortcutNames = @('ChromeProfilePicker.lnk', 'Chrome Profile Picker.lnk')
$removedAny = $false

foreach ($shortcutName in $shortcutNames) {
    $shortcutPath = Join-Path $startupDir $shortcutName
    if (Test-Path -LiteralPath $shortcutPath) {
        Remove-Item -LiteralPath $shortcutPath -Force
        Write-Host "Removed startup shortcut: $shortcutPath"
        $removedAny = $true
    }
}

if (-not $removedAny) {
    Write-Host 'No ChromeProfilePicker startup shortcut was found.'
}
