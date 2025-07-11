# GitHub Secrets Setup Script from JSON File
# This script reads Azure service principal JSON and adds secrets to GitHub

param(
    [Parameter(Mandatory=$true)]
    [string]$GitHubRepo,
    
    [Parameter(Mandatory=$true)]
    [string]$JsonFilePath,
    
    [Parameter(Mandatory=$false)]
    [string]$GitHubToken
)

Write-Host "🔧 Setting up GitHub Secrets from JSON file" -ForegroundColor Green
Write-Host "Repository: $GitHubRepo" -ForegroundColor Yellow
Write-Host "JSON File: $JsonFilePath" -ForegroundColor Yellow
Write-Host ""

# Check if JSON file exists
if (-not (Test-Path $JsonFilePath)) {
    Write-Host "❌ JSON file not found: $JsonFilePath" -ForegroundColor Red
    exit 1
}

# Read and parse JSON file
try {
    $jsonContent = Get-Content $JsonFilePath -Raw
    $spData = $jsonContent | ConvertFrom-Json
    Write-Host "✅ JSON file loaded successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to parse JSON file: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Validate required properties
$requiredProperties = @("clientId", "clientSecret", "subscriptionId", "tenantId")
foreach ($prop in $requiredProperties) {
    if (-not $spData.$prop) {
        Write-Host "❌ Missing required property: $prop" -ForegroundColor Red
        exit 1
    }
}

Write-Host "✅ Service Principal data validated" -ForegroundColor Green

# Function to add GitHub secret using GitHub CLI
function Add-GitHubSecretCLI {
    param(
        [string]$SecretName,
        [string]$SecretValue
    )
    
    try {
        gh secret set $SecretName --body $SecretValue --repo $GitHubRepo
        Write-Host "✅ Added $SecretName via GitHub CLI" -ForegroundColor Green
    } catch {
        Write-Host "❌ Failed to add $SecretName via GitHub CLI: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
    return $true
}

# Function to add GitHub secret using REST API
function Add-GitHubSecretAPI {
    param(
        [string]$SecretName,
        [string]$SecretValue
    )
    
    if (-not $GitHubToken) {
        Write-Host "❌ GitHub token required for API method" -ForegroundColor Red
        return $false
    }
    
    $headers = @{
        "Authorization" = "token $GitHubToken"
        "Accept" = "application/vnd.github.v3+json"
    }
    
    $body = @{
        encrypted_value = $SecretValue
        key_id = ""
    } | ConvertTo-Json
    
    $url = "https://api.github.com/repos/$GitHubRepo/actions/secrets/$SecretName"
    
    try {
        $response = Invoke-RestMethod -Uri $url -Method Put -Headers $headers -Body $body -ContentType "application/json"
        Write-Host "✅ Added $SecretName via REST API" -ForegroundColor Green
    } catch {
        Write-Host "❌ Failed to add $SecretName via REST API: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
    return $true
}

# Determine which method to use
$useCLI = $true
if ($GitHubToken) {
    Write-Host "🔑 Using REST API method with provided token" -ForegroundColor Cyan
    $useCLI = $false
} else {
    Write-Host "🔑 Using GitHub CLI method" -ForegroundColor Cyan
    # Check if GitHub CLI is available
    try {
        $ghVersion = gh --version
        Write-Host "✅ GitHub CLI found" -ForegroundColor Green
    } catch {
        Write-Host "❌ GitHub CLI not found. Please provide GitHubToken parameter for REST API method." -ForegroundColor Red
        exit 1
    }
}

# Add secrets to GitHub
Write-Host "🔑 Adding secrets to GitHub repository..." -ForegroundColor Cyan

$secrets = @{
    "AZURE_CLIENT_ID" = $spData.clientId
    "AZURE_CLIENT_SECRET" = $spData.clientSecret
    "AZURE_SUBSCRIPTION_ID" = $spData.subscriptionId
    "AZURE_TENANT_ID" = $spData.tenantId
}

$successCount = 0
foreach ($secret in $secrets.GetEnumerator()) {
    if ($useCLI) {
        if (Add-GitHubSecretCLI -SecretName $secret.Key -SecretValue $secret.Value) {
            $successCount++
        }
    } else {
        if (Add-GitHubSecretAPI -SecretName $secret.Key -SecretValue $secret.Value) {
            $successCount++
        }
    }
}

Write-Host ""
if ($successCount -eq 4) {
    Write-Host "✅ All secrets added successfully!" -ForegroundColor Green
} else {
    Write-Host "⚠️ $successCount out of 4 secrets added successfully" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📋 Summary:" -ForegroundColor Cyan
Write-Host "  Client ID: $($spData.clientId)" -ForegroundColor White
Write-Host "  Tenant ID: $($spData.tenantId)" -ForegroundColor White
Write-Host "  Subscription ID: $($spData.subscriptionId)" -ForegroundColor White
Write-Host "  Secrets Added: $successCount/4" -ForegroundColor White
Write-Host ""
Write-Host "🔗 You can now test the GitHub Actions workflow!" -ForegroundColor Green 