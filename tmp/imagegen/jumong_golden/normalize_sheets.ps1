Add-Type -AssemblyName System.Drawing

function Test-KeyPixel([System.Drawing.Color]$color) {
    return ($color.G -ge 180 -and $color.R -le 110 -and $color.B -le 110 -and $color.G -ge ($color.R + 90) -and $color.G -ge ($color.B + 90))
}

function Export-Sheet([string]$sourcePath, [string]$outputPath) {
    $source = [System.Drawing.Bitmap]::new((Resolve-Path -LiteralPath $sourcePath).Path)
    try {
        $frameCount = 4
        $cellWidth = [int][Math]::Floor($source.Width / $frameCount)
        $output = [System.Drawing.Bitmap]::new(1536, 384, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        try {
            $graphics = [System.Drawing.Graphics]::FromImage($output)
            try {
                $graphics.Clear([System.Drawing.Color]::Transparent)
                $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
                $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
                $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
                $attributes = [System.Drawing.Imaging.ImageAttributes]::new()
                try {
                    $attributes.SetColorKey([System.Drawing.Color]::FromArgb(0, 180, 0), [System.Drawing.Color]::FromArgb(110, 255, 110))
                    for ($frame = 0; $frame -lt $frameCount; $frame++) {
                        $left = $frame * $cellWidth
                        $right = if ($frame -eq 3) { $source.Width - 1 } else { (($frame + 1) * $cellWidth) - 1 }
                        $minX = $right
                        $minY = $source.Height - 1
                        $maxX = $left
                        $maxY = 0
                        for ($y = 0; $y -lt $source.Height; $y += 2) {
                            for ($x = $left; $x -le $right; $x += 2) {
                                if (-not (Test-KeyPixel $source.GetPixel($x, $y))) {
                                    if ($x -lt $minX) { $minX = $x }
                                    if ($x -gt $maxX) { $maxX = $x }
                                    if ($y -lt $minY) { $minY = $y }
                                    if ($y -gt $maxY) { $maxY = $y }
                                }
                            }
                        }
                        $minX = [Math]::Max($left, $minX - 4)
                        $maxX = [Math]::Min($right, $maxX + 4)
                        $minY = [Math]::Max(0, $minY - 4)
                        $maxY = [Math]::Min($source.Height - 1, $maxY + 4)
                        $cropWidth = $maxX - $minX + 1
                        $cropHeight = $maxY - $minY + 1
                        $scale = [Math]::Min(350.0 / $cropHeight, 360.0 / $cropWidth)
                        $drawWidth = [int][Math]::Round($cropWidth * $scale)
                        $drawHeight = [int][Math]::Round($cropHeight * $scale)
                        $destX = ($frame * 384) + [int][Math]::Round((384 - $drawWidth) / 2)
                        $destY = 340 - $drawHeight
                        $dest = [System.Drawing.Rectangle]::new($destX, $destY, $drawWidth, $drawHeight)
                        $src = [System.Drawing.Rectangle]::new($minX, $minY, $cropWidth, $cropHeight)
                        $graphics.DrawImage($source, $dest, $src.X, $src.Y, $src.Width, $src.Height, [System.Drawing.GraphicsUnit]::Pixel, $attributes)
                    }
                } finally {
                    $attributes.Dispose()
                }
            } finally {
                $graphics.Dispose()
            }
            $output.Save((Join-Path (Resolve-Path -LiteralPath (Split-Path -Parent $outputPath)).Path (Split-Path -Leaf $outputPath)), [System.Drawing.Imaging.ImageFormat]::Png)
        } finally {
            $output.Dispose()
        }
    } finally {
        $source.Dispose()
    }
}

Export-Sheet 'tmp\imagegen\jumong_golden\idle_source.png' 'assets\characters\jumong\golden\jumong_gold_idle_sheet_v1.png'
Export-Sheet 'tmp\imagegen\jumong_golden\walk_source.png' 'assets\characters\jumong\golden\jumong_gold_walk_front_sheet_v1.png'
Export-Sheet 'tmp\imagegen\jumong_golden\shot_source.png' 'assets\characters\jumong\golden\jumong_gold_basic_shot_sheet_v1.png'
