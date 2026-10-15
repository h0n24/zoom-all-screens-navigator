#Requires AutoHotkey v2.0

; Read one small screen rectangle into memory instead of making a GDI call
; for every pixel. Coordinates and the top-down DIB are physical pixels.
class ScreenStrip {
    __New(x, y, w, h) {
        this.x := x, this.y := y, this.w := w, this.h := h
        screen := DllCall("GetDC", "ptr", 0, "ptr")
        dc := DllCall("gdi32\CreateCompatibleDC", "ptr", screen, "ptr")
        bitmap := 0, previous := 0
        try {
            info := Buffer(40, 0)
            NumPut("uint", 40, "int", w, "int", -h, "ushort", 1, "ushort", 32, info)
            bits := 0
            bitmap := DllCall("gdi32\CreateDIBSection", "ptr", dc, "ptr", info,
                "uint", 0, "ptr*", &bits, "ptr", 0, "uint", 0, "ptr")
            if !screen || !dc || !bitmap || !bits
                throw Error("Could not capture the window region.")
            previous := DllCall("gdi32\SelectObject", "ptr", dc, "ptr", bitmap, "ptr")
            if !DllCall("gdi32\BitBlt", "ptr", dc, "int", 0, "int", 0,
                "int", w, "int", h, "ptr", screen, "int", x, "int", y, "uint", 0x40CC0020)
                throw Error("Could not capture the window region.")
            this.data := Buffer(w * h * 4)
            DllCall("ntdll\RtlMoveMemory", "ptr", this.data, "ptr", bits, "uptr", this.data.Size)
        } finally {
            if previous
                DllCall("gdi32\SelectObject", "ptr", dc, "ptr", previous)
            if bitmap
                DllCall("gdi32\DeleteObject", "ptr", bitmap)
            if dc
                DllCall("gdi32\DeleteDC", "ptr", dc)
            if screen
                DllCall("ReleaseDC", "ptr", 0, "ptr", screen)
        }
    }
}

ArrowColor(rgb) {
    r := (rgb >> 16) & 255, g := (rgb >> 8) & 255, b := rgb & 255
    if (Abs(r - 91) <= 38 && Abs(g - 185) <= 38 && Abs(b - 249) <= 38 && b - r > 65)
        return 1 ; Enabled blue.
    if (r >= 85 && r <= 165 && Abs(r - g) <= 20 && Abs(g - b) <= 20)
        return 2 ; Disabled grey; usable only as the opposite-side guard.
    return 0
}

; Connected components prevent unrelated blue pixels from becoming one arrow.
; Both sides must contain exactly one geometrically valid triangle.
DetectArrows(strip, direction, scale := 1) {
    w := strip.w, h := strip.h, n := w * h
    mask := Buffer(n, 0)
    Loop n
        NumPut("uchar", ArrowColor(NumGet(strip.data, (A_Index - 1) * 4, "uint")), mask, A_Index - 1)
    found := []
    Loop n {
        seed := A_Index - 1
        kind := NumGet(mask, seed, "uchar")
        if !kind
            continue
        queue := [seed], head := 1, pixels := []
        NumPut("uchar", 0, mask, seed)
        minX := w, maxX := 0, minY := h, maxY := 0
        while head <= queue.Length {
            p := queue[head++], px := Mod(p, w), py := p // w
            pixels.Push(p)
            minX := Min(minX, px), maxX := Max(maxX, px)
            minY := Min(minY, py), maxY := Max(maxY, py)
            for delta in [-w, -1, 1, w] {
                q := p + delta
                if (q < 0 || q >= n || (delta = -1 && px = 0) || (delta = 1 && px = w - 1))
                    continue
                if NumGet(mask, q, "uchar") = kind {
                    NumPut("uchar", 0, mask, q)
                    queue.Push(q)
                }
            }
        }
        ih := maxY - minY + 1, iw := maxX - minX + 1
        if (ih < 7 * scale || ih > 28 * scale || iw < 4 * scale || iw > 22 * scale
            || iw / ih < 0.3 || iw / ih > 0.95 || minX = 0 || maxX = w - 1
            || minY = 0 || maxY = h - 1)
            continue
        rows := Map()
        for p in pixels {
            px := Mod(p, w), py := p // w
            if !rows.Has(py)
                rows[py] := {l: px, r: px, count: 1}
            else {
                row := rows[py]
                row.l := Min(row.l, px), row.r := Max(row.r, px), row.count++
            }
        }
        valid := true
        for _, row in rows
            if row.count != row.r - row.l + 1
                valid := false
        if !valid || rows.Count != ih
            continue
        top := rows[minY + Round((ih - 1) * 0.2)]
        midY := minY + Round((ih - 1) * 0.5)
        mid := rows[midY], bot := rows[minY + Round((ih - 1) * 0.8)]
        offset := Max(2, Round(ih * 0.12)), flat := Max(2, Round(ih * 0.18))
        if direction = "right" {
            tip := mid.r - Max(top.r, bot.r)
            base := Max(top.l, mid.l, bot.l) - Min(top.l, mid.l, bot.l)
        } else {
            tip := Min(top.l, bot.l) - mid.l
            base := Max(top.r, mid.r, bot.r) - Min(top.r, mid.r, bot.r)
        }
        if (tip < offset || base > flat || Abs(top.count - bot.count) > flat
            || pixels.Length / (iw * ih) < 0.4 || pixels.Length / (iw * ih) > 0.85)
            continue
        ; Require a dark moat, keeping text, tiles and touching shapes out.
        margin := Max(2, Round(3 * scale))
        if minX < margin || minY < margin || maxX + margin >= w || maxY + margin >= h
            continue
        for xx in [minX - margin, maxX + margin] {
            for yy in [minY - margin, midY, maxY + margin] {
                c := NumGet(strip.data, (yy * w + xx) * 4, "uint")
                if ((c & 255) > 65 || ((c >> 8) & 255) > 65 || ((c >> 16) & 255) > 65)
                    valid := false
            }
        }
        if valid
            found.Push({x: strip.x + Round((mid.l + mid.r) / 2), y: strip.y + midY,
                enabled: kind = 1, height: ih, width: iw})
    }
    return found
}
