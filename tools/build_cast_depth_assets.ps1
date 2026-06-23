Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$raw = Join-Path $root "assets\ui\cast_depth\psd_layers_raw"
$out = Join-Path $root "assets\ui\cast_depth"
$size = 1024

function Open-Bitmap($name) {
    $path = Join-Path $raw $name
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Missing PSD layer export: $name"
    }
    return [System.Drawing.Bitmap]::FromFile($path)
}

function New-Canvas {
    $bitmap = New-Object System.Drawing.Bitmap $size, $size, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceOver
    $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    return @{ Bitmap = $bitmap; Graphics = $graphics }
}

function Draw-Layer($canvas, $name, $alpha = 1.0) {
    $image = Open-Bitmap $name
    try {
        $dest = New-Object System.Drawing.Rectangle 0, 0, $size, $size
        if ($alpha -ge 0.999) {
            $canvas.Graphics.DrawImage($image, $dest)
        } else {
            $matrix = New-Object System.Drawing.Imaging.ColorMatrix
            $matrix.Matrix33 = [single]$alpha
            $attrs = New-Object System.Drawing.Imaging.ImageAttributes
            $attrs.SetColorMatrix($matrix, [System.Drawing.Imaging.ColorMatrixFlag]::Default, [System.Drawing.Imaging.ColorAdjustType]::Bitmap)
            $canvas.Graphics.DrawImage($image, $dest, 0, 0, $image.Width, $image.Height, [System.Drawing.GraphicsUnit]::Pixel, $attrs)
            $attrs.Dispose()
        }
    } finally {
        $image.Dispose()
    }
}

function Save-Canvas($canvas, $name) {
    $path = Join-Path $out $name
    $canvas.Bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $canvas.Graphics.Dispose()
    $canvas.Bitmap.Dispose()
}

function Save-Layers($name, $layers) {
    $canvas = New-Canvas
    foreach ($layer in $layers) {
        if ($layer -is [array]) {
            Draw-Layer $canvas $layer[0] $layer[1]
        } else {
            Draw-Layer $canvas $layer
        }
    }
    Save-Canvas $canvas $name
}

function Save-MetalTrack($name, $sourceLayer) {
    $source = Open-Bitmap $sourceLayer
    $canvas = New-Canvas
    try {
        $scaled = New-Object System.Drawing.Bitmap $size, $size, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $scaleGraphics = [System.Drawing.Graphics]::FromImage($scaled)
        $scaleGraphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $scaleGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $scaleGraphics.DrawImage($source, (New-Object System.Drawing.Rectangle 0, 0, $size, $size))
        $scaleGraphics.Dispose()

        for ($y = 0; $y -lt $size; $y++) {
            for ($x = 0; $x -lt $size; $x++) {
                $pixel = $scaled.GetPixel($x, $y)
                if ($pixel.A -le 0) {
                    continue
                }
                $brightness = [int](($pixel.R * 0.30) + ($pixel.G * 0.52) + ($pixel.B * 0.18))
                $value = [Math]::Max(78, [Math]::Min(190, $brightness))
                $alpha = [Math]::Max(0, [Math]::Min(255, [int]($pixel.A * 0.74)))
                $scaled.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($alpha, $value, [Math]::Min(210, $value + 12), [Math]::Min(215, $value + 16)))
            }
        }
        $canvas.Graphics.DrawImage($scaled, (New-Object System.Drawing.Rectangle 0, 0, $size, $size))
        $scaled.Dispose()
    } finally {
        $source.Dispose()
    }
    Save-Canvas $canvas $name
}

function Save-CenteredIcon($name, $sourceRelativePath) {
    $canvas = New-Canvas
    $sourcePath = Join-Path $root $sourceRelativePath
    if (-not (Test-Path -LiteralPath $sourcePath)) {
        throw "Missing icon source: $sourceRelativePath"
    }

    $image = [System.Drawing.Bitmap]::FromFile($sourcePath)
    try {
        $target = 250
        $dest = New-Object System.Drawing.Rectangle (($size - $target) / 2), 485, $target, $target
        $canvas.Graphics.DrawImage($image, $dest)
    } finally {
        $image.Dispose()
    }
    Save-Canvas $canvas $name
}

New-Item -ItemType Directory -Force -Path $out | Out-Null
New-Item -ItemType Directory -Force -Path $raw | Out-Null
Set-Content -LiteralPath (Join-Path $raw ".gdignore") -Value "" -NoNewline

Save-Layers "cast_button_base.png" @(
    "015_Group_3_copy_Group_1_copy.png",
    "016_Group_3_copy_Group_1.png",
    "031_Group_3_copy_Ellipse_1.png",
    "029_Group_3_copy_png-circular-brushed-metal-texture.png",
    "014_Group_3_copy_Ellipse_1_copy_3.png",
    "011_Group_3_copy_Ellipse_1_copy.png",
    "010_Group_3_copy_Ellipse_1_copy_2.png",
    "012_Group_3_copy_Ellipse_1_copy_4.png",
    "009_Group_3_copy_Ellipse_1_copy_7.png",
    "007_Group_3_copy_Vector_Smart_Object.png",
    "008_Group_3_copy_hex-backgrounds-networking.png",
    "013_Group_3_copy_Ellipse_1_copy_6.png"
)

Save-MetalTrack "cast_button_track.png" "030_Group_3_copy_Ellipse_1_copy_5.png"

Save-Layers "cast_button_blue_fill.png" @(
    "003_Group_3_copy_Ellipse_1_copy_8.png"
)

Save-Layers "cast_button_handle.png" @(
    "001_Group_3_copy_Ellipse_2.png",
    "002_Group_3_copy_Ellipse_2_copy.png"
)

Save-Layers "cast_icon_ready.png" @(
    "006_Group_3_copy_Group_2_Vector_Smart_Object.png"
)

Save-CenteredIcon "cast_icon_waiting.png" "assets\ui\icons\hud\action_hook_new.png"
Save-CenteredIcon "cast_icon_reeling.png" "assets\ui\icons\hud\action_pull_fish.png"

Write-Host "Built cast depth button assets in $out"
