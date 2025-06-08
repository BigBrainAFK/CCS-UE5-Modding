param (
    [Parameter(Mandatory = $true, Position = 0)]
    [Alias("File", "Pak", "Input")]
    [ValidateNotNullOrEmpty()]
    [ValidatePattern('\.pak$')]
    [string]$PakFilePath,

    [Parameter(Mandatory = $false)]
    [Alias("Out", "Folder", "Name")]
    [ValidateNotNullOrEmpty()]
    [string]$OutputFolderName,

    [Parameter(Mandatory = $false)]
    [Alias("f")]
    [switch]$Force
)

# we check the output path doesnt start with ./ or .\ and ends with a / or \
if ($OutputFolderName -and ($OutputFolderName.StartsWith('./') -or $OutputFolderName.StartsWith('.\'))) {
    Write-Error "Output folder name cannot start with './' or '.\'"
    exit 1
}
if ($OutputFolderName -and -not $OutputFolderName.EndsWith('/')) {
    Write-Error "Output folder name must not end with '/'"
    exit 1
}


# Resolve .pak file path (supports relative or absolute)
$PakFileBaseName = [System.IO.Path]::GetFileNameWithoutExtension($ResolvedPakPath)

# Output folder defaults to base file name
$OutputFolder = if ($OutputFolderName) { $OutputFolderName } else { $PakFileBaseName }

# add verbose and force if specified
$arguments = @("unpack", $PakFilePath, "-o $OutputFolder")

if ($Verbose) {
    $arguments += "-v"
}
if ($Force) {
    $arguments += "-f"
}

# Run UnrealPak assuming it's available in current directory or PATH
& .\__tools\repak\repak.exe @arguments
if ($LASTEXITCODE -ne 0) {
    Write-Error "repak failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
}
