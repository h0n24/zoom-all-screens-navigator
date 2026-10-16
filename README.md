# Zoom All Screens Navigator

Simple keyboard and mouse navigation for teachers using Zoom's **All screens** view on Windows. No calibration. Students do not need to install anything.

## Get started

1. Open the [latest release](https://github.com/h0n24/zoom-all-screens-navigator/releases/latest) and download **`ZoomNavigator-VERSION-windows-x64.exe`**.
2. Double-click the downloaded file. No installation or AutoHotkey setup is needed.
3. Open Zoom's **All screens** view and use the controls below.

Windows x64 only; AutoHotkey and this helper do not run natively on macOS. The executable is currently unsigned.

For the editable script instead, install [AutoHotkey v2](https://www.autohotkey.com/), download **Source code (zip)**, extract the entire folder, and run `ZoomNavigator.ahk` with its `lib` folder alongside it.

When upgrading from an older version, quit that helper through its tray icon first. You do not need to restart Zoom.

| Control | Action |
| --- | --- |
| **← / →** | Previous / next page, including with chat or settings open. |
| **Double-click a shared screen** | Activate its visible blue expand button; double-click again to return to the overview. |
| **F6** | Pause or resume the helper while Zoom is active. |
| **Tray icon → Quit Zoom Navigator** | Stop the helper without closing Zoom. |

Arrow keys keep their normal function while typing in chat. After editing, click the overview to resume paging. Release each arrow key before pressing it again. The first/last page does not wrap.

Double-clicks in the All screens rendering area no longer trigger Zoom's whole-window fullscreen. The helper toggles the selected shared screen only when it can recognize its blue expand/collapse button. Without that button, the second click is swallowed. Pointer movements during and between clicks are tolerated (48 pixels at 100% scaling, adjusted for DPI). Single clicks and dragging are forwarded; chat, side panels, the title bar and other applications keep their normal mouse behaviour. Pausing the helper restores Zoom's original behaviour.

## If nothing happens

- Make sure the helper is running and not paused; check its tray icon.
- Activate the All screens window. Both paging arrows must be visible and unobscured.
- Click away from the chat editor or another control that uses arrow keys.
- For double-click, select a shared-screen tile so its blue expand button is visible.
- If Zoom changes its interface and an icon is not recognized, use the visible Zoom buttons directly. No calibration is required or provided.

Tested live with Zoom **7.1.9.48550**, AutoHotkey **2.0.30 x64**, and Windows at **100% display scaling**. Other themes, versions and mixed-DPI monitors need further live testing. The helper does not increase the number of screens per page or enable All screens on accounts where Zoom does not offer it.

## Updates

The helper checks for updates shortly after launch and once a day while running. A new version produces a notification and an **Update available** download entry in the tray menu. It does not download or install code automatically.

Right-click the tray icon to **Check for updates** manually or turn **Automatic update checks** off. That preference is remembered. If offline, automatic checks fail quietly; a manual check reports the problem.

To update, open the download entry, download the new `.exe`, quit the old helper through its tray icon, and run the new file. Zoom can stay open. Script users can download **Source code (zip)** instead. Versions before 0.6.2 need one manual upgrade to gain update notifications.

## Verify a download

Each binary release includes `SHA256SUMS.txt`. In PowerShell, calculate the downloaded file's SHA-256 (replace the version with the one downloaded):

```powershell
Get-FileHash .\ZoomNavigator-0.6.4-windows-x64.exe -Algorithm SHA256
```

Compare the entire hash with the matching filename in `SHA256SUMS.txt`; letter case does not matter. SHA-256 detects changed or incomplete files more reliably than CRC. A matching checksum is not a digital signature or proof of publisher identity.

## Privacy

The helper saves no screenshots. Update checks request a small version file from GitHub over HTTPS; GitHub receives the normal connection information and the application version in the User-Agent header. No meeting content, chat text, screenshots or personal identifiers are sent. You can disable automatic checks in the tray menu. It processes small icon regions in memory when you press an arrow or double-click. It reads window geometry and keyboard-focus metadata, not chat text. Optional local debug logs contain geometry and detection results and are excluded from Git.

## Project

- [Testing and compatibility](TESTING.md)
- [Development guide](DEVELOPMENT.md)
- [Changes](CHANGELOG.md)

There is one source entry point: `ZoomNavigator.ahk`. Files in `lib` are dependencies; files in `tests` are developer checks. Historical versions are kept in Git tags instead of duplicate launchers. Windows executables are built with the official AutoHotkey Ahk2Exe compiler and attached to releases.

The executable embeds AutoHotkey 2.0.30. See [runtime licence notices](AutoHotkey-LICENSE.txt); the corresponding AutoHotkey source archive is included with binary release downloads. This project's tagged source is also available on every release page.

This is an independent helper, not an official Zoom product.
