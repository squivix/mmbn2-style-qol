# Builds a ROM hack: copies the clean ROM named in projects\<name>\base_rom.txt,
# assembles projects\<name>\main.asm into the copy, and writes a BPS patch.
#
#   .\tools\build.ps1 mygame              -> build\mygame.gba + build\mygame.bps
#   .\tools\build.ps1 mygame -Run         -> also launches it in mGBA
#
# base_rom.txt holds either one ROM name, or one "<region> <rom>" line per target:
#   us bn1_us.gba
#   eu bn1_eu.gba
# Each target builds to build\<name>_<region>.gba/.bps, and main.asm sees REGION ("us", "eu").
#   .\tools\build.ps1 mygame -Region eu   -> only that target (-Run launches the first one built)
param(
    [Parameter(Mandatory)] [string] $Project,
    [string] $Region,
    [switch] $Run
)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$projDir = Join-Path $root "projects\$Project"
New-Item -ItemType Directory -Force (Join-Path $root 'build') | Out-Null

$targets = foreach ($line in Get-Content (Join-Path $projDir 'base_rom.txt')) {
    $parts = -split $line
    if ($parts.Count -eq 1) { [pscustomobject]@{ Region = ''; Rom = $parts[0] } }
    elseif ($parts.Count -eq 2) { [pscustomobject]@{ Region = $parts[0]; Rom = $parts[1] } }
}
if ($Region) {
    $targets = @($targets | Where-Object Region -eq $Region)
    if (-not $targets) { throw "No target '$Region' in base_rom.txt" }
}

# Optional per-project generator step (e.g. graphics/data -> .bin files main.asm imports).
$prebuild = Join-Path $projDir 'prebuild.py'
if (Test-Path $prebuild) {
    python $prebuild
    if ($LASTEXITCODE) { throw "prebuild.py failed ($LASTEXITCODE)" }
}

$built = @()
foreach ($t in $targets) {
    $baseRom = Join-Path $root "roms\$($t.Rom)"
    if (-not (Test-Path $baseRom)) { throw "Base ROM not found: $baseRom" }
    $name = if ($t.Region) { "${Project}_$($t.Region)" } else { $Project }
    $outRom = Join-Path $root "build\$name.gba"
    $outBps = Join-Path $root "build\$name.bps"
    # Delete old outputs up front: if an emulator still has the ROM open this fails loudly,
    # instead of armips "succeeding" while the stale ROM stays in place.
    foreach ($f in $outRom, $outBps) {
        if (Test-Path $f) {
            try { Remove-Item $f -Force -ErrorAction Stop }
            catch { throw "Cannot replace $f (is it open in an emulator?)" }
        }
    }
    Write-Host ("[$name] base ROM sha1: " + (Get-FileHash $baseRom -Algorithm SHA1).Hash.ToLower())

    # main.asm sees ROM_IN / ROM_OUT and should start with: .open ROM_IN, ROM_OUT, 0x08000000
    # armips opens ROM_IN writable, so give it a scratch copy and keep roms\ read-only.
    $tmpIn = Join-Path $root "build\$name.base.tmp"
    Copy-Item $baseRom $tmpIn -Force
    Set-ItemProperty $tmpIn -Name IsReadOnly -Value $false
    $defs = @('-strequ', 'ROM_IN', $tmpIn, '-strequ', 'ROM_OUT', $outRom)
    if ($t.Region) { $defs += '-strequ', 'REGION', $t.Region }
    Push-Location $projDir
    try {
        & "$root\tools\armips\armips.exe" main.asm @defs -sym (Join-Path $root "build\$name.sym")
        if ($LASTEXITCODE) { throw "armips failed ($LASTEXITCODE)" }
    } finally { Pop-Location; Remove-Item $tmpIn -Force -ErrorAction SilentlyContinue }

    & "$root\tools\flips\flips.exe" --create --bps-delta $baseRom $outRom $outBps | Out-Null
    if ($LASTEXITCODE -gt 1) { throw "flips failed ($LASTEXITCODE)" }
    Write-Host "Built $outRom`nPatch $outBps"
    $built += $outRom
}

if ($Run) { Start-Process "$root\tools\mgba\mGBA-0.10.5-win64\mGBA.exe" -ArgumentList "`"$($built[0])`"" }
