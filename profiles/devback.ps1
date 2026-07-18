param([switch]$AutoUpgrade)

. "$PSScriptRoot\..\lib\winget.ps1"
Assert-Winget

$PACKS = [ordered]@{
  "1"  = "Git.Git"
  "2"  = "Microsoft.VisualStudioCode"
  "3"  = "Microsoft.WindowsTerminal"
  "4"  = "Postman.Postman"
  "5"  = "Docker.DockerDesktop"
  "6"  = "OpenJS.NodeJS.LTS"
  "7"  = "Python.Python.3.12"
  "8"  = "Oracle.JDK.21"
  "9"  = "DBeaver.DBeaver"
  "10" = "GitHub.cli"
}

Show-WingetProfile -Title "Perfil: Dev Backend" -Packages $PACKS -AutoUpgrade:$AutoUpgrade
