#Requires AutoHotkey v2.0
#SingleInstance Off
#Include ChromeProfilePicker.Core.ahk

Persistent()

settings := LoadSettings()
targetUrl := A_Args.Length >= 1 ? A_Args[1] : ""
ShowPicker(settings, targetUrl, true)
