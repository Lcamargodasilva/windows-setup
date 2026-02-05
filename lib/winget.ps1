Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Fonte padrão (ignora msstore / evita erro 0x8a15003b no Sandbox)
$global:WINGET_SOURCE = "winget"

function Assert-Winget {
  if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw "Winget não encontrado. Instale/atualize o App Installer."
  }
}

function Install-WingetPackage($Id) {
  Write-Host "`n==> Instalando: $Id" -ForegroundColor Cyan
  try {
    winget install --id $Id -e --source $global:WINGET_SOURCE --silent `
      --accept-package-agreements `
      --accept-source-agreements
  } catch {
    Write-Host "Falhou silencioso: $Id. Tentando modo normal..." -ForegroundColor Yellow
    winget install --id $Id -e --source $global:WINGET_SOURCE `
      --accept-package-agreements `
      --accept-source-agreements
  }
}

function Install-WingetMany($Ids) {
  foreach ($id in $Ids) { Install-WingetPackage $id }
}

function Ask-UpgradeAll([switch]$Auto) {
  $cmd = {
    winget upgrade --all --source $global:WINGET_SOURCE `
      --accept-package-agreements `
      --accept-source-agreements
  }

  if ($Auto) {
    & $cmd
    return
  }

  if ((Read-Host "Atualizar tudo (winget upgrade --all)? (Y/N)") -match '^[Yy]$') {
    & $cmd
  }
}

function Show-Menu($Title, $Options) {
  while ($true) {
    Write-Host "`n==== $Title ====" -ForegroundColor Green

    # Ordenação natural PS 5.1:
    $sortedKeys = $Options.Keys |
      Sort-Object -Property @{
        Expression = {
          if ($_ -eq "0") { "0|0000|$_" }
          elseif ($_ -match '^\d+$') { "1|{0:D4}|$_" -f ([int]$_) }
          else { "2|9999|$_" }
        }
      }

    foreach ($k in $sortedKeys) {
      Write-Host "$k) $($Options[$k].label)"
    }

    $choice = Read-Host "Escolha"
    if (-not $Options.ContainsKey($choice)) {
      Write-Host "Inválido." -ForegroundColor Red
      continue
    }

    & $Options[$choice].action
    if ($Options[$choice].exitAfter) { break }
  }
}
