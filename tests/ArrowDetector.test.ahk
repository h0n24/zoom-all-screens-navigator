#Requires AutoHotkey v2.0
#Include ..\lib\ArrowDetector.ahk

; Pure in-memory tests: no screen capture, hotkeys, mouse input or Zoom needed.
checks := 0
try {
    for scale in [1, 1.25, 1.5, 2, 3] {
        for direction in ["left", "right"] {
            for color in [0x5BB9F9, 0x7F8589] {
                s := Fixture(scale)
                DrawTriangle(s, direction, color, scale)
                result := DetectArrows(s, direction, scale)
                Assert(result.Length = 1, "triangle at scale " scale " " direction)
                Assert(result[1].enabled = (color = 0x5BB9F9), "enabled state")
                Assert(result[1].x < 0 && result[1].y > 3000, "virtual desktop coordinates")
                opposite := direction = "left" ? "right" : "left"
                Assert(DetectArrows(s, opposite, scale).Length = 0, "wrong direction")
            }
        }
    }
    s := Fixture(1)
    Assert(DetectArrows(s, "right").Length = 0, "empty gutter")
    for color in [0xFFFFFF, 0xF05050, 0x00FF00] {
        s := Fixture(1)
        DrawTriangle(s, "right", color, 1)
        Assert(DetectArrows(s, "right").Length = 0, "wrong colour")
    }
    s := Fixture(1)
    Loop 16 {
        y := A_Index + 19
        Loop 10
            Pixel(s, A_Index + 19, y, 0x5BB9F9)
    }
    Assert(DetectArrows(s, "right").Length = 0, "blue rectangle")
    s := Fixture(1)
    DrawTriangle(s, "right", 0x5BB9F9, 1)
    Pixel(s, 23, 27, 0x101010)
    Assert(DetectArrows(s, "right").Length = 0, "hole in triangle")
    s := Fixture(1)
    DrawTriangle(s, "right", 0x5BB9F9, 1, 0)
    Assert(DetectArrows(s, "right").Length = 0, "clipped shape")
    s := Fixture(1)
    DrawTriangle(s, "right", 0x5BB9F9, 1)
    DrawTriangle(s, "right", 0x5BB9F9, 1, 20, 60)
    Assert(DetectArrows(s, "right").Length = 2, "ambiguous pair remains ambiguous")
    FileAppend "PASS: " checks " assertions`n", "*"
    ExitApp 0
} catch as err {
    FileAppend "FAIL: " err.Message "`n", "*"
    ExitApp 1
}

Fixture(scale) {
    w := Round(54 * scale), h := Round(110 * scale)
    s := {x: -4900, y: 3100, w: w, h: h, data: Buffer(w * h * 4)}
    Loop w * h
        NumPut("uint", 0x101010, s.data, (A_Index - 1) * 4)
    return s
}

DrawTriangle(s, direction, color, scale, ox := 20, oy := 20) {
    height := Round(16 * scale), width := Round(10 * scale)
    Loop height {
        y := A_Index - 1
        span := Max(1, Round(width * (1 - Abs((2 * y / (height - 1)) - 1))))
        Loop span {
            x := direction = "right" ? A_Index - 1 : width - A_Index
            Pixel(s, Round(ox * scale) + x, Round(oy * scale) + y, color)
        }
    }
}

Pixel(s, x, y, color) => NumPut("uint", color, s.data, (y * s.w + x) * 4)

Assert(condition, message) {
    global checks
    checks++
    if !condition
        throw Error(message)
}
