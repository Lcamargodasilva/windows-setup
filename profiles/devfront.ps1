param([switch]$AutoUpgrade)

. "$PSScriptRoot\..\lib\winget.ps1"
Assert-Winget

$PACKS = [ordered]@{
  "1" = "Git.Git"
  "2" = "Microsoft.VisualStudioCode"
  "3" = "Microsoft.WindowsTerminal"
  "4" = "OpenJS.NodeJS.LTS"
  "5" = "Google.Chrome"
  "6" = "Mozilla.Firefox"
  "7" = "Postman.Postman"
  "8" = "Docker.DockerDesktop"
  "9" = "GitHub.cli"
}

Show-WingetProfile -Title "Perfil: Dev Frontend" -Packages $PACKS -AutoUpgrade:$AutoUpgrade
