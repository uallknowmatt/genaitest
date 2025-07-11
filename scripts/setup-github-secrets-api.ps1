# GitHub Secrets Setup Script using REST API
# This script creates Azure service principal and adds secrets to GitHub via API

param(
    [Parameter(Mandatory=$true)]
    [string]$GitHubToken,
    
    [Parameter(Mandatory=$true)]
    [string]$GitHubRepo, # Format: "owner/repo"
    
    [Parameter(Mandatory=$false)]
    [string]$SubscriptionId = "d8797220-f5cf-4668-a271-39ce114bb150",
    
    [Parameter(Mandatory=$false)]
    [string]$ServicePrincipalName = "terraform-github-actions"
)

Write-Host "🔧 Setting up GitHub Secrets for Azure Terraform (REST API)" -ForegroundColor Green
Write-Host "Repository: $GitHubRepo" -ForegroundColor Yellow
Write-Host "Subscription: $SubscriptionId" -ForegroundColor Yellow
Write-Host ""

# Check if Azure CLI is installed
try {
    $azVersion = az --version
    Write-Host "✅ Azure CLI found" -ForegroundColor Green
} catch {
    Write-Host "❌ Azure CLI not found. Please install it first." -ForegroundColor Red
    Write-Host "Download from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli" -ForegroundColor Yellow
    exit 1
}

# Login to Azure
Write-Host "🔐 Logging into Azure..." -ForegroundColor Cyan
az login
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to login to Azure" -ForegroundColor Red
    exit 1
}

# Create Service Principal
Write-Host "👤 Creating Azure Service Principal..." -ForegroundColor Cyan
$spOutput = az ad sp create-for-rbac --name $ServicePrincipalName --role contributor --scopes "/subscriptions/$SubscriptionId" --sdk-auth --output json
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to create service principal" -ForegroundColor Red
    exit 1
}

# Parse the JSON output
$spData = $spOutput | ConvertFrom-Json

Write-Host "✅ Service Principal created successfully" -ForegroundColor Green

# Function to add GitHub secret
function Add-GitHubSecret {
    param(
        [string]$SecretName,
        [string]$SecretValue
    )
    
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
        Write-Host "✅ Added $SecretName" -ForegroundColor Green
    } catch {
        Write-Host "❌ Failed to add $SecretName: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Add secrets to GitHub
Write-Host "🔑 Adding secrets to GitHub repository..." -ForegroundColor Cyan

Add-GitHubSecret -SecretName "AZURE_CLIENT_ID" -SecretValue $spData.clientId
Add-GitHubSecret -SecretName "AZURE_CLIENT_SECRET" -SecretValue $spData.clientSecret
Add-GitHubSecret -SecretName "AZURE_SUBSCRIPTION_ID" -SecretValue $spData.subscriptionId
Add-GitHubSecret -SecretName "AZURE_TENANT_ID" -SecretValue $spData.tenantId

Write-Host ""
Write-Host "✅ All secrets added successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Summary:" -ForegroundColor Cyan
Write-Host "  Service Principal: $ServicePrincipalName" -ForegroundColor White
Write-Host "  Client ID: $($spData.clientId)" -ForegroundColor White
Write-Host "  Tenant ID: $($spData.tenantId)" -ForegroundColor White
Write-Host "  Subscription ID: $($spData.subscriptionId)" -ForegroundColor White
Write-Host ""
Write-Host "🔗 You can now test the GitHub Actions workflow!" -ForegroundColor Green 