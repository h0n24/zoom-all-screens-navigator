# Zoom All Screens Navigator

Use Left and Right to page through Zoom's All screens view on Windows, without calibration. Students do not need to install anything.

## Quick start

1. Install AutoHotkey v2 from https://www.autohotkey.com/.
2. Keep the complete project folder, including `lib`.
3. Exit any older copy of this helper through its tray icon. Do not close Zoom.
4. Run `Zoom_AllScreens_Arrows_v5.ahk`.
5. Activate Zoom's All screens window and press Left or Right.

F6 pauses or resumes the helper. Pause it while typing in chat. Release the arrow key before pressing it again. At the first/last page, the helper does not click the disabled arrow.

Use the tray menu to pause, open this guide or quit the helper. Quitting the helper does not end the meeting.

## Limitations

This baseline version expects both arrows at the outside edges of the window. Close side panels before using it. It was tested in Zoom 7.1.9.48550 at 100% scaling. Other display configurations need additional live testing.

The helper checks arrow shape, colour and direction before clicking. It does not increase the number of shared screens on a page. If it cannot identify the navigation pair, it sends the original key to Zoom without clicking.

## Privacy

No network access or saved screenshots. Two small edge regions are processed in memory only when navigating. Optional debug logs record geometry and detection results, not meeting content. Logs are excluded from Git.

## Development

See [DEVELOPMENT.md](DEVELOPMENT.md) and [TESTING.md](TESTING.md). An executable build is planned but has not been created. This is an independent helper, not an official Zoom product.
