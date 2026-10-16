#Requires AutoHotkey v2.0
#SingleInstance Force
#MaxThreadsPerHotkey 1
#Include lib\ArrowDetector.ahk
#Include lib\ZoomWindow.ahk
#Include lib\ViewButton.ahk
#Include lib\MouseNavigation.ahk
#Include lib\UpdateChecker.ahk

; Zoom All Screens Navigator. No calibration or Zoom restart required.
InstallMouseHook()
CoordMode "Mouse", "Screen"
CoordMode "ToolTip", "Screen"
SendMode "Event"
SetMouseDelay -1
navEnabled := true
busy := false
lastClick := 0
mousePress := false
clickTracker := ClickSequence()
OnExit(ReleaseMouse)
debug := A_Args.Length && A_Args[1] = "--debug"
A_IconTip := "Zoom Navigator - enabled (F6: pause)"
A_TrayMenu.Delete()
A_TrayMenu.Add("Pause / resume (F6)", (*) => ToggleNavigation())
A_TrayMenu.Add("Help", (*) => Run(A_ScriptDir "\README.md"))
updateService := UpdateChecker('0.6.3')
A_TrayMenu.Add()
A_TrayMenu.Add("Quit Zoom Navigator", (*) => ExitApp())

#HotIf WinActive("ahk_exe Zoom.exe")
F6::ToggleNavigation()
#HotIf WinActive("ahk_exe Zoom.exe") && navEnabled
$Left::HandleArrow("left", "Left")
$Right::HandleArrow("right", "Right")
#HotIf RenderClickContext()
$*LButton::RenderMouseDown()
#HotIf IsObject(mousePress)
$*LButton Up::RenderMouseUp()
#HotIf

ReleaseMouse(*) {
    global mousePress
    if IsObject(mousePress) && mousePress.forward
        SendEvent '{Blind}{LButton Up}'
}

ToggleNavigation() {
    global navEnabled
    navEnabled := !navEnabled
    A_IconTip := "Zoom Navigator - " (navEnabled ? "enabled" : "paused") " (F6)"
    ShowStatus(navEnabled ? "Zoom Navigator enabled" : "Zoom Navigator paused - press F6 to resume")
}

HandleArrow(direction, key) {
    global busy
    if PreserveFocusedArrows() {
        SendEvent "{" key "}"
        Log("native keyboard focus; key passed through")
        return
    }
    if busy
        return
    busy := true
    try Navigate(direction, key)
    catch as err {
        Log("error: " err.Message)
        ShowStatus("Could not verify the arrow. Try again, or press F6 to pause.")
    } finally {
        KeyWait key
        busy := false
    }
}

FindNavigation(hwnd) {
    viewport := ZoomViewport(hwnd)
    if !IsObject(viewport)
        return false
    x := viewport.x, y := viewport.y, w := viewport.w, h := viewport.h
    scale := DllCall("GetDpiForWindow", "ptr", hwnd, "uint") / 96
    if scale <= 0
        scale := 1
    if w < 450 * scale || h < 250 * scale
        return false
    ; The gutters contain Zoom's arrows, never scan the shared screen tiles.
    stripW := Round(54 * scale), stripH := Round(h * 0.16)
    stripY := y + Round(h * 0.42)
    left := DetectArrows(ScreenStrip(x, stripY, stripW, stripH), "left", scale)
    right := DetectArrows(ScreenStrip(x + w - stripW, stripY, stripW, stripH), "right", scale)
    Log("scan " x "," y " " w "x" h " dpi=" scale " left=" left.Length " right=" right.Length)
    if left.Length != 1 || right.Length != 1
        return false
    l := left[1], r := right[1]
    if Abs(l.y - r.y) > 3 * scale || Abs(l.height - r.height) > 3 * scale
        return false
    return {left: l, right: r, x: x, y: y, w: w, h: h, child: viewport.child}
}

TargetWindowAt(x, y, hwnd) {
    point := Buffer(8)
    NumPut("int", x, "int", y, point)
    hit := DllCall("WindowFromPoint", "int64", NumGet(point, 0, "int64"), "ptr")
    return DllCall("GetAncestor", "ptr", hit, "uint", 2, "ptr") = hwnd
}

