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

Show-Menu "Perfil: Dev Backend" $options
