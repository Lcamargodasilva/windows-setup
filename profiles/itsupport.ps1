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

Show-WingetProfile -Title "Perfil: Suporte TI" -Packages $PACKS -AutoUpgrade:$AutoUpgrade
