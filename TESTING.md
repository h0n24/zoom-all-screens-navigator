# Testing

## Baseline v5 — 2026-10-13

Environment: Windows; Zoom 7.1.9.48550; AutoHotkey 2.0.30 (64-bit); 1564 × 1129 client area at 96 DPI; an existing meeting with two pages.

Verified live without restarting Zoom:

- Right changes page 1/2 to 2/2.
- Left changes page 2/2 to 1/2.
- Disabled arrows on both boundaries produce no click.
- F6 pauses and resumes navigation.
- The pointer returns after clicking.
- No unintended fullscreen transition was observed during these tests.

Page indicators and tiles were visually checked; a log entry saying `click sent` alone was not treated as proof of success. One final left-navigation sample took approximately 141 ms to send the click; this is not a performance guarantee.

The detector passed 88 assertions over in-memory fixtures, including directions, enabled/disabled colours, 100–300% scales, signed/large coordinates, blank regions, wrong colours, rectangles, holes, clipped shapes and ambiguous candidates.

During development a pointer highlight obscured the arrow. Moving the final visual verification before pointer placement resolved that observed failure. This does not prove the cause of every earlier v4 failure.

## Compatibility still to validate

- Physical monitors with mixed DPI and negative coordinates.
- Additional Zoom versions, themes, HDR and remote desktops.
- More than two pages, key repeat and rapid direction changes.
- Changes to sharing/layout during navigation.
- Occlusion, focus loss and manual pointer movement during input.
- Side panels and chat editing (unsupported by the baseline).

Synthetic scale tests do not replace live Windows DPI tests. Visual recognition cannot guarantee compatibility with every future interface.
