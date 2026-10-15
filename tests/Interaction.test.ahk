#Requires AutoHotkey v2.0
#Include ..\lib\ViewButton.ahk
#Include ..\lib\ZoomWindow.ahk

checks := 0
try {
    for scale in [1, 1.25, 1.5, 2, 3] {
        for glyph in ['expand', 'collapse'] {
            s := Fixture(scale, glyph)
            buttons := DetectViewButtons(s, scale)
            Assert(buttons.Length = 1, glyph ' scale ' scale)
            Assert(buttons[1].x < 0 && buttons[1].y > 3000, 'signed coordinates')
        }
        for glyph in ['blank', 'menu', 'solid', 'cross']
            Assert(DetectViewButtons(Fixture(scale, glyph), scale).Length = 0, 'reject ' glyph)
    }
    tracker := ClickSequence()
    Assert(!tracker.Down(10, 10, 1, 1000, 500, 4, 4), 'first click passes')
    Assert(tracker.Down(10, 10, 1, 1100, 500, 4, 4) && tracker.trigger, 'second triggers')
    Assert(tracker.Down(10, 10, 1, 1200, 500, 4, 4) && !tracker.trigger, 'triple suppressed')
    Assert(!tracker.Down(10, 10, 1, 2000, 500, 4, 4), 'idle resets')
    Assert(!tracker.Down(30, 10, 1, 2100, 500, 4, 4), 'different position')
    Assert(!tracker.Down(30, 10, 2, 2200, 500, 4, 4), 'different viewport')
    for scale in [1, 1.25, 1.5, 2, 3] {
        tolerance := ClickTolerance(scale, 4, 4)
        tracker := ClickSequence()
        tracker.Down(-100, 100, 1, 1000, 500, tolerance, tolerance)
        Assert(tracker.Down(-100 + tolerance, 100 - tolerance, 1, 1100, 500, tolerance, tolerance)
            && tracker.trigger, 'diagonal hand motion at scale ' scale)
        Assert(WithinClickMotion(-100 + tolerance, 100 - tolerance, -100, 100, tolerance),
            'release and delayed click accept same tolerance')
        Assert(!WithinClickMotion(-99 + tolerance, 100, -100, 100, tolerance), 'larger motion cancels')
        tracker := ClickSequence()
        tracker.Down(100, 100, 1, 1000, 500, tolerance, tolerance)
        Assert(!tracker.Down(101 + tolerance, 100, 1, 1100, 500, tolerance, tolerance),
            'separate clicks outside tolerance')
    }
    Assert(ClickTolerance(1, 20, 16) = 20, 'respect larger system tolerance')
    Assert(FocusTypeUsesArrows(50004), 'edit retains arrows')
    Assert(FocusTypeUsesArrows(50030), 'document retains arrows')
    Assert(!FocusTypeUsesArrows(50033), 'render pane allows navigation')
    a := {child: 1, x: -200, y: 10, w: 100, h: 50}
    Assert(PointInside(a, -150, 30) && !PointInside(a, -100, 30), 'viewport bounds')
    Assert(SameViewport(a, a), 'stable viewport')
    Assert(!SameViewport(a, {child: 1, x: -200, y: 10, w: 99, h: 50}), 'resize cancels')
    FileAppend 'PASS: ' checks ' assertions`n', '*'
    ExitApp 0
} catch as err {
    FileAppend 'FAIL: ' err.Message '`n', '*'
    ExitApp 1
}
Assert(value, message) {
    global checks
    checks++
    if !value
        throw Error(message)
}
Fixture(scale, glyph) {
    w := Round(50 * scale), h := Round(50 * scale)
    s := {x: -1500, y: 3500, w: w, h: h, data: Buffer(w * h * 4, 0)}
    Loop h {
        y := A_Index - 1, gy := Floor(y / scale) - 10
        Loop w {
            x := A_Index - 1, gx := Floor(x / scale) - 10
            c := 0x222222
            if glyph != 'blank' && gx >= 0 && gx < 24 && gy >= 0 && gy < 24 {
                c := 0x0E72ED
                if glyph = 'menu' && gy >= 11 && gy <= 13 && (gx = 6 || gx = 12 || gx = 18)
                    c := 0xFFFFFF
                if glyph = 'cross' && (gx = 12 || gy = 12)
                    c := 0xFFFFFF
                if glyph = 'expand' || glyph = 'collapse' {
                    if (gx >= 13 && gx <= 18 && gy >= 5 && gy <= 10)
                        || (gx >= 5 && gx <= 10 && gy >= 13 && gy <= 18) {
                        if gx + gy = 23 || (glyph = 'expand' && (gy = 5 || gx = 18 || gx = 5 || gy = 18))
                            || (glyph = 'collapse' && (gy = 10 || gx = 13 || gx = 10 || gy = 13))
                            c := 0xFFFFFF
                    }
                }
            }
            NumPut('uint', c, s.data, (y * w + x) * 4)
        }
    }
    return s
}
