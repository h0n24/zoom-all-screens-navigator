# Testing

## Version 0.6.0 — 2026-10-15

Environment: Windows, Zoom 7.1.9.48550, AutoHotkey 2.0.30 x64, 100% scaling. The All screens render child measured 1833 × 966 pixels in a window with two pages. Tests used an already-running meeting without restarting Zoom.

Verified live by observing Zoom's tiles/page indicators, rather than relying only on click logs:

- Right navigates to page 2/2; Left returns to 1/2.
- Left works with chat open. Both directions work with chat and settings open together.
- The disabled right arrow on page 2/2 produces no click.
- With an empty chat editor focused, a temporary unsent `abcd` draft was entered. Left moved the caret, and inserting `X` produced `abcXd` while the gallery stayed on page 1/2. The test draft was then removed without sending it.
- Double-click on a shared-screen tile opens that screen inside the existing window, retaining the sidebar. A subsequent double-click returns to the overview.
- Double-click on a participant-name tile with no expand button leaves the overview unchanged and does not enter whole-window fullscreen.
- A rapid triple-click produces one expansion, not repeated toggles or fullscreen. A later double-click returns normally.
- Pointer restoration and single-click toolbar operation worked during these tests.

A startup error in an intermediate development build left the previous helper running; one early double-click therefore entered Zoom's native fullscreen. The startup error was corrected, the view was restored, and the double-click tests above were repeated successfully with the new helper running.

Desktop test inputs were injected through the Computer Use tool. Physical-device timing, dragging across windows and modifier changes still need broader manual testing. The earlier baseline was also confirmed by the user with physical arrow keys.

## Automated checks

- Arrow detector: **88 passing assertions**, covering direction, enabled/disabled state, 100–300% synthetic scaling, signed coordinates, blank regions, wrong colours, rectangles, holes, clipping and ambiguity.
- Interaction checks: **52 passing assertions**, covering expand/collapse glyphs at 100–300% synthetic scaling, rejected menu/solid/cross shapes, signed coordinates, double/triple-click sequences, time/position/window changes, editor focus types and viewport resizing.

These suites use in-memory fixtures and do not interact with Zoom. Synthetic scaling tests do not replace live mixed-DPI tests.

## Baseline 0.5.0 — 2026-10-13

Verified page navigation in both directions, disabled arrows, F6 pause/resume and pointer restoration at 100% scaling. The baseline did not support side panels or automatic chat-focus protection. It is preserved under the `v0.5.0` tag.

## Remaining compatibility checks

- Physical monitors with mixed DPI and negative coordinates.
- Additional Zoom versions, themes, HDR and remote desktops.
- More than two pages, layout changes while input is pending, and rapid physical direction changes.
- Occlusion, foreground changes, manual pointer movement, dragging and modifiers during intercepted clicks.
- Other Zoom panel types and accessibility configurations.

Visual recognition cannot guarantee compatibility with future Zoom interfaces. Unknown/ambiguous icons cause the helper to avoid clicking.
