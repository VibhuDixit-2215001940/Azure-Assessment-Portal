# =====================================================================
#  Azure Assessment Portal - Base64 Script Obfuscation Builder
#  This script reads scripts from 'scripts_src/', encodes them,
#  and outputs the secure wrapper files in 'scripts/'
# =====================================================================

$srcDir = "$PSScriptRoot\scripts_src"
$destDir = "$PSScriptRoot\scripts"

# Ensure directories exist
if (-not (Test-Path $srcDir)) {
    Write-Error "Source directory '$srcDir' does not exist."
    exit 1
}

if (-not (Test-Path $destDir)) {
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
}

# Get all PowerShell scripts in the source directory
$files = Get-ChildItem -Path $srcDir -Filter *.ps1

foreach ($file in $files) {
    Write-Host "Encoding '$($file.Name)'..." -ForegroundColor Cyan

    # 1. Read raw code of source script (using UTF-8 to preserve unicode/emojis)
    $originalCode = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)

    # 2. Convert raw script content to UTF-8 bytes and then Base64
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($originalCode)
    $base64String = [System.Convert]::ToBase64String($bytes)

    # 3. Create the secure wrapper
    $wrapperCode = "[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('$base64String')) | Invoke-Expression"

    # 4. Save the wrapper script to the destination directory
    $destPath = Join-Path $destDir $file.Name
    [System.IO.File]::WriteAllText($destPath, $wrapperCode, [System.Text.Encoding]::UTF8)

    Write-Host "Successfully generated secure wrapper at '$destPath'" -ForegroundColor Green
}

Write-Host "`nBuild complete! Obfuscated scripts are ready." -ForegroundColor Green
