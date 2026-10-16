# Changelog

## 0.6.4

- Publish a standalone Windows x64 executable built with official Ahk2Exe; users no longer need to install AutoHotkey.
- Include SHA-256 checksums, runtime licence notices and corresponding AutoHotkey source in binary releases.
- Embed a short Help dialog so the executable works without adjacent documentation files.
- Document the Windows-only release and verification workflow in project instructions.

## 0.6.3

- Remove the double-click waiting period and avoid cancelling recognized gestures when the pointer subsequently moves within the viewport.
- Speed up expand/collapse icon recognition using sparse seeds with full component validation.
- Activate the verified button directly without moving the pointer or generating native double-clicks.
- Recognize successive rapid pairs while continuing to suppress unpaired extra clicks.

## 0.6.2

- Increase double-click movement tolerance to 48 DIP, including motion during the first press.
- Track the first click when it activates an inactive Zoom window, preventing an untracked click from reaching native fullscreen handling.
- Add background update checks at startup and daily, manual checks, a remembered opt-out and an update download entry in the tray menu.
- Keep updates notification-only: no automatic installation or Zoom restart.

## 0.6.1

- Allow small pointer movement between double-clicks and while waiting for the view toggle.
- Use a consistent 12-DIP tolerance (or the larger system tolerance), while preserving drag detection and viewport checks.

## 0.6.0

- Follow the actual All screens viewport when chat or settings panels are open.
- Preserve arrow-key editing with native caret and UI Automation focus checks.
- Replace double-click fullscreen with the visible shared-screen expand/collapse button.
- Preserve ordinary clicks and dragging; suppress extra clicks in rapid sequences.
- Use one stable `ZoomNavigator.ahk` launcher, with previous versions in Git tags.
- Provide English documentation and interface text.

## 0.5.0

- Introduce calibration-free visual recognition of paging arrows.
- Add disabled-arrow checks, F6 pause and pointer restoration.
- Preserve the tested baseline before sidebar and double-click changes.
