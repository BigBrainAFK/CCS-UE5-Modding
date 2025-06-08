param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$sourceFolder,
    
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$outputFile
)

if (-not $outputFile.ToLower().EndsWith(".pak")) {
    Write-Error "The output file must end with '.pak'."
    exit 1
}

$outputDir = Split-Path -Path $outputFile -Parent
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

$sourceFolder = $sourceFolder.TrimEnd('\', '/')
& ./__tools/retoc/retoc.exe to-legacy $sourceFolder $outputFile