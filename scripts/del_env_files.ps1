# Script to recursively delete .env files with git rm and recreate them

# Set the repository root (current directory)
$repoRoot = Get-Location

Write-Host "Starting cleanup of .env files in repository: $repoRoot" -ForegroundColor Green

# Find all .env files recursively
$envFiles = Get-ChildItem -Path $repoRoot -Recurse -Name "*.env" -File

if ($envFiles.Count -eq 0) {
    Write-Host "No .env files found in the repository." -ForegroundColor Yellow
} else {
    Write-Host "Found $($envFiles.Count) .env file(s):" -ForegroundColor Cyan
    $envFiles | ForEach-Object { Write-Host "  $_" }
    
    # Remove each .env file using git rm
    foreach ($file in $envFiles) {
        try {
            Write-Host "Removing $file with git rm..." -ForegroundColor Yellow
            git rm --cached "$file"
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  ✓ Successfully removed $file" -ForegroundColor Green
            } else {
                Write-Host "  ✗ Failed to remove $file with git rm" -ForegroundColor Red
            }
        }
        catch {
            Write-Host "  ✗ Error removing $($file): $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}