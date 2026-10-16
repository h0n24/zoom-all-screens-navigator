#Requires AutoHotkey v2.0
#Include ..\lib\UpdateChecker.ahk
checks := 0
try {
    for sample in ['0.6.2', '1.0.0', '10.20.300', ' 0.6.2`r`n']
        Assert(IsObject(ParseReleaseVersion(sample)), 'valid version')
    for sample in ['', 'v0.6.2', '0.6', '0.6.2-beta', '0.6.2 extra', '<html>error</html>', 'https://example.com', '1.2.3`n4.5.6']
        Assert(!ParseReleaseVersion(sample), 'reject invalid response')
    Assert(ReleaseCheckResult(200, '0.6.3', '0.6.2') = 'newer', 'patch update')
    Assert(ReleaseCheckResult(200, '0.10.0', '0.6.2') = 'newer', 'numeric minor update')
    Assert(ReleaseCheckResult(200, '1.0.0', '0.6.2') = 'newer', 'major update')
    Assert(ReleaseCheckResult(200, '0.6.2', '0.6.2') = 'current', 'equal')
    Assert(ReleaseCheckResult(200, '0.6.1', '0.6.2') = 'current', 'no downgrade')
    Assert(ReleaseCheckResult(404, '0.6.3', '0.6.2') = 'error', 'HTTP failure')
    Assert(ReleaseCheckResult(200, 'invalid', '0.6.2') = 'error', 'malformed body')
    Assert(Trim(FileRead(A_ScriptDir '\..\VERSION'), ' `t`r`n') = '0.6.3', 'release marker matches application')
    probe := ProbeChecker(FakeRequest(false))
    probe.Poll()
    Assert(probe.result = '', 'pending request returns without completion')
    probe := ProbeChecker(FakeRequest(false), 16000)
    probe.Poll()
    Assert(probe.result = 'error', 'timeout ends request')
    probe := ProbeChecker(FakeRequest(true, 200, '0.6.3'))
    probe.Poll()
    Assert(probe.result = 'newer', 'asynchronous update response')
    probe := ProbeChecker(FakeRequest(true, 503, 'unavailable'))
    probe.Poll()
    Assert(probe.result = 'error', 'HTTP error ends request')
    probe := ProbeChecker(FakeRequest(true, 200, '0.6.2'))
    probe.Poll()
    Assert(probe.result = 'current', 'asynchronous current response')
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

class ProbeChecker extends UpdateChecker {
    __New(request, elapsed := 0) {
        this.request := request
        this.started := A_TickCount - elapsed
        this.version := '0.6.2'
        this.result := ''
    }
    Finish(result, version := '') {
        this.result := result
    }
}
class FakeRequest {
    __New(ready, status := 200, body := '') {
        this.ready := ready
        this.Status := status
        this.ResponseText := body
    }
    WaitForResponse(timeout) => this.ready
}
