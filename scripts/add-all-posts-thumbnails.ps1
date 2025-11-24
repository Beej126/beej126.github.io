param(
  [string]$PostsPath = "..\_posts",
  [switch]$DryRun
)

Write-Host "Scanning $PostsPath"

$mdFiles = Get-ChildItem -Path $PostsPath -Filter *.md -File -ErrorAction Stop

$markdownImgRegex = [regex]'!\[[^\]]*\]\((?<url>(?:\{\{[^}]+\}\})?[^)\s]+)'
$htmlImgRegex     = [regex]'<img[^>]*\bsrc=["''](?<url>(?:\{\{[^}]+\}\})?[^"''>]+)'

foreach ($file in $mdFiles) {
  $lines = (Get-Content -LiteralPath $file.FullName -Raw -ErrorAction Stop -Encoding UTF8) -split "`r?`n"
  $frontMatterStart = $lines.IndexOf('---')
  if ($frontMatterStart -ne 0) {
    Write-Host "[SKIP] $($file.Name) (no leading front matter delimiter)" -ForegroundColor Yellow
    continue
  }
  $frontMatterEnd = ($lines | Select-Object -Index (1..($lines.Length-1))) |
    ForEach-Object { $_ } |
    Where-Object { $_ -eq '---' } |
    Select-Object -First 1

  if (-not $frontMatterEnd) {
    Write-Host "[SKIP] $($file.Name) (no closing front matter delimiter)" -ForegroundColor Yellow
    continue
  }

  $endIndex = ($lines | Select-Object -Index (1..($lines.Length-1))).IndexOf('---') + 1
  $yamlLines = $lines[1..($endIndex-1)]
  if ($yamlLines -match '^\s*thumbnail-img:') {
    Write-Host "[OK]   $($file.Name) (already has thumbnail-img)"
    continue
  }

  $bodyLines = $lines[($endIndex+1)..($lines.Length-1)]
  $bodyText = ($bodyLines -join "`n")

  $thumbUrl = $null

  $m1 = $markdownImgRegex.Match($bodyText)
  if ($m1.Success) {
    $thumbUrl = $m1.Groups['url'].Value
  } else {
    $m2 = $htmlImgRegex.Match($bodyText)
    if ($m2.Success) {
      $thumbUrl = $m2.Groups['url'].Value
    }
  }

  if (-not $thumbUrl) {
    Write-Host "[NONE] $($file.Name) (no image found)"
    continue
  }

  # Normalize possible surrounding spaces
  $thumbUrl = $thumbUrl.Trim()

  $insertLine = "thumbnail-img: $thumbUrl"
  Write-Host "[ADD]  $($file.Name) -> $thumbUrl" -ForegroundColor Green

  if (-not $DryRun) {
    # Insert before closing ---
    $newContent = @()
    $newContent += '---'
    $newContent += $yamlLines
    $newContent += $insertLine
    $newContent += '---'
    $newContent += $bodyLines

    $newContentString = ($newContent -join "`n")
    Set-Content -LiteralPath $file.FullName -Value $newContentString -NoNewline -Encoding UTF8
  }
}

Write-Host "Done. Use -DryRun to preview without writing."