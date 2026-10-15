# Zoom All Screens Navigator

Simple keyboard and mouse navigation for teachers using Zoom's **All screens** view on Windows. No calibration. Students do not need to install anything.

## Get started

1. Install [AutoHotkey v2](https://www.autohotkey.com/).
2. Download this repository using **Code → Download ZIP**, then extract the entire folder.
3. Double-click **`ZoomNavigator.ahk`**. Keep its `lib` folder alongside it.
4. Open Zoom's **All screens** view and use the controls below.

When upgrading from an older version, quit that helper through its tray icon first. You do not need to restart Zoom.

| Control | Action |
| --- | --- |
| **← / →** | Previous / next page, including with chat or settings open. |
| **Double-click a shared screen** | Activate its visible blue expand button; double-click again to return to the overview. |
| **F6** | Pause or resume the helper while Zoom is active. |
| **Tray icon → Quit Zoom Navigator** | Stop the helper without closing Zoom. |

Arrow keys keep their normal function while typing in chat. After editing, click the overview to resume paging. Release each arrow key before pressing it again. The first/last page does not wrap.

Double-clicks in the All screens rendering area no longer trigger Zoom's whole-window fullscreen. The helper toggles the selected shared screen only when it can recognize its blue expand/collapse button. Without that button, the second click is swallowed. Small pointer movements between clicks are tolerated (12 pixels at 100% scaling, adjusted for DPI). Single clicks and dragging are forwarded; chat, side panels, the title bar and other applications keep their normal mouse behaviour. Pausing the helper restores Zoom's original behaviour.

## If nothing happens

- Make sure the helper is running and not paused; check its tray icon.
- Activate the All screens window. Both paging arrows must be visible and unobscured.
- Click away from the chat editor or another control that uses arrow keys.
- For double-click, select a shared-screen tile so its blue expand button is visible.
- If Zoom changes its interface and an icon is not recognized, use the visible Zoom buttons directly. No calibration is required or provided.

Tested live with Zoom **7.1.9.48550**, AutoHotkey **2.0.30 x64**, and Windows at **100% display scaling**. Other themes, versions and mixed-DPI monitors need further live testing. The helper does not increase the number of screens per page or enable All screens on accounts where Zoom does not offer it.

## Privacy

The helper makes no network requests and saves no screenshots. It processes small icon regions in memory when you press an arrow or double-click. It reads window geometry and keyboard-focus metadata, not chat text. Optional local debug logs contain geometry and detection results and are excluded from Git.

## Project

- [Testing and compatibility](TESTING.md)
- [Development guide](DEVELOPMENT.md)
- [Changes](CHANGELOG.md)

There is one application entry point: `ZoomNavigator.ahk`. Files in `lib` are dependencies; files in `tests` are developer checks. Historical versions are kept in Git tags instead of duplicate launchers. No executable has been built yet.

This is an independent helper, not an official Zoom product.
