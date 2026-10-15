#Requires AutoHotkey v2.0

; Only stable numeric versions are accepted; never execute remote content.
ParseReleaseVersion(text) {
    text := Trim(text, ' `t`r`n')
    if !RegExMatch(text, '^([0-9]{1,4})\.([0-9]{1,4})\.([0-9]{1,4})$', &m)
        return false
    return [Integer(m[1]), Integer(m[2]), Integer(m[3])]
}

ReleaseCheckResult(status, body, current) {
    remote := ParseReleaseVersion(body), installed := ParseReleaseVersion(current)
    if status != 200 || !IsObject(remote) || !IsObject(installed)
        return 'error'
    Loop 3 {
        if remote[A_Index] > installed[A_Index]
            return 'newer'
        if remote[A_Index] < installed[A_Index]
            return 'current'
    }
    return 'current'
}

class UpdateChecker {
    __New(version) {
        this.version := version
        this.request := false
        this.manual := false
        this.notified := ''
        this.downloadLabel := 'Download latest version'
        this.settings := A_AppData '\ZoomNavigator\settings.ini'
        this.automatic := IniRead(this.settings, 'Updates', 'Automatic', '1') != '0'
        this.pollCallback := ObjBindMethod(this, 'Poll')
        this.dailyCallback := ObjBindMethod(this, 'Check')
        A_TrayMenu.Add('Check for updates', (*) => this.Check(true))
        A_TrayMenu.Add(this.downloadLabel, (*) => Run('https://github.com/h0n24/zoom-all-screens-navigator/releases/latest'))
        A_TrayMenu.Add('Automatic update checks', (*) => this.ToggleAutomatic())
        if this.automatic {
            A_TrayMenu.Check('Automatic update checks')
            SetTimer this.dailyCallback, -3000
        }
    }

    ToggleAutomatic() {
        this.automatic := !this.automatic
        A_TrayMenu.ToggleCheck('Automatic update checks')
        try {
            DirCreate A_AppData '\ZoomNavigator'
            IniWrite this.automatic ? '1' : '0', this.settings, 'Updates', 'Automatic'
        }
        SetTimer this.dailyCallback, 0
        if this.automatic
            this.Check()
        else if IsObject(this.request) && !this.manual
            this.StopRequest()
    }

    Check(manual := false) {
        if IsObject(this.request) {
            this.manual := this.manual || manual
            return
        }
        if !manual && !this.automatic
            return
        this.manual := manual
        if this.automatic
            SetTimer this.dailyCallback, -86400000
        try {
            this.request := ComObject('WinHttp.WinHttpRequest.5.1')
            this.request.SetTimeouts(3000, 3000, 3000, 5000)
            this.request.Open('GET', 'https://raw.githubusercontent.com/h0n24/zoom-all-screens-navigator/main/VERSION', true)
            this.request.SetRequestHeader('User-Agent', 'Zoom-All-Screens-Navigator/' this.version)
            this.request.SetRequestHeader('Cache-Control', 'no-cache')
            this.started := A_TickCount
            this.request.Send()
            SetTimer this.pollCallback, 200
        } catch {
            this.Finish('error')
        }
    }

    Poll() {
        try {
            if !this.request.WaitForResponse(0) {
                if A_TickCount - this.started > 15000
                    this.Finish('error')
                return
            }
            body := this.request.ResponseText
            result := ReleaseCheckResult(this.request.Status, body, this.version)
            this.Finish(result, result = 'error' ? '' : Trim(body, ' `t`r`n'))
        } catch {
            this.Finish('error')
        }
    }

    Finish(result, version := '') {
        this.StopRequest()
        if result = 'newer' && (this.manual || this.notified != version) {
            this.notified := version
            label := 'Update available: ' version ' (download)'
            A_TrayMenu.Rename(this.downloadLabel, label)
            this.downloadLabel := label
            TrayTip 'Version ' version ' is available. Right-click the tray icon and choose Update available to download it.', 'Zoom Navigator update', 1
        } else if this.manual {
            TrayTip result = 'error' ? 'Could not check for updates. Try again later.' : 'You are up to date (version ' this.version ').', 'Zoom Navigator', 1
        }
    }

    StopRequest() {
        SetTimer this.pollCallback, 0
        if IsObject(this.request)
            try this.request.Abort()
        this.request := false
    }
}
