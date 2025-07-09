# Azure Infrastructure Deployment Script
# This script helps you deploy the Azure infrastructure locally

param(
    [Parameter(Mandatory=$false)]
    [string]$Action = "plan",
    
    [Parameter(Mandatory=$false)]
    [string]$SubscriptionId = "d8797220-f5cf-4668-a271-39ce114bb150"
)

Write-Host "🚀 Azure Infrastructure Deployment Script" -ForegroundColor Green
Write-Host "Action: $Action" -ForegroundColor Yellow
Write-Host "Subscription: $SubscriptionId" -ForegroundColor Yellow
Write-Host ""

# Check if Azure CLI is installed
try {
    $azVersion = az version --output json | ConvertFrom-Json
    Write-Host "✅ Azure CLI found (version: $($azVersion.'azure-cli'))" -ForegroundColor Green
} catch {
    Write-Host "❌ Azure CLI not found. Please install it first." -ForegroundColor Red
    Write-Host "Download from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli" -ForegroundColor Yellow
    exit 1
}

# Check if Terraform is installed
try {
    $tfVersion = terraform version -json | ConvertFrom-Json
    Write-Host "✅ Terraform found (version: $($tfVersion.terraform_version))" -ForegroundColor Green
} catch {
    Write-Host "❌ Terraform not found. Please install it first." -ForegroundColor Red
    Write-Host "Download from: https://www.terraform.io/downloads.html" -ForegroundColor Yellow
    exit 1
}

# Login to Azure
Write-Host "🔐 Logging into Azure..." -ForegroundColor Cyan
az login
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to login to Azure" -ForegroundColor Red
    exit 1
}

# Set subscription
Write-Host "📋 Setting subscription..." -ForegroundColor Cyan
az account set --subscription $SubscriptionId
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to set subscription" -ForegroundColor Red
    exit 1
}

# Initialize Terraform
Write-Host "🔧 Initializing Terraform..." -ForegroundColor Cyan
terraform init
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to initialize Terraform" -ForegroundColor Red
    exit 1
}

# Execute Terraform action
switch ($Action.ToLower()) {
    "plan" {
        Write-Host "📋 Running Terraform plan..." -ForegroundColor Cyan
        terraform plan
    }
    "apply" {
        Write-Host "🚀 Applying Terraform configuration..." -ForegroundColor Cyan
        terraform apply -auto-approve
    }
    "destroy" {
        Write-Host "🗑️ Destroying infrastructure..." -ForegroundColor Red
        Write-Host "⚠️ This will delete all resources! Are you sure? (y/N)" -ForegroundColor Yellow
        $confirmation = Read-Host
        if ($confirmation -eq "y" -or $confirmation -eq "Y") {
            terraform destroy -auto-approve
        } else {
            Write-Host "❌ Operation cancelled" -ForegroundColor Yellow
        }
    }
    "output" {
        Write-Host "📤 Showing Terraform outputs..." -ForegroundColor Cyan
        terraform output
    }
    default {
        Write-Host "❌ Invalid action. Use: plan, apply, destroy, or output" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "✅ Script completed successfully!" -ForegroundColor Green 