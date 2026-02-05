Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Assert-Winget {
  if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw "Winget não encontrado. Instale o App Installer."
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
    foreach ($k in ($Options.Keys | Sort-Object)) {
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
