param (
    [Parameter(Mandatory = $true, Position = 0)]
    [Alias('src, in, input')]
    [ValidateNotNullOrEmpty()]
    [ValidatePattern('\\$')]
    [string]$SourcePath,

    [Parameter(Mandatory = $true, Position = 1)]
    [Alias('out, output')]
    [ValidateNotNullOrEmpty()]
    [ValidatePattern('_P\.(pak|utoc)$')]
    [string]$OutputPath,

    [Parameter(Mandatory = $false)]
    [Alias('c')]
    [switch]$compress,

    [Parameter(Mandatory = $false)]
    [Alias('z')]
    [switch]$zip,

    [Parameter(Mandatory = $false)]
    [Alias('cleanup')]
    [switch]$removeFiles,

    [Parameter(Mandatory = $false)]
    [Alias('p', 'prio')]
    [ValidateNotNullOrEmpty()]
    [int]$priority = 0
)

if ($removeFiles -and -not $zip) {
    Write-Error "The -cleanup switch can only be used with the -zip switch."
    exit 1
}

if ($priority -lt 0) {
    Write-Error "Priority must be 0 or higher."
    exit 1
}

if ($priority -gt 0) {
    $OutputPath = $OutputPath -replace '_P\.(pak|utoc)$', "_$priority`_P.`$1"
}

# Derive .pak and .utoc paths
$pakkedOutput = [System.IO.Path]::ChangeExtension($OutputPath, '.pak')
$utocOutput = [System.IO.Path]::ChangeExtension($OutputPath, '.utoc')

# tool paths
$retocPath = ".\__tools\retoc\retoc.exe"
$repakPath = ".\__tools\repak\repak.exe"
$7zaPath = ".\__tools\7z\x64\7za.exe"

# Ensure repak.exe exists
if (-not (Test-Path -Path $repakPath)) {
    Write-Error "repak.exe not found at $repakPath"
    exit 1
}

Write-Host "Running repak..."

$trimmedSource = $SourcePath.TrimEnd('\')

# we only add the -compress switch if the user specified it
$repakArgs = @("-v", "`"$trimmedSource`"", "`"$pakkedOutput`"")
if ($compress) {
    $repakArgs += "-compression Oodle"
}

& $repakPath pack -v "`"$trimmedSource`"" "`"$pakkedOutput`""
if ($LASTEXITCODE -ne 0) {
    Write-Error "repak.exe failed"
    exit 1
}

# Ensure retoc.exe exists
if (-not (Test-Path -Path $retocPath)) {
    Write-Error "retoc.exe not found at $retocPath"
    exit 1
}

# Run retoc
Write-Host "Running retoc.exe..."
& $retocPath to-zen --version UE5_4 "`"$pakkedOutput`"" "`"$utocOutput`""
if ($LASTEXITCODE -ne 0) {
    Write-Error "retoc.exe failed"
    exit 1
}

# compress to zip if specified
if ($zip) {
    # Ensure 7z.exe exists
    if (-not (Test-Path -Path $7zaPath)) {
        Write-Error "7za.exe not found at $7zaPath"
        exit 1
    }

    # then we use the output utoc file and pack the files extensions .pak and .ucas as well
    # this means we should get all 3 .pak, .utoc and .ucas files in the zip
    $ucasOutput = [System.IO.Path]::ChangeExtension($OutputPath, '.ucas')

    # for the zip file we remove the _P from the output filename/path and change the extension to .zip
    $zipOutput = [System.IO.Path]::ChangeExtension($OutputPath, '.zip')

    if ($priority -gt 0) {
        $zipOutput = $zipOutput -replace "_$priority", ''
    }
    $zipOutput = $zipOutput -replace '_P\.zip$', '.zip'

    # check if all files exist
    if (-not (Test-Path -Path $pakkedOutput)) {
        Write-Error "Output .pak file not found: $pakkedOutput"
        exit 1
    }
    if (-not (Test-Path -Path $utocOutput)) {
        Write-Error "Output .utoc file not found: $utocOutput"
        exit 1
    }
    if (-not (Test-Path -Path $ucasOutput)) {
        Write-Error "Output .ucas file not found: $ucasOutput"
        exit 1
    }

    # if zip exists then delete it
    if (Test-Path -Path $zipOutput) {
        Remove-Item -Path $zipOutput -Force
    }

    Write-Host "Compressing to zip..."
    & $7zaPath a -tzip -bb "`"$zipOutput`"" "`"$ucasOutput`"" "`"$pakkedOutput`"" "`"$utocOutput`"" | Select-String "archive", "everything", "+" -SimpleMatch
    if ($LASTEXITCODE -ne 0) {
        Write-Error "7za.exe failed"
        exit 1
    }

    # if we are removing files then we delete the .pak, .utoc and .ucas files
    if ($removeFiles) {
        Write-Host "Removing original files..."
        Remove-Item -Path $pakkedOutput, $utocOutput, $ucasOutput -Force
    }
}
