param(
    [string]$ApkPath = "build\RybnoeMesto_0.1.0-beta.3.apk",
    [string]$BuildToolsPath = "$env:LOCALAPPDATA\Android\Sdk\build-tools\35.0.1",
    [string]$KeystorePath = "$env:APPDATA\Godot\keystores\debug.keystore",
    [string]$StorePass = "android",
    [string]$KeyAlias = "androiddebugkey",
    [string]$KeyPass = "android"
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$apkFullPath = if ([System.IO.Path]::IsPathRooted($ApkPath)) {
    $ApkPath
} else {
    Join-Path $repoRoot $ApkPath
}

$zipalign = Join-Path $BuildToolsPath "zipalign.exe"
$apksigner = Join-Path $BuildToolsPath "apksigner.bat"
$aapt2 = Join-Path $BuildToolsPath "aapt2.exe"

foreach ($path in @($apkFullPath, $zipalign, $apksigner, $aapt2, $KeystorePath)) {
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Required file not found: $path"
    }
}

$iconEntryName = "res/mipmap-anydpi-v26/icon.xml"
$themedEntryName = "res/mipmap-anydpi-v26/themed_icon.xml"

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$readZip = [System.IO.Compression.ZipFile]::OpenRead($apkFullPath)
try {
    $hasIcon = $null -ne $readZip.GetEntry($iconEntryName)
    $hasThemedIcon = $null -ne $readZip.GetEntry($themedEntryName)
} finally {
    $readZip.Dispose()
}

if (-not $hasIcon) {
    throw "APK does not contain $iconEntryName"
}

if (-not $hasThemedIcon) {
    $workDir = Join-Path $repoRoot ".tmp\android-themed-icon-patch"
    New-Item -ItemType Directory -Force -Path $workDir | Out-Null

    $unalignedApk = Join-Path $workDir "themed_icon_unaligned.apk"
    $alignedApk = Join-Path $workDir "themed_icon_aligned.apk"
    $signedApk = Join-Path $workDir "themed_icon_signed.apk"

    Copy-Item -Force -LiteralPath $apkFullPath -Destination $unalignedApk

    $updateZip = [System.IO.Compression.ZipFile]::Open($unalignedApk, [System.IO.Compression.ZipArchiveMode]::Update)
    try {
        $sourceEntry = $updateZip.GetEntry($iconEntryName)
        $destEntry = $updateZip.CreateEntry($themedEntryName, [System.IO.Compression.CompressionLevel]::Optimal)
        $sourceStream = $sourceEntry.Open()
        $destStream = $destEntry.Open()
        try {
            $sourceStream.CopyTo($destStream)
        } finally {
            $destStream.Dispose()
            $sourceStream.Dispose()
        }
    } finally {
        $updateZip.Dispose()
    }

    & $zipalign -f -p 4 $unalignedApk $alignedApk
    if ($LASTEXITCODE -ne 0) {
        throw "zipalign failed with exit code $LASTEXITCODE"
    }

    & $apksigner sign --ks $KeystorePath --ks-pass "pass:$StorePass" --ks-key-alias $KeyAlias --key-pass "pass:$KeyPass" --out $signedApk $alignedApk
    if ($LASTEXITCODE -ne 0) {
        throw "apksigner sign failed with exit code $LASTEXITCODE"
    }

    Copy-Item -Force -LiteralPath $signedApk -Destination $apkFullPath
    Write-Host "Added $themedEntryName and re-signed APK."
} else {
    Write-Host "$themedEntryName already exists."
}

$badging = & $aapt2 dump badging $apkFullPath 2>&1 | Out-String
if ($LASTEXITCODE -ne 0) {
    throw "aapt2 dump badging failed with exit code $LASTEXITCODE"
}
if ($badging -match "themed_icon.*no such path") {
    throw "APK still has missing themed_icon resource."
}

& $apksigner verify --verbose --print-certs $apkFullPath
if ($LASTEXITCODE -ne 0) {
    throw "apksigner verify failed with exit code $LASTEXITCODE"
}

Write-Host "APK themed icon resource and signature verified."
