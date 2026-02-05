param(
  [switch]$AutoUpgrade
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Repo RAW base
$RepoRawBase = "https://raw.githubusercontent.com/Lcamargodasilva/windows-setup/main"

# Cache local
$CacheRoot   = Join-Path $env:TEMP "windows-setup"
$LibDir      = Join-Path $CacheRoot "lib"
$ProfilesDir = Join-Path $CacheRoot "profiles"

function Ensure-Dirs {
  New-Item -ItemType Directory -Force -Path $CacheRoot   | Out-Null
  New-Item -ItemType Directory -Force -Path $LibDir      | Out-Null
  New-Item -ItemType Directory -Force -Path $ProfilesDir | Out-Null
}

function Download-File($url, $outFile) {
  Write-Host "⬇️  Baixando: $url" -ForegroundColor DarkCyan
  Invoke-WebRequest -Uri $url -OutFile $outFile -UseBasicParsing
}

function Sync-Scripts {
  Ensure-Dirs

  $files = @(
    @{ rel = "lib/winget.ps1"; out = (Join-Path $LibDir "winget.ps1") },

    @{ rel = "profiles/basic.ps1";     out = (Join-Path $ProfilesDir "basic.ps1") },
    @{ rel = "profiles/itsupport.ps1"; out = (Join-Path $ProfilesDir "itsupport.ps1") },
    @{ rel = "profiles/devfront.ps1";  out = (Join-Path $ProfilesDir "devfront.ps1") },
    @{ rel = "profiles/devback.ps1";   out = (Join-Path $ProfilesDir "devback.ps1") },
    @{ rel = "profiles/devops.ps1";    out = (Join-Path $ProfilesDir "devops.ps1") }
  )

  foreach ($f in $files) {
    Download-File "$RepoRawBase/$($f.rel)" $f.out
  }
}

function Run-Profile($scriptName) {
  $path = Join-Path $ProfilesDir $scriptName
  if (-not (Test-Path $path)) {
    Write-Host "Script não encontrado: $path" -ForegroundColor Red
    return
  }
  & $path -AutoUpgrade:$AutoUpgrade
}

Write-Host "`n🚀 Windows Setup (Winget)" -ForegroundColor Green
Sync-Scripts

while ($true) {
  Write-Host "`n========================================" -ForegroundColor Green
  Write-Host " Windows Setup — Menu Principal" -ForegroundColor Green
  Write-Host "========================================" -ForegroundColor Green
  Write-Host "1) Básicos (Usuário)"
  Write-Host "2) Suporte de TI"
  Write-Host "3) Dev Frontend"
  Write-Host "4) Dev Backend"
  Write-Host "5) DevOps / Infra"
  Write-Host "0) Sair`n"

  switch (Read-Host "Escolha uma opção") {
    "1" { Run-Profile "basic.ps1" }
    "2" { Run-Profile "itsupport.ps1" }
    "3" { Run-Profile "devfront.ps1" }
    "4" { Run-Profile "devback.ps1" }
    "5" { Run-Profile "devops.ps1" }
    "0" { break }
    default { Write-Host "Opção inválida." -ForegroundColor Red }
  }
}

Write-Host "`n✅ Setup finalizado." -ForegroundColor Green
