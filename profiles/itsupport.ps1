param([switch]$AutoUpgrade)

. "$PSScriptRoot\..\lib\winget.ps1"
Assert-Winget

$PACKS = [ordered]@{
  "1" = "Google.Chrome"
  "2" = "Mozilla.Firefox"
  "3" = "7zip.7zip"
  "4" = "Microsoft.Sysinternals"
  "5" = "WiresharkFoundation.Wireshark"
  "6" = "PuTTY.PuTTY"
  "7" = "RustDesk.RustDesk"
  "8" = "AnyDeskSoftwareGmbH.AnyDesk"
  "9" = "Notepad++.Notepad++"
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

Show-Menu "Perfil: Suporte TI" $options
