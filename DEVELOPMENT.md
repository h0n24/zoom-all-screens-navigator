# Development

## Structure

- `ZoomNavigator.ahk`: application entry point, tray menu, arrow hotkeys and verified clicks.
- `lib/ArrowDetector.ahk`: bounded GDI capture and connected-component triangle recognition.
- `lib/ZoomWindow.ahk`: rendering viewport, focus protection and click-sequence classification.
- `lib/ViewButton.ahk`: blue expand/collapse icon recognition.
- `lib/MouseNavigation.ahk`: mouse interception and selected-screen toggling.
- `lib/UpdateChecker.ahk`: asynchronous version checks and tray notifications.
- `VERSION`: stable release version served to installed helpers.
- `tests/`: deterministic in-memory tests; no Zoom interaction.

Windows and AutoHotkey v2 are the only runtime dependencies. Documentation, comments and commit messages are in English. Keep one stable entry point and use Git tags for releases.

## Arrow navigation

Unmodified Left/Right hotkeys apply only while Zoom is foreground and the helper is enabled. The native `ProctorModeRenderWindow` child provides the current render rectangle, excluding chat/settings and the meeting toolbar. Hidden children are ignored; an absent or ambiguous viewport cancels detection. No saved coordinates or sidebar-width guesses are used.

Before navigation, inspect `GetGUIThreadInfo` and UI Automation focus. Zoom's custom chat editor can report the top-level window as its UIA focus, so the native caret flag is essential. Editors, documents, lists and other controls that use arrows receive the original key. Unknown focus also preserves native input. The script never reads editor contents.

Capture two 54-DIP-wide strips around the vertical centre of the viewport. Classify connected blue/grey components and verify size, direction, filled rows, symmetry, density and a dark surrounding margin. Require exactly one compatible arrow on each side; never click a disabled grey arrow. If no pair exists, forward the original key without a mouse click.

Recheck the pair before moving the pointer, then verify foreground, viewport, focus and pointer position before clicking. A pointer near the gutters is temporarily parked to avoid hover/highlight interference. Release mouse buttons in `finally` and restore the pointer only if it has not moved. A busy flag and `KeyWait` prevent overlapping navigation and held-key paging.

## Double-click handling

Mouse hooks apply only over the actual rendering child in the Zoom window under the pointer, including an inactive window being activated by the first click. Forward the first down/up immediately. Consume repeated clicks within the Windows double-click interval and a 48-DIP spatial tolerance (or the larger system tolerance); trigger at most one toggle per rapid sequence. Movement beyond the same tolerance during the first press resets the sequence. Small first-press jitter must not erase the first click. The second release and delayed action use the same relaxed double-click tolerance and must remain inside the viewport. Mouse-up remains paired even if the pointer leaves the viewport or a modifier changes. An exit handler releases a forwarded down event.

On a recognized double-click, capture a narrow right-edge strip and find a blue square with a white diagonal expand/collapse glyph. Reject blank squares and the adjacent three-dot menu. Require exactly one candidate, then recheck its crop, unchanged viewport, foreground and pointer before a single click. Without a valid candidate, do nothing. The whole-window fullscreen command is never sent.

Generated clicks respect the Windows double-click interval plus a margin. Both features share a busy flag and click timestamp. Pixel checks are not a semantic Zoom API: future layouts, occlusion and simultaneous physical input still need live testing. There is an unavoidable interval between observation and input delivery.

## Update checks

The application version and root `VERSION` file must match. An asynchronous WinHTTP GET reads the fixed GitHub raw `main/VERSION` endpoint. A timer polls completion without blocking on the response. Requests have bounded timeouts; only HTTP 200 and three numeric version components are accepted. Comparison is numeric, and older versions never trigger a downgrade. Remote text is never executed or used as a command/URL.

Automatic checks run after startup and every 24 hours. Their failures are silent; explicit checks report errors. Notifications are deduplicated per version during a run, and an update remains visible in the tray menu. Downloads open the fixed repository's latest-release page only when the user selects the menu item. No automatic replacement, executable build or installer is involved. The automatic-check preference is stored in `%APPDATA%\ZoomNavigator\settings.ini`.

Before pushing a new `VERSION`, create a matching GitHub release so the fixed download page is ready. Old versions before 0.6.2 cannot discover updates automatically.

## Run tests

From PowerShell in the repository:

```powershell
foreach ($suite in 'ArrowDetector', 'Interaction', 'UpdateChecker') {
    $run = Start-Process 'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe' `
        -ArgumentList '/ErrorStdOut', "tests/$suite.test.ahk" `
        -WindowStyle Hidden -Wait -PassThru `
        -RedirectStandardOutput "$suite-results.log" `
        -RedirectStandardError "$suite-errors.log"
    Get-Content "$suite-results.log", "$suite-errors.log"
    if ($run.ExitCode -ne 0) { throw "$suite failed" }
}
```

The suites exercise synthetic icon regions, DPI scales, negative coordinates, focus types, viewport changes and double/triple-click sequences. See [TESTING.md](TESTING.md) for live evidence and remaining gaps.

To enable optional local diagnostics, launch `ZoomNavigator.ahk --debug` using AutoHotkey. `navigation-debug.log` records detection geometry and events, never captured images or chat text. A `click sent` line does not prove the page changed: verify Zoom visually. Restart only the helper without `--debug` for normal use.

## Release process

Run all suites, validate the changed behaviour in an existing test meeting, review the staged files, then commit and tag. Never close or restart an active meeting for testing. Never commit screenshots, meeting content, credentials or local diagnostics. The `.local` directory and logs are ignored.

No executable is currently built. Before a binary release, choose a licence, validate supported Windows/Zoom versions, and package user-facing help without assuming a neighbouring Markdown file. Build an executable only when explicitly requested.
