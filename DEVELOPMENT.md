# Development

## Files

- `Zoom_AllScreens_Arrows_v5.ahk`: AutoHotkey v2 entry point, hotkeys, window checks and click handling.
- `lib/ArrowDetector.ahk`: bounded GDI capture and in-memory triangle recognition.
- `tests/ArrowDetector.test.ahk`: deterministic tests without Zoom or desktop interaction.
- `README.md`: Czech quick-start guide for teachers.
- `TESTING.md`: live test evidence and remaining compatibility checks.

No external libraries or network services are required. The installed AutoHotkey v2 interpreter is the only runtime dependency besides Windows.

## Detection and safeguards

1. Handle unmodified Left/Right only while `Zoom.exe` is foreground and navigation is enabled. F6 pauses it. A single global busy flag and `KeyWait` prevent overlapping clicks and key-repeat paging.
2. If the pointer is near a navigation gutter, park it temporarily away from the icon. Hover appearance and pointer highlighting can otherwise obscure the shape.
3. Read two 54-DIP-wide strips in the middle 16% of the client area's height. Use the window DPI. Never search the entire virtual desktop or shared tiles.
4. `BitBlt` copies each strip into a top-down 32-bit DIB. Release all GDI handles in `finally`; inspect pixels in memory.
5. Classify connected blue/grey components, then check size, aspect ratio, filled rows, tip direction, symmetry, density and dark surrounding pixels.
6. Require exactly one left and one right arrow at matching vertical positions and sizes. Grey is valid as a guard but never a click target.
7. Honour the Windows double-click interval plus a margin. Re-detect before moving onto the target, check the foreground HWND, unchanged window geometry, pointer movement and the root window under the target.
8. Send one mouse down/up pair, release the button in `finally`, and restore the pointer only if the user has not moved it. Never retry a click automatically.

The second visual check deliberately happens **before** hovering over the arrow. In live testing, the pointer highlight covered the icon and caused a post-hover check to reject it.

The interval check prevents this script's clicks from forming a double-click with each other; it cannot guarantee protection against simultaneous manual mouse input. There remains a small unavoidable race between the last observation and input delivery. Visual recognition is not a semantic Zoom API and cannot guarantee zero false positives in every future layout.

If no pair is found, the original arrow key is passed to Zoom, without a mouse click. Text focus is not inspected; users should pause navigation with F6 for chat. Side panels/layouts that move the right arrow away from the window edge are intentionally unsupported. Capture needs visible, unobscured gutters. Multi-monitor coordinates are signed; mixed-DPI behaviour needs broader live validation.

## Tests

From PowerShell in the project folder:

```powershell
$test = Start-Process 'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe' `
    -ArgumentList '/ErrorStdOut', '.\tests\ArrowDetector.test.ahk' `
    -WindowStyle Hidden -Wait -PassThru `
    -RedirectStandardOutput test-results.log -RedirectStandardError test-errors.log
Get-Content test-results.log, test-errors.log
$test.ExitCode
```

Tests return a nonzero exit code on failure. They cover direction, enabled state, several scales, negative/large virtual-desktop coordinates, blank areas, wrong colours, rectangles, holes, clipped shapes and multiple candidates. These synthetic fixtures supplement live tests; they do not prove compatibility with every renderer or theme.

For optional live diagnostics:

```powershell
& 'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe' /ErrorStdOut .\Zoom_AllScreens_Arrows_v5.ahk --debug
```

`navigation-debug.log` contains no captured images. A `click sent` entry only proves input was sent; verify the page indicator in Zoom to confirm navigation. Restart without `--debug` for normal use. Logs and future binaries are excluded by `.gitignore`.

## Future release

Do not build or publish an executable yet. Before a binary release: validate the live matrix in `TESTING.md`, choose a repository licence, decide supported Windows/Zoom versions, and package the entry point with its included detector and a user-facing help resource. A compiled build will need help handling that does not assume a neighbouring Markdown file. Never bundle meeting data, personal screenshots or diagnostic logs. GitHub commit messages are written in English.
