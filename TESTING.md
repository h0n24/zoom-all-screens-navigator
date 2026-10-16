# Testing

## Version 0.6.4 — 2026-10-16

All 221 automated assertions pass. The Windows x64 executable was compiled with Ahk2Exe 1.1.37.02a2 and AutoHotkey 2.0.30, then launched from an unrelated working directory without adjacent scripts or libraries. Startup produced no errors and the process remained running. The installed AutoHotkey runtime was not removed: this is a standalone packaging smoke test, not a clean-machine compatibility test. Navigation behaviour is unchanged from 0.6.3.

## Version 0.6.3 — 2026-10-16

All suites pass: arrow detection **88**, interaction **108**, update checks **25** assertions. New coverage checks sparse detection with shifted icon origins at multiple DPI scales and successive rapid pairs, including suppression of intervening odd clicks.

In an existing Zoom meeting, direct child-control clicks successfully expanded and collapsed a selected shared screen without moving the pointer or entering whole-window fullscreen. Both final implementation actions logged approximately **31 ms** from handler entry to click dispatch; this measures helper processing, not display refresh latency. Double-clicking a participant-name tile without a visible view button left the overview unchanged. Zoom was not restarted.

A synthetic blank 150 x 1000 strip benchmark (ten scans) took 625 ms with the old detector and 47 ms with sparse seeds. This is a detector-only measurement, not an end-to-end performance guarantee. Physical hand-motion and inactive-window activation still require user validation; injected desktop tests cannot establish those behaviours conclusively.

## Version 0.6.2

Interaction checks: **76 passing assertions**, including a 30-pixel diagonal double-click, first-press motion and a 48-DIP default. Update checks: **25 passing assertions** for strict parsing, numeric comparison, equal/older versions, HTTP failures, invalid responses, asynchronous pending/completed states and timeout handling.

The inactive-window first-click fix follows a code-path review: the old foreground-only mouse context skipped the activation click. Physical validation of that specific transition is pending. Earlier live results below do not establish that this regression is fixed on every setup. A standalone real-network transport test was blocked by the execution tool; update completion and failure handling were tested with simulated transport responses.

## Version 0.6.1 — pointer movement regression

The interaction suite passes **73 assertions**, including 21 new checks for diagonal movement between clicks, consistent release/delayed-action tolerance, cancellation beyond the threshold, and larger system tolerances at 100–300% synthetic scaling. The pointer-movement fix has been checked with deterministic tests; physical hand-motion testing remains to be confirmed. Live results below apply to 0.6.0.


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
