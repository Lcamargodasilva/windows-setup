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

$options = @{}

foreach ($k in $PACKS.Keys) {
  $id = $PACKS[$k]


  $kCopy  = $k
  $idCopy = $id

  $options[$kCopy] = @{
    label     = "Instalar $idCopy"
    action    = { Install-WingetPackage $idCopy }
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

Show-Menu "Perfil: Dev Frontend" $options
