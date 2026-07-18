param([switch]$AutoUpgrade)

. "$PSScriptRoot\..\lib\winget.ps1"
Assert-Winget

$PACKS = [ordered]@{
  "1" = "Hashicorp.Terraform"
  "2" = "Kubernetes.kubectl"
  "3" = "Helm.Helm"
  "4" = "Docker.DockerDesktop"
  "5" = "Git.Git"
  "6" = "GitHub.cli"
  "7" = "Amazon.AWSCLI"
  "8" = "Microsoft.AzureCLI"
  "9" = "Google.CloudSDK"
}

Show-WingetProfile -Title "Perfil: DevOps / Infra" -Packages $PACKS -AutoUpgrade:$AutoUpgrade
