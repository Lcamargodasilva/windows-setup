$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$errors = @()

Get-ChildItem -LiteralPath $root -Recurse -Filter "*.ps1" | ForEach-Object {
  $tokens = $null
  $parseErrors = $null
  [System.Management.Automation.Language.Parser]::ParseFile($_.FullName, [ref]$tokens, [ref]$parseErrors) | Out-Null
  if ($parseErrors.Count -gt 0) {
    $errors += $parseErrors
    Write-Host "ERRO $($_.FullName)" -ForegroundColor Red
    $parseErrors | ForEach-Object { Write-Host $_ }
  } else {
    Write-Host "OK $($_.FullName)"
  }
}

if ($errors.Count -gt 0) { throw "Foram encontrados $($errors.Count) erro(s) sintático(s)." }
Write-Host "Todos os arquivos PowerShell passaram na análise sintática." -ForegroundColor Green
