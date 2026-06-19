LoadSettings() {
    configPath := A_ScriptDir "\config.ini"
    shortcutDir := ResolveConfiguredPath(IniRead(configPath, "Settings", "ShortcutDir", "Profiles"))

    DirCreate(shortcutDir)

    return {
        shortcutDir: shortcutDir,
        hotkeyText: IniRead(configPath, "Settings", "Hotkey", "^+!p"),
        dialogWidth: Integer(IniRead(configPath, "Settings", "DialogWidth", "340")),
        maxVisibleItems: Integer(IniRead(configPath, "Settings", "MaxVisibleItems", "10"))
    }
}

ShowPicker(settings, targetUrl := "", exitOnClose := false) {
    if targetUrl = "" && WinExist("ChromeProfilePicker ahk_class AutoHotkeyGUI") {
        WinActivate
        return
    }

    shortcuts := LoadShortcuts(settings.shortcutDir)
    if shortcuts.Length = 0 {
        MsgBox("Put your Chrome profile .lnk shortcuts in:`n" settings.shortcutDir, "ChromeProfilePicker", "Icon!")
        Run(settings.shortcutDir)
        FinishPicker(exitOnClose)
        return
    }

    names := []
    for shortcut in shortcuts {
        names.Push(shortcut.name)
    }

    visibleRows := Min(shortcuts.Length, settings.maxVisibleItems)
    pickerTitle := targetUrl = "" ? "ChromeProfilePicker" : "ChromeProfilePicker - Open Link"
    picker := Gui("+AlwaysOnTop +ToolWindow", pickerTitle)
    picker.MarginX := 12
    picker.MarginY := 12

    list := picker.AddListBox("w" settings.dialogWidth " r" visibleRows, names)
    list.Choose(1)

    launch := (*) => LaunchSelected(picker, list, shortcuts, targetUrl, exitOnClose)
    close := (*) => ClosePicker(picker, exitOnClose)
    list.OnEvent("DoubleClick", launch)
    picker.AddButton("Default Hidden w0 h0", "Launch").OnEvent("Click", launch)
    picker.OnEvent("Escape", close)
    picker.OnEvent("Close", close)

    picker.Show("AutoSize Center")
    list.Focus()
}

LoadShortcuts(shortcutDir) {
    shortcuts := []
    Loop Files, shortcutDir "\*.lnk", "F" {
        displayName := RegExReplace(A_LoopFileName, "\.lnk$", "")
        shortcuts.Push({ name: displayName, path: A_LoopFileFullPath })
    }

    return shortcuts
}

LaunchSelected(picker, list, shortcuts, targetUrl := "", exitOnClose := false) {
    selectedIndex := list.Value
    if !selectedIndex {
        return
    }

    shortcutPath := shortcuts[selectedIndex].path
    picker.Destroy()
    LaunchShortcut(shortcutPath, targetUrl)
    FinishPicker(exitOnClose)
}

ClosePicker(picker, exitOnClose := false) {
    picker.Destroy()
    FinishPicker(exitOnClose)
}

FinishPicker(exitOnClose := false) {
    if exitOnClose {
        ExitApp
    }
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
