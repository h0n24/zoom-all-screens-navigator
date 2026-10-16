param(
    [Parameter(Mandatory = $true)][string]$Compiler,
    [Parameter(Mandatory = $true)][string]$RuntimeSourceZip,
    [string]$Runtime = 'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe',
    [string]$RuntimeLicense = 'C:\Program Files\AutoHotkey\license.txt'
)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$version = (Get-Content (Join-Path $root 'VERSION') -Raw).Trim()
if ($version -notmatch '^\d+\.\d+\.\d+$') { throw 'Invalid VERSION' }
$compilerPath = (Resolve-Path -LiteralPath $Compiler).Path
$runtimePath = (Resolve-Path -LiteralPath $Runtime).Path
$sourcePath = (Resolve-Path -LiteralPath $RuntimeSourceZip).Path
$licensePath = (Resolve-Path -LiteralPath $RuntimeLicense).Path
$runtimeVersion = (Get-Item -LiteralPath $runtimePath).VersionInfo.ProductVersion
if ($runtimeVersion -ne '2.0.30') { throw 'Review runtime source and notices before changing the pinned AutoHotkey 2.0.30 runtime.' }
$output = Join-Path $root "dist/$version"
New-Item -ItemType Directory -Force -Path $output | Out-Null
$exe = Join-Path $output "ZoomNavigator-$version-windows-x64.exe"
if (Test-Path -LiteralPath $exe) { throw "Build already exists: $exe. Use a fresh release output directory." }
$entry = Join-Path $root 'ZoomNavigator.ahk'
$arguments = '/in "{0}" /out "{1}" /base "{2}" /compress 0 /silent verbose' -f $entry, $exe, $runtimePath
$process = Start-Process -FilePath $compilerPath -ArgumentList $arguments -WindowStyle Hidden -Wait -PassThru
if ($process.ExitCode -ne 0 -or !(Test-Path -LiteralPath $exe)) { throw 'Ahk2Exe compilation failed' }
Copy-Item -LiteralPath $sourcePath -Destination (Join-Path $output 'AutoHotkey-v2.0.30-source.zip')
Copy-Item -LiteralPath $licensePath -Destination (Join-Path $output 'AutoHotkey-LICENSE.txt')
$checksums = Get-ChildItem -LiteralPath $output -File | Where-Object Name -ne 'SHA256SUMS.txt' | Sort-Object Name | ForEach-Object {
    '{0}  {1}' -f (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant(), $_.Name
}
$checksums | Set-Content (Join-Path $output 'SHA256SUMS.txt') -Encoding ascii
Write-Output $exe
Write-Output $checksums
