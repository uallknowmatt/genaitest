# GitHub Secrets Setup Runner Script
# This script runs the GitHub secrets setup with predefined parameters

Write-Host "Running GitHub Secrets Setup..." -ForegroundColor Green
Write-Host "Repository: uallknowmatt/genaitest" -ForegroundColor Yellow
Write-Host "JSON File: C:\genaiexperiments\genaitest\appreg\service-principal.json" -ForegroundColor Yellow
Write-Host ""

# Check if the JSON file exists
$jsonPath = "C:\genaiexperiments\genaitest\appreg\service-principal.json"
if (-not (Test-Path $jsonPath)) {
    Write-Host "JSON file not found: $jsonPath" -ForegroundColor Red
    Write-Host "Please ensure the service principal JSON file exists at the specified path." -ForegroundColor Yellow
    exit 1
}

Write-Host "JSON file found" -ForegroundColor Green

# Run the setup script
Write-Host "Executing GitHub secrets setup..." -ForegroundColor Cyan
& ".\setup-github-secrets-from-file.ps1" -GitHubRepo "uallknowmatt/genaitest" -JsonFilePath $jsonPath

Write-Host ""
Write-Host "Setup script execution completed!" -ForegroundColor Green 