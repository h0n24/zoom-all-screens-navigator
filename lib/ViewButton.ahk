#Requires AutoHotkey v2.0

ButtonBlue(c) => (c & 255) >= 190 && ((c >> 8) & 255) >= 75
    && ((c >> 8) & 255) <= 165 && ((c >> 16) & 255) < 65

; Recognize the rounded blue square and diagonal white expand/collapse glyph.
; The adjacent three-dot menu has no diagonal glyph and is rejected.
DetectViewButtons(strip, scale := 1) {
    w := strip.w, h := strip.h, n := w * h
    ; A valid button has a solid blue border. Sparse seeds find that border
    ; without classifying every pixel in the tall viewport strip twice.
    mask := Buffer(n, 0), found := [], step := Max(1, Floor(4 * scale))
    columns := Ceil(w / step), rows := Ceil(h / step)
    Loop columns * rows {
        seed := ((A_Index - 1) // columns) * step * w + Mod(A_Index - 1, columns) * step
        if NumGet(mask, seed, 'uchar') || !ButtonBlue(NumGet(strip.data, seed * 4, 'uint'))
            continue
        queue := [seed], head := 1
        NumPut('uchar', 1, mask, seed)
        lx := w, rx := 0, ty := h, by := 0
        while head <= queue.Length {
            p := queue[head++], x := Mod(p, w), y := p // w
            lx := Min(lx, x), rx := Max(rx, x), ty := Min(ty, y), by := Max(by, y)
            for delta in [-w, -1, 1, w] {
                q := p + delta
                if q < 0 || q >= n || (delta = -1 && x = 0) || (delta = 1 && x = w - 1)
                    continue
                if !NumGet(mask, q, 'uchar') && ButtonBlue(NumGet(strip.data, q * 4, 'uint')) {
                    NumPut('uchar', 1, mask, q)
                    queue.Push(q)
                }
            }
        }
        bw := rx - lx + 1, bh := by - ty + 1
        if bw < 20 * scale || bw > 29 * scale || Abs(bw - bh) > 2 * scale
            || lx = 0 || ty = 0 || rx = w - 1 || by = h - 1
            || queue.Length < bw * bh * 0.65
            continue
        upper := 0, lower := 0, other := 0, minY := bh, maxY := 0
        Loop bh {
            yy := A_Index - 1
            Loop bw {
                xx := A_Index - 1
                c := NumGet(strip.data, ((ty + yy) * w + lx + xx) * 4, 'uint')
                if (c & 255) < 170 || ((c >> 8) & 255) < 170 || ((c >> 16) & 255) < 150
                    continue
                minY := Min(minY, yy), maxY := Max(maxY, yy)
                if xx > bw * 0.48 && yy < bh * 0.48
                    upper++
                else if xx < bw * 0.48 && yy > bh * 0.48
                    lower++
                else
                    other++
            }
        }
        if upper >= 5 * scale * scale && lower >= 5 * scale * scale
            && other <= (upper + lower) * 0.2 && maxY - minY >= bh * 0.4
            found.Push({x: strip.x + (lx + rx) // 2, y: strip.y + (ty + by) // 2})
    }
    return found
}
