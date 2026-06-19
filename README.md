# ChromeProfilePicker

ChromeProfilePicker is a small Windows utility for launching Chrome with the profile you choose.

It supports two workflows:

- Press `Ctrl+Shift+Alt+P`, choose a Chrome profile shortcut, and launch Chrome.
- Register it as an `http`/`https` browser handler, then choose the Chrome profile before a link opens.

The app uses your existing Chrome `.lnk` shortcuts as the source of truth. If a shortcut already opens the right Chrome profile, this picker can launch that same shortcut or append a URL to it.

The hotkey and URL workflows use separate AutoHotkey entry points. `ChromeProfilePicker.ahk` stays resident for the global hotkey. `ChromeProfilePicker-Url.ahk` is used for browser links and exits after the link picker closes. Both scripts share picker and launch behavior through `ChromeProfilePicker.Core.ahk`.

## Requirements

- Windows
- Google Chrome
- AutoHotkey v2
- One `.lnk` shortcut per Chrome profile

Install AutoHotkey v2 with winget:

```powershell
winget install --exact --id AutoHotkey.AutoHotkey
```

## Setup

1. Put your Chrome profile `.lnk` files in the local `Profiles` folder.
2. Run `.\Run-Picker.ps1` to start the hotkey for the current Windows session.
3. Press `Ctrl+Shift+Alt+P`.
4. Use arrow keys and Enter to choose a profile.

To stop the running picker:

```powershell
.\Stop-Picker.ps1
```

To start the picker automatically when you sign in:

```powershell
.\Install-StartupShortcut.ps1
```

To remove the startup shortcut:

```powershell
.\Uninstall-StartupShortcut.ps1
```

## Use for Links

Run:

```powershell
.\Register-Browser.ps1
```

This registers `ChromeProfilePicker` as a browser candidate for `http` and `https`.

Windows still requires a manual default-app selection. After registration, open Windows Default apps and set `ChromeProfilePicker` for both `HTTP` and `HTTPS`.

The registration script also adds a per-user `ChromeHTML` fallback. This covers Windows shell paths such as Win+R with `www.example.com`, which can bypass the normal `http`/`https` default-app handler.

When Windows opens this app with a URL, the picker resolves the selected `.lnk` shortcut, keeps its Chrome profile arguments, and appends the URL.

If you update from an older version, rerun `.\Register-Browser.ps1` so URL handlers point to `ChromeProfilePicker-Url.ahk`.

To remove the browser registration:

```powershell
.\Unregister-Browser.ps1
```

If it was selected as your default browser handler, choose another default app for `HTTP` and `HTTPS` in Windows Settings.

## Configuration

Edit `config.ini`.

| Setting | Default | Description |
| --- | --- | --- |
| `Hotkey` | `^+!p` | AutoHotkey syntax for `Ctrl+Shift+Alt+P`. |
| `ShortcutDir` | `Profiles` | Folder containing Chrome profile `.lnk` files. Relative paths resolve from this project folder. |
| `DialogWidth` | `340` | Picker width in pixels. |
| `MaxVisibleItems` | `10` | Maximum visible rows before the list scrolls. |

## Shortcut Notes

Each `.lnk` file should target Chrome and include the profile argument Chrome uses, for example:

```text
chrome.exe --profile-directory="Profile 1"
```

The `Profiles` folder stores shortcuts to Chrome profiles. It is not Chrome's internal profile data directory.

The picker displays each shortcut by filename without the `.lnk` extension.

## Privacy

The `Profiles/*.lnk` files are ignored by git because they can contain personal paths, profile names, and local machine details.

## Troubleshooting

If the picker opens an empty folder, add at least one `.lnk` file to `Profiles`.

If the hotkey does nothing, run `.\Run-Picker.ps1` again and confirm AutoHotkey v2 is installed.

If Windows will not let you rename or delete the project folder, run `.\Stop-Picker.ps1` first.

If `.\Stop-Picker.ps1` warns that the picker may be running elevated, stop the listed AutoHotkey process from an elevated PowerShell or Task Manager, or reboot.

If you rename or move the project folder, run `.\Install-StartupShortcut.ps1` again from the new location. If you use ChromeProfilePicker for links, run `.\Register-Browser.ps1` again too.

If `ChromeProfilePicker` does not appear as a browser option, run `.\Register-Browser.ps1` again, then reopen Windows Default apps.

If links do nothing and AutoHotkey eventually says it could not close the previous instance, update to the current split-handler version, rerun `.\Register-Browser.ps1`, then clear any old elevated resident picker process or reboot.

If links open in the wrong profile, inspect the selected `.lnk` file and confirm it launches the intended Chrome profile directly.

## License

MIT
