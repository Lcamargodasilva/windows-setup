Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$global:WINGET_SOURCE = "winget"
$script:WingetRunId = Get-Date -Format "yyyyMMdd-HHmmss-fff"
$script:WingetLogDir = Join-Path (Join-Path $env:TEMP "windows-setup") "logs"
$script:WingetAttemptNumber = 0
$script:WingetTestRunner = $null

function Initialize-WingetLogs {
  if (-not (Test-Path -LiteralPath $script:WingetLogDir)) {
    New-Item -ItemType Directory -Force -Path $script:WingetLogDir | Out-Null
  }
}

function ConvertTo-WingetHex([int]$ExitCode) {
  return ('0x{0}' -f $ExitCode.ToString("X8"))
}

function Get-WingetResultKind([int]$ExitCode) {
  $hex = ConvertTo-WingetHex $ExitCode

  if ($ExitCode -eq 0) { return "Success" }
  if ($ExitCode -eq 3010 -or $ExitCode -eq 1641 -or $hex -in @("0x8A150109", "0x8A15010A", "0x8A15010B")) { return "RebootRequired" }
  if ($hex -in @("0x800704C7", "0x8A150005", "0x8A15006A", "0x8A150077", "0x8A15010C")) { return "Cancelled" }
  if ($hex -in @("0x8A150061", "0x8A15010D")) { return "AlreadyInstalled" }
  if ($hex -eq "0x8A15002B") { return "NoApplicableUpdate" }
  return "Failed"
}

function Get-SafeLogName([string]$Value) {
  return ($Value -replace '[^A-Za-z0-9._-]', '_')
}

function Invoke-WingetAttempt {
  param(
    [Parameter(Mandatory = $true)][string]$PackageId,
    [Parameter(Mandatory = $true)][string]$Mode,
    [Parameter(Mandatory = $true)][string[]]$Arguments
  )

  Initialize-WingetLogs
  $script:WingetAttemptNumber++
  $safeId = Get-SafeLogName $PackageId
  $logName = "{0}-{1:D3}-{2}-{3}.log" -f $script:WingetRunId, $script:WingetAttemptNumber, $safeId, $Mode
  $logPath = Join-Path $script:WingetLogDir $logName

  Write-Host "`n==> Pacote: $PackageId | modo: $Mode" -ForegroundColor Cyan

  if ($null -ne $script:WingetTestRunner) {
    $testResult = & $script:WingetTestRunner $PackageId $Mode $Arguments $logPath
    $exitCode = [int]$testResult.ExitCode
    [string[]]$output = @($testResult.Output)
    $output | Set-Content -LiteralPath $logPath -Encoding UTF8
  } else {
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
      & winget @Arguments *> $logPath
      $exitCode = $LASTEXITCODE
    } finally {
      $ErrorActionPreference = $oldPreference
    }
    [string[]]$output = @(Get-Content -LiteralPath $logPath -ErrorAction SilentlyContinue)
  }

  if ($output.Count -gt 0) { $output | ForEach-Object { Write-Host $_ } }
  $kind = Get-WingetResultKind $exitCode
  $hex = ConvertTo-WingetHex $exitCode
  $line = "pacote={0}; modo={1}; exitCode={2}; hex={3}; resultado={4}" -f $PackageId, $Mode, $exitCode, $hex, $kind
  Add-Content -LiteralPath $logPath -Value "`r`n[$line]" -Encoding UTF8
  Write-Host $line -ForegroundColor $(if ($kind -eq "Failed") { "Red" } elseif ($kind -eq "Cancelled") { "Yellow" } else { "Green" })

  return [pscustomobject]@{
    PackageId = $PackageId
    Mode = $Mode
    ExitCode = $exitCode
    HexCode = $hex
    Kind = $kind
    LogPath = $logPath
  }
}

function Assert-Winget {
  Initialize-WingetLogs
  $winget = Get-Command winget -ErrorAction SilentlyContinue
  if (-not $winget) {
    throw "Winget não encontrado. Instale ou atualize o App Installer. Logs: $script:WingetLogDir"
  }

  $diagnosticLog = Join-Path $script:WingetLogDir ("{0}-diagnostico.log" -f $script:WingetRunId)
  Write-Host "`nDiagnóstico do Winget (somente leitura)" -ForegroundColor Cyan
  & winget --info *> $diagnosticLog
  $infoExitCode = $LASTEXITCODE
  & winget source list *>> $diagnosticLog
  $sourcesExitCode = $LASTEXITCODE
  Get-Content -LiteralPath $diagnosticLog -ErrorAction SilentlyContinue | ForEach-Object { Write-Host $_ }
  Add-Content -LiteralPath $diagnosticLog -Value ("`r`nwinget --info: {0} ({1}); source list: {2} ({3})" -f $infoExitCode, (ConvertTo-WingetHex $infoExitCode), $sourcesExitCode, (ConvertTo-WingetHex $sourcesExitCode))

  if ($infoExitCode -ne 0 -or $sourcesExitCode -ne 0) {
    Write-Host "Aviso: o diagnóstico retornou erro. Consulte $diagnosticLog" -ForegroundColor Yellow
  }
  Write-Host "Logs desta execução: $script:WingetLogDir" -ForegroundColor DarkCyan
}

