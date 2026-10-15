#Requires AutoHotkey v2.0

RenderClickContext() {
    global navEnabled
    if !navEnabled || !WinActive('ahk_exe Zoom.exe')
        return false
    try {
        v := ZoomViewport(WinActive('A'))
        MouseGetPos &x, &y,, &child, 2
        return PointInside(v, x, y) && child = v.child
    }
    return false
}

RenderMouseDown() {
    global mousePress, clickTracker, lastClick
    Critical
    MouseGetPos &x, &y
    v := ZoomViewport(WinActive('A'))
    if !IsObject(v) {
        mousePress := {forward: true}
        SendEvent '{Blind}{LButton Down}'
        return
    }
    scale := Max(1, DllCall('GetDpiForWindow', 'ptr', v.hwnd, 'uint') / 96)
    tolerance := ClickTolerance(scale, SysGet(36), SysGet(37))
    repeat := clickTracker.Down(x, y, v.child, A_TickCount,
        DllCall('GetDoubleClickTime', 'uint'), tolerance, tolerance)
    mousePress := {forward: !repeat, toggle: clickTracker.trigger, v: v, x: x, y: y, tolerance: tolerance}
    if !repeat {
        SendEvent '{Blind}{LButton Down}'
        lastClick := A_TickCount
    }
}

RenderMouseUp() {
    global mousePress, clickTracker
    Critical
    press := mousePress
    mousePress := false
    if press.forward {
        SendEvent '{Blind}{LButton Up}'
        MouseGetPos &x, &y
        if press.HasOwnProp('x') && (Abs(x - press.x) > SysGet(36) || Abs(y - press.y) > SysGet(37))
            clickTracker.last := false
        return
    }
    MouseGetPos &x, &y
    if press.toggle && WithinClickMotion(x, y, press.x, press.y, press.tolerance)
        && PointInside(press.v, x, y)
        SetTimer () => ToggleVisibleScreen(press), -1
}

ToggleVisibleScreen(press) {
    global busy, navEnabled, lastClick
    if busy || !navEnabled
        return
    busy := true
    try {
        v := press.v
        if !WinActive('ahk_id ' v.hwnd) || !SameViewport(v, ZoomViewport(v.hwnd))
            return
        scale := DllCall('GetDpiForWindow', 'ptr', v.hwnd, 'uint') / 96
        stripW := Round(150 * scale)
        buttons := DetectViewButtons(ScreenStrip(v.x + v.w - stripW, v.y, stripW, v.h), scale)
        Log('double click: view buttons=' buttons.Length)
        if buttons.Length != 1
            return
        target := buttons[1]
        ; A generated click must never combine with the forwarded first click.
        remaining := DllCall('GetDoubleClickTime', 'uint') + 80 - (A_TickCount - lastClick)
        if remaining > 0
            Sleep remaining
        MouseGetPos &x, &y
        if !navEnabled || !WinActive('ahk_id ' v.hwnd) || GetKeyState('LButton', 'P')
            || !SameViewport(v, ZoomViewport(v.hwnd)) || !PointInside(v, x, y)
            || !WithinClickMotion(x, y, press.x, press.y, press.tolerance)
            return
        ; Recheck only the icon crop, with the pointer still away from it.
        size := Round(40 * scale)
        checked := DetectViewButtons(ScreenStrip(target.x - size // 2, target.y - size // 2, size, size), scale)
        if checked.Length != 1 || !TargetWindowAt(target.x, target.y, v.hwnd)
            return
        MouseMove target.x, target.y, 0
        try {
            MouseClick 'Left',,, 1, 0, 'D'
            Sleep 50
        } finally {
            MouseClick 'Left',,, 1, 0, 'U'
            lastClick := A_TickCount
            MouseGetPos &mx, &my
            if Abs(mx - target.x) <= 2 && Abs(my - target.y) <= 2
                MouseMove x, y, 0
        }
        Log('view button clicked')
    } catch as err {
        Log('double click error: ' err.Message)
    } finally {
        busy := false
    }
}
