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

$options = @{}

foreach ($k in $PACKS.Keys) {
  $id = $PACKS[$k]

  $options[$k] = @{
    label     = "Instalar $id"
    action    = { param($pkg) Install-WingetPackage $pkg }
    args      = @($id)
    exitAfter = $false
  }
}

$options["A"] = @{
  label     = "Instalar TODOS"
  action    = { Install-WingetMany $PACKS.Values }
  exitAfter = $false
}

$options["U"] = @{
  label     = "Atualizar tudo"
  action    = { Ask-UpgradeAll -Auto:$AutoUpgrade }
  exitAfter = $false
}

$options["0"] = @{
  label     = "Voltar"
  action    = { }
  exitAfter = $true
}

Show-Menu "Perfil: DevOps / Infra" $options
