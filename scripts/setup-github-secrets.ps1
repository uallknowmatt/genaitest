# GitHub Secrets Setup Script
# This script creates Azure service principal and adds secrets to GitHub

param(
    [Parameter(Mandatory=$true)]
    [string]$GitHubRepo,
    
    [Parameter(Mandatory=$false)]
    [string]$SubscriptionId = "d8797220-f5cf-4668-a271-39ce114bb150",
    
    [Parameter(Mandatory=$false)]
    [string]$ServicePrincipalName = "terraform-github-actions"
)

Write-Host "🔧 Setting up GitHub Secrets for Azure Terraform" -ForegroundColor Green
Write-Host "Repository: $GitHubRepo" -ForegroundColor Yellow
Write-Host "Subscription: $SubscriptionId" -ForegroundColor Yellow
Write-Host ""

# Check if GitHub CLI is installed
try {
    $ghVersion = gh --version
    Write-Host "✅ GitHub CLI found" -ForegroundColor Green
} catch {
    Write-Host "❌ GitHub CLI not found. Please install it first." -ForegroundColor Red
    Write-Host "Download from: https://cli.github.com/" -ForegroundColor Yellow
    exit 1
}

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

# Add secrets to GitHub
Write-Host "🔑 Adding secrets to GitHub repository..." -ForegroundColor Cyan

# AZURE_CLIENT_ID
Write-Host "Adding AZURE_CLIENT_ID..." -ForegroundColor Yellow
gh secret set AZURE_CLIENT_ID --body $spData.clientId --repo $GitHubRepo

# AZURE_CLIENT_SECRET
Write-Host "Adding AZURE_CLIENT_SECRET..." -ForegroundColor Yellow
gh secret set AZURE_CLIENT_SECRET --body $spData.clientSecret --repo $GitHubRepo

# AZURE_SUBSCRIPTION_ID
Write-Host "Adding AZURE_SUBSCRIPTION_ID..." -ForegroundColor Yellow
gh secret set AZURE_SUBSCRIPTION_ID --body $spData.subscriptionId --repo $GitHubRepo

# AZURE_TENANT_ID
Write-Host "Adding AZURE_TENANT_ID..." -ForegroundColor Yellow
gh secret set AZURE_TENANT_ID --body $spData.tenantId --repo $GitHubRepo

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