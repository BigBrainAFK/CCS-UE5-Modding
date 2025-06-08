$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$command = "cd '$scriptDir'; Start-Process '$scriptDir\__tools\UAssetGUI\UAssetGUI.exe'"
Start-Process powershell -ArgumentList "-NoExit", "-Command", $command
