param(
  [switch]$AutoUpgrade
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

if (-not (Get-Variable AutoUpgrade -ErrorAction SilentlyContinue)) {
  $AutoUpgrade = $false
}

# ===============================
# CONFIGURAÇaO DO REPOSITÓRIO
# ===============================
$RepoRawBase = "https://raw.githubusercontent.com/Lcamargodasilva/windows-setup/main"

# Cache local
$CacheRoot   = Join-Path $env:TEMP "windows-setup"
$LibDir      = Join-Path $CacheRoot "lib"
$ProfilesDir = Join-Path $CacheRoot "profiles"

# ===============================
# FUNÇÕES INTERNAS
# ===============================
function Ensure-Dirs {
  New-Item -ItemType Directory -Force -Path $CacheRoot   | Out-Null
  New-Item -ItemType Directory -Force -Path $LibDir      | Out-Null
  New-Item -ItemType Directory -Force -Path $ProfilesDir | Out-Null
}

function Download-File {
  param(
    [Parameter(Mandatory=$true)][string]$Url,
    [Parameter(Mandatory=$true)][string]$OutFile
  )

  Write-Host "⬇️  Baixando: $Url" -ForegroundColor DarkCyan
  Invoke-WebRequest -Uri $Url -OutFile $OutFile -UseBasicParsing
}

function Sync-Scripts {
  Ensure-Dirs

  $files = @(
    @{ rel = "lib/winget.ps1";         out = (Join-Path $LibDir "winget.ps1") },

    @{ rel = "profiles/basic.ps1";     out = (Join-Path $ProfilesDir "basic.ps1") },
    @{ rel = "profiles/itsupport.ps1"; out = (Join-Path $ProfilesDir "itsupport.ps1") },
    @{ rel = "profiles/devfront.ps1";  out = (Join-Path $ProfilesDir "devfront.ps1") },
    @{ rel = "profiles/devback.ps1";   out = (Join-Path $ProfilesDir "devback.ps1") },
    @{ rel = "profiles/devops.ps1";    out = (Join-Path $ProfilesDir "devops.ps1") }
  )

  foreach ($f in $files) {
    $url = "$RepoRawBase/$($f.rel)"
    Download-File -Url $url -OutFile $f.out
  }
}

function Run-Profile {
  param(
    [Parameter(Mandatory=$true)][string]$ScriptName
  )

  $path = Join-Path $ProfilesDir $ScriptName
  if (-not (Test-Path $path)) {
    Write-Host "❌ Script nao encontrado: $path" -ForegroundColor Red
    return
  }

  & $path -AutoUpgrade:$AutoUpgrade
}

# ===============================
# EXECUÇaO
# ===============================
Write-Host "`n🚀 Windows Setup (Winget)" -ForegroundColor Green
Write-Host "Inicializando ambiente..." -ForegroundColor Green

Sync-Scripts

# ===============================
# MENU PRINCIPAL
# ===============================
while ($true) {
  Write-Host "`n========================================" -ForegroundColor Green
  Write-Host " Windows Setup (Winget) — Menu Principal" -ForegroundColor Green
  Write-Host "========================================" -ForegroundColor Green
  Write-Host "1) Basicos (Usuario)"
  Write-Host "2) Suporte de TI"
  Write-Host "3) Dev Frontend"
  Write-Host "4) Dev Backend"
  Write-Host "5) DevOps / Infra"
  Write-Host "0) Sair`n"

  $choice = Read-Host "Escolha uma opçao"

  switch ($choice) {
    "1" { Run-Profile "basic.ps1" }
    "2" { Run-Profile "itsupport.ps1" }
    "3" { Run-Profile "devfront.ps1" }
    "4" { Run-Profile "devback.ps1" }
    "5" { Run-Profile "devops.ps1" }
    "0" {
      Write-Host "`n👋 Saindo do Windows Setup. Até mais!" -ForegroundColor Yellow
      return
    }
    default {
      Write-Host "❌ Opcao invalida." -ForegroundColor Red
    }
  }
}
