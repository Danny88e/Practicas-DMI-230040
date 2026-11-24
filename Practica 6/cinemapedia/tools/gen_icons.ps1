param([string]$Logo = "assets/logos/Cinemapedia_logo.png")

Add-Type -AssemblyName System.Drawing
$ErrorActionPreference = "Stop"

$src = [System.Drawing.Bitmap]::FromFile((Resolve-Path $Logo))
Write-Host "Logo: $($src.Width) x $($src.Height) ($($src.PixelFormat))"

# ---------- 1) Detectar bounding box del badge (zona oscura) ----------
function Test-Dark([System.Drawing.Color]$c) { return (($c.R + $c.G + $c.B) -lt 450) }

$midY = [int]($src.Height / 2)
$midX = [int]($src.Width / 2)

$x0 = 0;    while ($x0 -lt $src.Width  -and -not (Test-Dark $src.GetPixel($x0, $midY))) { $x0++ }
$x1 = $src.Width - 1; while ($x1 -gt 0 -and -not (Test-Dark $src.GetPixel($x1, $midY))) { $x1-- }
$y0 = 0;    while ($y0 -lt $src.Height -and -not (Test-Dark $src.GetPixel($midX, $y0))) { $y0++ }
$y1 = $src.Height - 1; while ($y1 -gt 0 -and -not (Test-Dark $src.GetPixel($midX, $y1))) { $y1-- }

$bw = $x1 - $x0 + 1; $bh = $y1 - $y0 + 1
Write-Host "Badge bbox: x0=$x0 y0=$y0 x1=$x1 y1=$y1 ($bw x $bh)"

# ---------- 2) Color de fondo muestreado del borde interior del badge ----------
$sampleX = $x0 + [int]($bw * 0.06)
$samples = @()
foreach ($fy in @(0.15, 0.35, 0.5, 0.65, 0.85)) {
  $p = $src.GetPixel($sampleX, ($y0 + [int]($bh * $fy)))
  if ($p.A -eq 255) { $samples += $p }
}
$avgR = [int](($samples | Measure-Object -Property R -Average).Average)
$avgG = [int](($samples | Measure-Object -Property G -Average).Average)
$avgB = [int](($samples | Measure-Object -Property B -Average).Average)
$bgHex = "#{0:X2}{1:X2}{2:X2}" -f $avgR, $avgG, $avgB
Write-Host "Fondo adaptive icon: $bgHex"

# ---------- 3) Helper: icono con badge recortado en esquinas redondeadas ----------
function RoundedRectPath([double]$x, [double]$y, [double]$w, [double]$h, [double]$r) {
  $p = New-Object System.Drawing.Drawing2D.GraphicsPath
  $p.AddArc($x, $y, 2*$r, 2*$r, 180, 90)
  $p.AddArc($x + $w - 2*$r, $y, 2*$r, 2*$r, 270, 90)
  $p.AddArc($x + $w - 2*$r, $y + $h - 2*$r, 2*$r, 2*$r, 0, 90)
  $p.AddArc($x, $y + $h - 2*$r, 2*$r, 2*$r, 90, 90)
  $p.CloseFigure()
  return $p
}

# legacy: badge a sangre completa sobre fondo solido (esquinas via clip)
# foreground: badge al 66% (zona segura adaptive) sobre lienzo transparente
function New-Icon([int]$size, [bool]$fullBleed, [double]$scale, [string]$outPath) {
  $bmp = New-Object System.Drawing.Bitmap($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  if ($fullBleed) { $g.Clear([System.Drawing.Color]::FromArgb(255, $script:avgR, $script:avgG, $script:avgB)) }
  else { $g.Clear([System.Drawing.Color]::Transparent) }

  $target = [int]($size * $scale)
  $off = [int](($size - $target) / 2)
  $r = $target * 0.14
  $path = RoundedRectPath $off $off $target $target $r
  $g.SetClip($path)
  $srcRect = New-Object System.Drawing.Rectangle($script:x0, $script:y0, $script:bw, $script:bh)
  $dstRect = New-Object System.Drawing.RectangleF($off, $off, $target, $target)
  $g.DrawImage($src, $dstRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
  $g.ResetClip()
  $g.Dispose()
  $bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
  $bmp.Dispose()
  Write-Host "  -> $outPath ($size px)"
}

$resDir = "android/app/src/main/res"

# ---------- 4) Iconos legacy (pre API 26) ----------
Write-Host "Legacy ic_launcher.png:"
New-Icon 48  $true 1.0 "$resDir/mipmap-mdpi/ic_launcher.png"
New-Icon 72  $true 1.0 "$resDir/mipmap-hdpi/ic_launcher.png"
New-Icon 96  $true 1.0 "$resDir/mipmap-xhdpi/ic_launcher.png"
New-Icon 144 $true 1.0 "$resDir/mipmap-xxhdpi/ic_launcher.png"
New-Icon 192 $true 1.0 "$resDir/mipmap-xxxhdpi/ic_launcher.png"

# ---------- 5) Foreground adaptive (108dp) ----------
Write-Host "Adaptive ic_launcher_foreground.png:"
New-Icon 108 $false 0.66 "$resDir/mipmap-mdpi/ic_launcher_foreground.png"
New-Icon 162 $false 0.66 "$resDir/mipmap-hdpi/ic_launcher_foreground.png"
New-Icon 216 $false 0.66 "$resDir/mipmap-xhdpi/ic_launcher_foreground.png"
New-Icon 324 $false 0.66 "$resDir/mipmap-xxhdpi/ic_launcher_foreground.png"
New-Icon 432 $false 0.66 "$resDir/mipmap-xxxhdpi/ic_launcher_foreground.png"

# ---------- 6) Adaptive icon XML + color ----------
New-Item -ItemType Directory -Force -Path "$resDir/mipmap-anydpi-v26" | Out-Null
@"
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
"@ | Out-File -Encoding ascii "$resDir/mipmap-anydpi-v26/ic_launcher.xml"

@"
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">$bgHex</color>
</resources>
"@ | Out-File -Encoding ascii "$resDir/values/colors.xml"

Write-Host "OK: adaptive XML + colors.xml escritos"
$src.Dispose()
