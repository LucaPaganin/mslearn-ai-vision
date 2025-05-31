$ErrorActionPreference = "Stop"

# Get the parent directory of the script root
$parentDir = Split-Path $PSScriptRoot
echo "Script root: $PSScriptRoot"
echo "Parent directory: $parentDir"

# Find all requirements.txt files recursively
$requirementsFiles = Get-ChildItem -Path $parentDir -Filter requirements.txt -Recurse

Write-Host "Found $($requirementsFiles.Count) requirements.txt files."
# Write-Output $requirementsFiles

# Create venv in .venv at the parent of the parent of the script root
# $venvRoot = Split-Path $parentDir -Parent
$venvPath = Join-Path $parentDir ".venv"

echo "Virtual environment path: $venvPath"

echo "Checking for existing virtual environment..."

# Write-Host "Stopping the script as requested."
# exit

if (Test-Path $venvPath) {
    Write-Host "Found existing virtual environment at $venvPath"
}
else {
    Write-Host "Creating virtual environment at $venvPath"
    python -m venv $venvPath
}

# Activate the venv
$activateScript = Join-Path $venvPath "Scripts\Activate.ps1"
. $activateScript

# Install all requirements.txt files with confirmation
foreach ($req in $requirementsFiles) {
    Write-Host "File $([array]::IndexOf($requirementsFiles, $req) + 1)/$($requirementsFiles.Count): $($req.FullName)"
    $confirm = Read-Host "Install requirements from $($req.FullName)? (y/n)"
    if ($confirm -eq 'y') {
        pip install -r $req.FullName
        Write-Host "Installed requirements from $($req.FullName)"
    } else {
        Write-Host "Skipped $($req.FullName)"
    }

    Write-Host "----------------------------------------"
    Write-Host "Current pip version: $(pip --version)"

}
