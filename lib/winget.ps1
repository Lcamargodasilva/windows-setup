Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Assert-Winget {
  if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw "Winget nao encontrado. Instale o App Installer."
  }
}

function Install-WingetPackage($Id) {
  Write-Host "`n==> Instalando: $Id" -ForegroundColor Cyan
  try {
    winget install --id $Id -e --silent `
      --accept-package-agreements `
      --accept-source-agreements
  } catch {
    winget install --id $Id -e `
      --accept-package-agreements `
      --accept-source-agreements
  }
}

function Install-WingetMany($Ids) {
  foreach ($id in $Ids) { Install-WingetPackage $id }
}

function Ask-UpgradeAll([switch]$Auto) {
  if ($Auto) {
    winget upgrade --all --accept-package-agreements --accept-source-agreements
    return
  }

  if ((Read-Host "Atualizar tudo (winget upgrade --all)? (Y/N)") -match '^[Yy]$') {
    winget upgrade --all --accept-package-agreements --accept-source-agreements
  }
}

function Show-Menu($Title, $Options) {
  while ($true) {
    Write-Host "`n==== $Title ====" -ForegroundColor Green

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

