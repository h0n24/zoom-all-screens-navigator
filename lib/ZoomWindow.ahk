#Requires AutoHotkey v2.0

; Zoom's visible rendering child excludes chat/settings side panels and the
; meeting toolbar. Never guess a sidebar width or use stale child rectangles.
ZoomViewport(hwnd) {
    if !hwnd || !WinExist("ahk_id " hwnd) || WinGetMinMax("ahk_id " hwnd) = -1
        return false
    candidates := []
    for child in WinGetControlsHwnd("ahk_id " hwnd) {
        if !DllCall("IsWindowVisible", "ptr", child)
            continue
        if WinGetTitle("ahk_id " child) != "ProctorModeRenderWindow"
            continue
        WinGetClientPos &x, &y, &w, &h, "ahk_id " child
        if w > 300 && h > 180
            candidates.Push({hwnd: hwnd, child: child, x: x, y: y, w: w, h: h})
    }
    return candidates.Length = 1 ? candidates[1] : false
}

PointInside(rect, x, y) => IsObject(rect) && x >= rect.x && y >= rect.y
    && x < rect.x + rect.w && y < rect.y + rect.h

SameViewport(a, b) => IsObject(a) && IsObject(b) && a.child = b.child
    && a.x = b.x && a.y = b.y && a.w = b.w && a.h = b.h

; Only inspect focus metadata, never the editor's text or meeting history.
; Interface indices follow Microsoft's UIAutomationClient.h.
PreserveFocusedArrows() {
    ; Zoom's custom chat editor reports the top-level window as UIA focus.
    ; The native caret remains available even when UIA cannot name the edit.
    info := Buffer(8 + 6 * A_PtrSize + 16, 0)
    NumPut("uint", info.Size, info)
    if !DllCall("GetGUIThreadInfo", "uint", 0, "ptr", info)
        return true
    if NumGet(info, 4, "uint") & 1
        return true
    element := 0
    try {
        static automation := ComObject("{FF48DBA4-60EF-4201-AA87-54103EEF594E}",
            "{30CBE57D-D9D0-452A-AB13-7AC5AC4825EE}")
        ComCall(8, automation, "ptr*", &element) ; GetFocusedElement
        if !element
            return true
        kind := 0
        ComCall(21, element, "int*", &kind) ; CurrentControlType
        ; Editing and standard controls retain native keyboard navigation.
        return FocusTypeUsesArrows(kind)
    } catch {
        return true ; Unknown focus: preserve normal keyboard behaviour.
    } finally {
        if element
            ObjRelease(element)
    }
}

FocusTypeUsesArrows(kind) {
    static native := Map(50003, 1, 50004, 1, 50007, 1, 50008, 1,
        50009, 1, 50011, 1, 50014, 1, 50015, 1, 50016, 1,
        50018, 1, 50019, 1, 50023, 1, 50024, 1, 50028, 1, 50030, 1)
    return native.Has(kind)
}


; Allow small hand motion consistently through recognition and delayed input.
ClickTolerance(scale, systemX, systemY) => Max(Round(48 * scale), systemX, systemY)
WithinClickMotion(x, y, startX, startY, tolerance) => Abs(x - startX) <= tolerance
    && Abs(y - startY) <= tolerance

class ClickSequence {
    last := false
    trigger := false
    count := 0
    Down(x, y, child, now, interval, dx, dy) {
        previous := this.last
        repeated := IsObject(previous) && previous.child = child
            && now - previous.time <= interval
            && Abs(x - previous.x) <= dx && Abs(y - previous.y) <= dy
        ; Consume every subsequent click, but allow each completed pair to
        ; toggle. Forwarding a third click could reach Zoom as a native double-click.
        this.count := repeated ? this.count + 1 : 1
        this.trigger := repeated && Mod(this.count, 2) = 0
        this.last := {x: x, y: y, child: child, time: now, repeated: repeated}
        return repeated
    }
}