function Install-WingetPackage([string]$Id) {
  $baseArgs = @("install", "--id", $Id, "-e", "--source", $global:WINGET_SOURCE,
    "--accept-package-agreements", "--accept-source-agreements")

  $silent = Invoke-WingetAttempt -PackageId $Id -Mode "silencioso" -Arguments ($baseArgs + "--silent")
  if ($silent.Kind -ne "Failed") { return $silent }

  Write-Host "Falha silenciosa em $Id ($($silent.ExitCode), $($silent.HexCode)). Tentando modo normal..." -ForegroundColor Yellow
  $normal = Invoke-WingetAttempt -PackageId $Id -Mode "normal" -Arguments $baseArgs
  if ($normal.Kind -eq "Success") {
    $normal.Kind = "SuccessAfterFallback"
    Add-Content -LiteralPath $normal.LogPath -Value "resultadoFinal=SuccessAfterFallback" -Encoding UTF8
  }
  return $normal
}

function Install-WingetMany($Ids) {
  $results = @()
  foreach ($id in $Ids) {
    try {
      $results += Install-WingetPackage $id
    } catch {
      Write-Host "Falha inesperada em $id; continuando: $($_.Exception.Message)" -ForegroundColor Red
      $results += [pscustomobject]@{ PackageId = $id; Kind = "Failed"; ExitCode = $null; HexCode = $null; LogPath = $null }
    }
  }

  $successful = @($results | Where-Object { $_.Kind -in @("Success", "SuccessAfterFallback", "AlreadyInstalled", "NoApplicableUpdate", "RebootRequired") })
  $failed = @($results | Where-Object { $_.Kind -in @("Failed", "Cancelled") })
  Write-Host "`nResumo: $($successful.Count) sucesso(s), $($failed.Count) falha(s)/cancelamento(s)." -ForegroundColor Cyan
  foreach ($result in $results) {
    Write-Host ("- {0}: {1}{2}" -f $result.PackageId, $result.Kind, $(if ($null -ne $result.ExitCode) { " [$($result.ExitCode), $($result.HexCode)]" } else { "" }))
  }
  return $results
}

function Ask-UpgradeAll([switch]$Auto) {
  if (-not $Auto -and (Read-Host "Atualizar tudo (winget upgrade --all)? (Y/N)") -notmatch '^[Yy]$') { return }
  Invoke-WingetAttempt -PackageId "ALL" -Mode "upgrade" -Arguments @("upgrade", "--all", "--source", $global:WINGET_SOURCE, "--accept-package-agreements", "--accept-source-agreements") | Out-Null
}

function Show-Menu($Title, $Options) {
  while ($true) {
    Write-Host "`n==== $Title ====" -ForegroundColor Green
    $sortedKeys = $Options.Keys | Sort-Object -Property @{ Expression = {
      if ($_ -eq "0") { "0|0000|$_" } elseif ($_ -match '^\d+$') { "1|{0:D4}|$_" -f ([int]$_) } else { "2|9999|$_" }
    } }
    foreach ($k in $sortedKeys) { Write-Host "$k) $($Options[$k].label)" }

    $choice = Read-Host "Escolha"
    if (-not $Options.ContainsKey($choice)) { Write-Host "Inválido." -ForegroundColor Red; continue }
    $opt = $Options[$choice]
    if ($opt.ContainsKey("args") -and $null -ne $opt.args) { & $opt.action @($opt.args) } else { & $opt.action }
    if ($opt.ContainsKey("exitAfter") -and $opt.exitAfter) { return }
  }
}

function Show-WingetProfile {
  param([string]$Title, $Packages, [switch]$AutoUpgrade)
  $options = @{}
  foreach ($key in $Packages.Keys) {
    $packageId = $Packages[$key]
    $options[$key] = @{ label = "Instalar $packageId"; action = { param($pkg) Install-WingetPackage $pkg | Out-Null }; args = @($packageId); exitAfter = $false }
  }
  $options["A"] = @{ label = "Instalar TODOS"; action = { Install-WingetMany $Packages.Values | Out-Null }; exitAfter = $false }
  $options["U"] = @{ label = "Atualizar tudo"; action = { Ask-UpgradeAll -Auto:$AutoUpgrade }; exitAfter = $false }
  $options["0"] = @{ label = "Voltar"; action = {}; exitAfter = $true }
  Show-Menu $Title $options
}
