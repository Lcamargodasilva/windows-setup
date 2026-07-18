$ErrorActionPreference = "Stop"
. "$PSScriptRoot\..\lib\winget.ps1"

function Assert-Equal($Expected, $Actual, [string]$Message) {
  if ($Expected -ne $Actual) { throw "$Message. Esperado: $Expected; obtido: $Actual" }
}

$queue = New-Object System.Collections.Queue
$script:WingetTestRunner = {
  param($PackageId, $Mode, $Arguments, $LogPath)
  $code = [int]$queue.Dequeue()
  [pscustomobject]@{ ExitCode = $code; Output = @("simulado: $PackageId/$Mode/$code") }
}

$queue.Enqueue(0)
$result = Install-WingetPackage "Test.Success"
Assert-Equal "Success" $result.Kind "Sucesso direto"
Assert-Equal 0 $queue.Count "Sucesso não deve usar fallback"

$queue.Enqueue(1)
$queue.Enqueue(0)
$result = Install-WingetPackage "Test.Fallback"
Assert-Equal "SuccessAfterFallback" $result.Kind "Fallback normal"

$queue.Enqueue(1)
$queue.Enqueue(2)
$result = Install-WingetPackage "Test.Failure"
Assert-Equal "Failed" $result.Kind "Falha definitiva"

Assert-Equal "AlreadyInstalled" (Get-WingetResultKind ([int]0x8A150061)) "Pacote já instalado"
Assert-Equal "NoApplicableUpdate" (Get-WingetResultKind ([int]0x8A15002B)) "Sem atualização aplicável"
Assert-Equal "Cancelled" (Get-WingetResultKind ([int]0x8A15010C)) "Cancelamento"
Assert-Equal "RebootRequired" (Get-WingetResultKind 3010) "Reinicialização"

$script:MenuReads = New-Object System.Collections.Queue
$script:MenuReads.Enqueue("0")
function global:Read-Host { param([string]$Prompt) return $script:MenuReads.Dequeue() }
$options = @{ "0" = @{ label = "Voltar"; action = {}; exitAfter = $true } }
Show-Menu "Teste de submenu" $options
Assert-Equal 0 $script:MenuReads.Count "Retorno do submenu"

Write-Host "Todos os testes simulados passaram." -ForegroundColor Green