Navigate(direction, key) {
    global lastClick
    hwnd := WinActive("ahk_exe Zoom.exe")
    if !hwnd
        return
    started := A_TickCount
    MouseGetPos &initialX, &initialY
    viewport := ZoomViewport(hwnd)
    if !IsObject(viewport) {
        SendEvent "{" key "}"
        return
    }
    wx := viewport.x, wy := viewport.y, ww := viewport.w, wh := viewport.h
    parked := false
    ; Hover styling, large pointers and pointer highlights can hide the icon.
    ; Move away without clicking before reading it, then restore the pointer.
    if initialY > wy + wh * 0.3 && initialY < wy + wh * 0.7
        && (Abs(initialX - wx) < 110 || Abs(initialX - wx - ww) < 110) {
        MouseMove wx + ww // 2, wy + wh // 4, 0
        parked := true
        Sleep 100
    }
    try NavigateVisible(hwnd, direction, key, started)
    finally {
        if parked {
            MouseGetPos &mx, &my
            if Abs(mx - (wx + ww // 2)) <= 2 && Abs(my - (wy + wh // 4)) <= 2
                MouseMove initialX, initialY, 0
        }
    }
}

NavigateVisible(hwnd, direction, key, started) {
    global lastClick, navEnabled
    pair := FindNavigation(hwnd)
    if !IsObject(pair) {
        Log("no navigation pair; key passed through")
        ; Preserve normal editing/navigation when the gallery is not detected.
        if WinActive("ahk_id " hwnd)
            SendEvent "{" key "}"
        return
    }
    target := pair.%direction%
    if !target.enabled {
        Log(direction " disabled")
        ShowStatus(direction = "left" ? "First page" : "Last page")
        return
    }
    ; Prevent rapid clicks from being interpreted as a double click by Zoom.
    remaining := DllCall("GetDoubleClickTime", "uint") + 80 - (A_TickCount - lastClick)
    if remaining > 0
        Sleep remaining
    if GetKeyState("LButton", "P") || GetKeyState("RButton", "P")
        return
    if !navEnabled || !WinActive("ahk_id " hwnd) || !TargetWindowAt(target.x, target.y, hwnd)
        return
    MouseGetPos &oldX, &oldY
    down := false
    try {
        ; Verify BEFORE moving onto the icon: hover effects may change its
        ; colour, and pointer highlighters may cover the triangle completely.
        confirmed := FindNavigation(hwnd)
        if !IsObject(confirmed) || !navEnabled || !WinActive("ahk_id " hwnd) || PreserveFocusedArrows()
            return
        current := confirmed.%direction%
        MouseGetPos &mx, &my
        if (!current.enabled || Abs(current.x - target.x) > 2 || Abs(current.y - target.y) > 2
            || confirmed.x != pair.x || confirmed.y != pair.y || confirmed.w != pair.w || confirmed.h != pair.h
            || Abs(mx - oldX) > 2 || Abs(my - oldY) > 2
            || !TargetWindowAt(target.x, target.y, hwnd))
            return
        MouseMove target.x, target.y, 0
        Sleep 80
        MouseGetPos &mx, &my
        if !navEnabled || !WinActive("ahk_id " hwnd) || !TargetWindowAt(target.x, target.y, hwnd)
            || !SameViewport(pair, ZoomViewport(hwnd)) || PreserveFocusedArrows()
            || Abs(mx - target.x) > 2 || Abs(my - target.y) > 2 || GetKeyState("LButton", "P")
            return
        MouseClick "Left", target.x, target.y, 1, 0, "D"
        down := true
        Sleep 50
        MouseClick "Left",,, 1, 0, "U"
        down := false
        lastClick := A_TickCount
        Log(direction " click sent at " target.x "," target.y "; " (A_TickCount - started) " ms")
        Sleep 80
    } finally {
        if down
            MouseClick "Left",,, 1, 0, "U"
        MouseGetPos &mx, &my
        if Abs(mx - target.x) <= 2 && Abs(my - target.y) <= 2
            MouseMove oldX, oldY, 0
    }
}

ShowStatus(message) {
    try {
        WinGetPos &x, &y,,, "A"
        ToolTip message, x + 80, y + 80
        SetTimer () => ToolTip(), -1400
    }
}

Log(message) {
    global debug
    if debug
        try FileAppend FormatTime(, "HH:mm:ss") " " message "`n", A_ScriptDir "\navigation-debug.log", "UTF-8"
}
