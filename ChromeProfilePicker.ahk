#Requires AutoHotkey v2.0
#SingleInstance Force

configPath := A_ScriptDir "\config.ini"
shortcutDir := ResolveConfiguredPath(IniRead(configPath, "Settings", "ShortcutDir", "Profiles"))
hotkeyText := IniRead(configPath, "Settings", "Hotkey", "^+!p")
dialogWidth := Integer(IniRead(configPath, "Settings", "DialogWidth", "340"))
maxVisibleItems := Integer(IniRead(configPath, "Settings", "MaxVisibleItems", "10"))
pendingUrl := A_Args.Length >= 1 ? A_Args[1] : ""

DirCreate(shortcutDir)

try {
    Hotkey(hotkeyText, (*) => ShowPicker())
} catch Error as err {
    MsgBox("Invalid hotkey in config.ini: " hotkeyText "`n`n" err.Message, "ChromeProfilePicker", "Iconx")
    ExitApp
}

if pendingUrl != "" {
    ShowPicker(pendingUrl)
}

ShowPicker(targetUrl := "") {
    global shortcutDir, dialogWidth, maxVisibleItems

    if WinExist("ChromeProfilePicker ahk_class AutoHotkeyGUI") {
        WinActivate
        return
    }

    shortcuts := LoadShortcuts()
    if shortcuts.Length = 0 {
        MsgBox("Put your Chrome profile .lnk shortcuts in:`n" shortcutDir, "ChromeProfilePicker", "Icon!")
        Run(shortcutDir)
        return
    }

    names := []
    for shortcut in shortcuts {
        names.Push(shortcut.name)
    }

    visibleRows := Min(shortcuts.Length, maxVisibleItems)
    pickerTitle := targetUrl = "" ? "ChromeProfilePicker" : "ChromeProfilePicker - Open Link"
    picker := Gui("+AlwaysOnTop +ToolWindow", pickerTitle)
    picker.MarginX := 12
    picker.MarginY := 12

    list := picker.AddListBox("w" dialogWidth " r" visibleRows, names)
    list.Choose(1)

    launch := (*) => LaunchSelected(picker, list, shortcuts, targetUrl)
    list.OnEvent("DoubleClick", launch)
    picker.AddButton("Default Hidden w0 h0", "Launch").OnEvent("Click", launch)
    picker.OnEvent("Escape", (*) => picker.Destroy())
    picker.OnEvent("Close", (*) => picker.Destroy())

    picker.Show("AutoSize Center")
    list.Focus()
}

LoadShortcuts() {
    global shortcutDir

    shortcuts := []
    Loop Files, shortcutDir "\*.lnk", "F" {
        displayName := RegExReplace(A_LoopFileName, "\.lnk$", "")
        shortcuts.Push({ name: displayName, path: A_LoopFileFullPath })
    }

    return shortcuts
}

LaunchSelected(picker, list, shortcuts, targetUrl := "") {
    selectedIndex := list.Value
    if !selectedIndex {
        return
    }

    shortcutPath := shortcuts[selectedIndex].path
    picker.Destroy()
    LaunchShortcut(shortcutPath, targetUrl)
}

LaunchShortcut(shortcutPath, targetUrl := "") {
    if targetUrl = "" {
        Run(shortcutPath)
        return
    }

    shortcut := ComObject("WScript.Shell").CreateShortcut(shortcutPath)
    targetPath := shortcut.TargetPath
    arguments := shortcut.Arguments
    workingDir := shortcut.WorkingDirectory

    if targetPath = "" {
        Run(QuoteArg(shortcutPath) " " QuoteArg(targetUrl))
        return
    }

    commandLine := QuoteArg(targetPath)
    if arguments != "" {
        commandLine .= " " arguments
    }
    commandLine .= " " QuoteArg(targetUrl)

    Run(commandLine, workingDir)
}

QuoteArg(value) {
    quote := Chr(34)
    return quote StrReplace(value, quote, "\" quote) quote
}

ResolveConfiguredPath(path) {
    path := Trim(path)
    if path = "" {
        return A_ScriptDir "\Profiles"
    }
    if RegExMatch(path, "i)^[a-z]:[\\/]|^\\\\") {
        return path
    }
    return A_ScriptDir "\" path
}
