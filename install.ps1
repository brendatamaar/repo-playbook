# Pasang skill repo-playbook ke sebuah project (Windows PowerShell 5.1+ / PowerShell 7+).
# Pemakaian: powershell -ExecutionPolicy Bypass -File install.ps1 <path-project>
param([Parameter(Mandatory = $true)][string]$Target)
$ErrorActionPreference = 'Stop'

$Src = $PSScriptRoot
$StartMark = '<!-- repo-playbook:start'
$EndMark = '<!-- repo-playbook:end -->'
$Utf8 = New-Object System.Text.UTF8Encoding($false)

if (-not (Test-Path -LiteralPath $Target -PathType Container)) {
  throw "Folder tidak ditemukan: $Target"
}
$Target = (Resolve-Path -LiteralPath $Target).Path
if ($Target -eq (Resolve-Path -LiteralPath $Src).Path) {
  throw 'Target tidak boleh repo-playbook itu sendiri.'
}
if (-not (Test-Path -LiteralPath (Join-Path $Target '.git'))) {
  Write-Warning "$Target bukan root repo git. Lanjut tetap memasang."
}

function Read-Text($path) { [System.IO.File]::ReadAllText($path) }
function Write-Text($path, $text) { [System.IO.File]::WriteAllText($path, $text, $Utf8) }

# 1. Skill: salin ke .agents/skills dan .claude/skills. Skill lain tidak disentuh.
$skillDirs = Get-ChildItem -LiteralPath (Join-Path $Src 'skills') -Directory
foreach ($dest in @('.agents/skills', '.claude/skills')) {
  $destRoot = Join-Path $Target $dest
  New-Item -ItemType Directory -Force -Path $destRoot | Out-Null
  foreach ($dir in $skillDirs) {
    $to = Join-Path $destRoot $dir.Name
    if (Test-Path -LiteralPath $to) { Remove-Item -LiteralPath $to -Recurse -Force }
    Copy-Item -LiteralPath $dir.FullName -Destination $to -Recurse
  }
}

# 2. File pendukung.
$pb = Join-Path $Target '.agents/playbook'
New-Item -ItemType Directory -Force -Path $pb | Out-Null
Copy-Item -LiteralPath (Join-Path $Src 'shared/formats.md') -Destination (Join-Path $pb 'formats.md') -Force
$routing = Join-Path $pb 'routing.md'
if (-not (Test-Path -LiteralPath $routing)) {
  Copy-Item -LiteralPath (Join-Path $Src 'shared/routing.md') -Destination $routing
  $routingNote = 'dibuat'
} else {
  $routingNote = 'dipertahankan (milik project)'
}
$version = 'unknown'
try { $v = (& git -C $Src rev-parse --short HEAD 2>$null); if ($LASTEXITCODE -eq 0 -and $v) { $version = $v.Trim() } } catch {}
Write-Text (Join-Path $pb 'VERSION') ($version + "`n")

# 3. AGENTS.md
$section = (Read-Text (Join-Path $Src 'templates/agents-section.md')).Replace("`r`n", "`n")
$agents = Join-Path $Target 'AGENTS.md'
if (-not (Test-Path -LiteralPath $agents)) {
  $header = "# Agent rules`n`n<!-- Stack, perintah test/lint/build, dan konvensi: diisi oleh skill phase-setup-new / phase-setup-existing. -->`n`n"
  Write-Text $agents ($header + $section)
  $agentsNote = 'dibuat'
} else {
  $text = Read-Text $agents
  $si = $text.IndexOf($StartMark)
  if ($si -ge 0) {
    $ei = $text.IndexOf($EndMark, $si)
    if ($ei -lt 0) { throw 'AGENTS.md punya penanda start tanpa penanda end. Perbaiki manual dulu.' }
    $after = $ei + $EndMark.Length
    # buang satu line break setelah penanda end; section sudah diakhiri newline
    if ($text.Substring($after).StartsWith("`r`n")) { $after += 2 } elseif ($text.Substring($after).StartsWith("`n")) { $after += 1 }
    Write-Text $agents ($text.Substring(0, $si) + $section + $text.Substring($after))
    $agentsNote = 'blok repo-playbook diperbarui'
  } else {
    Write-Text $agents ($text + "`n" + $section)
    $agentsNote = 'blok repo-playbook ditambahkan di akhir (isi lama dipertahankan)'
  }
}

# 4. CLAUDE.md
$claude = Join-Path $Target 'CLAUDE.md'
if (-not (Test-Path -LiteralPath $claude)) {
  Write-Text $claude "@AGENTS.md`n"
  $claudeNote = 'dibuat'
} else {
  $ctext = Read-Text $claude
  if ($ctext -match '(?m)^@AGENTS\.md\r?$') {
    $claudeNote = 'sudah mengimpor AGENTS.md'
  } else {
    Write-Text $claude ("@AGENTS.md`n`n" + $ctext)
    $claudeNote = 'baris @AGENTS.md ditambahkan di atas (isi lama dipertahankan)'
  }
}

$names = ($skillDirs | ForEach-Object { $_.Name }) -join ' '
Write-Output "repo-playbook $version terpasang di $Target"
Write-Output "  skills      : $names"
Write-Output "  lokasi      : .agents/skills/ dan .claude/skills/"
Write-Output "  routing.md  : $routingNote"
Write-Output "  AGENTS.md   : $agentsNote"
Write-Output "  CLAUDE.md   : $claudeNote"
Write-Output ''
Write-Output 'Berikutnya:'
Write-Output '  1. Review perubahan: git status ; git diff'
Write-Output "  2. Commit: git add .agents .claude AGENTS.md CLAUDE.md ; git commit -m `"chore: install repo-playbook $version`""
Write-Output '  3. Jalankan skill phase-setup-new (project baru) atau phase-setup-existing (project berjalan).'
