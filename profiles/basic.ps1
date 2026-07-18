param([switch]$AutoUpgrade)

. "$PSScriptRoot\..\lib\winget.ps1"
Assert-Winget

$PACKS = [ordered]@{
  "1"  = "Google.Chrome"
  "2"  = "Mozilla.Firefox"
  "3"  = "Brave.Brave"
  "4"  = "7zip.7zip"
  "5"  = "RARLab.WinRAR"
  "6"  = "VideoLAN.VLC"
  "7"  = "Adobe.Acrobat.Reader.64-bit"
  "8"  = "Notepad++.Notepad++"
  "9"  = "Microsoft.PowerToys"
  "10" = "Microsoft.WindowsTerminal"
  "11" = "voidtools.Everything"
  "12" = "ShareX.ShareX"
}

Show-WingetProfile -Title "Perfil: Basicos" -Packages $PACKS -AutoUpgrade:$AutoUpgrade
