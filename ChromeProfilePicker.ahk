#Requires AutoHotkey v2.0
#SingleInstance Ignore
#Include ChromeProfilePicker.Core.ahk

settings := LoadSettings()

try {
    Hotkey(settings.hotkeyText, (*) => ShowPicker(settings))
} catch Error as err {
    MsgBox("Invalid hotkey in config.ini: " settings.hotkeyText "`n`n" err.Message, "ChromeProfilePicker", "Iconx")
    ExitApp
}
