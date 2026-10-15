# Changelog

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
