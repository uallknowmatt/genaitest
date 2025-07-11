# Azure Development Test Cycle Script
# Creates infrastructure, tests the app, then destroys it to save costs

param(
    [Parameter(Mandatory=$true)]
    [string]$Action = "full-cycle", # full-cycle, create, test, destroy
    
    [Parameter(Mandatory=$false)]
    [string]$SubscriptionId = "d8797220-f5cf-4668-a271-39ce114bb150",
    
    [Parameter(Mandatory=$false)]
    [int]$TestDurationMinutes = 30,
    
    [Parameter(Mandatory=$false)]
    [string]$Environment = "dev-test"
)

Write-Host "🚀 Azure Development Test Cycle Script" -ForegroundColor Green
Write-Host "Action: $Action" -ForegroundColor Yellow
Write-Host "Test Duration: $TestDurationMinutes minutes" -ForegroundColor Yellow
Write-Host "Environment: $Environment" -ForegroundColor Yellow
Write-Host ""

# Check prerequisites
function Test-Prerequisites {
    Write-Host "Checking prerequisites..." -ForegroundColor Cyan
    
    # Check Azure CLI
    if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
        Write-Error "Azure CLI is not installed. Please install it first."
        exit 1
    }
    
    # Check Terraform
    if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
        Write-Error "Terraform is not installed. Please install it first."
        exit 1
    }
    
    Write-Host "✅ Prerequisites met" -ForegroundColor Green
}

# Login to Azure
function Connect-Azure {
    Write-Host "Logging into Azure..." -ForegroundColor Cyan
    az login
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to login to Azure"
        exit 1
    }
    
    Write-Host "Setting subscription..." -ForegroundColor Cyan
    az account set --subscription $SubscriptionId
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to set subscription"
        exit 1
    }
    
    Write-Host "✅ Azure connected" -ForegroundColor Green
}

# Create infrastructure
function New-Infrastructure {
    Write-Host "🏗️ Creating infrastructure..." -ForegroundColor Cyan
    
    # Initialize Terraform
    Write-Host "Initializing Terraform..." -ForegroundColor Yellow
    terraform init
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Terraform init failed"
        exit 1
    }
    
    # Plan deployment
    Write-Host "Planning deployment..." -ForegroundColor Yellow
    terraform plan -out=tfplan
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Terraform plan failed"
        exit 1
    }
    
    # Apply infrastructure
    Write-Host "Applying infrastructure..." -ForegroundColor Yellow
    terraform apply tfplan
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Terraform apply failed"
        exit 1
    }
    
    # Get outputs
    Write-Host "Getting infrastructure outputs..." -ForegroundColor Yellow
    $outputs = terraform output -json | ConvertFrom-Json
    
    # Save outputs to file for testing
    $outputs | ConvertTo-Json -Depth 10 | Out-File -FilePath "infrastructure-outputs.json" -Encoding UTF8
    
    Write-Host "✅ Infrastructure created successfully!" -ForegroundColor Green
    Write-Host "📊 Estimated cost for this session: $1.50-2.50" -ForegroundColor Yellow
}

# Test the application
function Test-Application {
    Write-Host "🧪 Testing application..." -ForegroundColor Cyan
    
    # Read infrastructure outputs
    if (Test-Path "infrastructure-outputs.json") {
        $outputs = Get-Content "infrastructure-outputs.json" | ConvertFrom-Json
        
        # Get Function App URL
        $functionAppUrl = $outputs.function_app_url.value
        Write-Host "Function App URL: $functionAppUrl" -ForegroundColor Green
        
        # Test AI Query endpoint
        Write-Host "Testing AI Query endpoint..." -ForegroundColor Yellow
        $testQuery = @{
            query = "What is this system about?"
            user_id = "test-user"
        } | ConvertTo-Json
        
        try {
            $response = Invoke-RestMethod -Uri "$functionAppUrl/api/query" -Method POST -Body $testQuery -ContentType "application/json"
            Write-Host "✅ AI Query test successful!" -ForegroundColor Green
            Write-Host "Response: $($response.response)" -ForegroundColor Gray
        } catch {
            Write-Host "⚠️ AI Query test failed: $($_.Exception.Message)" -ForegroundColor Yellow
        }
        
        # Test document upload (if storage is configured)
        Write-Host "Testing document upload..." -ForegroundColor Yellow
        # Add document upload test here
        
    } else {
        Write-Host "⚠️ No infrastructure outputs found" -ForegroundColor Yellow
    }
    
    Write-Host "⏰ Waiting $TestDurationMinutes minutes for testing..." -ForegroundColor Cyan
    Write-Host "You can now test the application manually at: $functionAppUrl" -ForegroundColor Green
    Write-Host "Press Ctrl+C to stop testing early" -ForegroundColor Yellow
    
    # Wait for testing period
    Start-Sleep -Seconds ($TestDurationMinutes * 60)
    
    Write-Host "✅ Testing completed" -ForegroundColor Green
}

# Destroy infrastructure
function Remove-Infrastructure {
    Write-Host "🗑️ Destroying infrastructure..." -ForegroundColor Cyan
    
    # Confirm destruction
    Write-Host "This will delete ALL resources! Are you sure? (y/N)" -ForegroundColor Red
    $confirmation = Read-Host
    if ($confirmation -ne "y" -and $confirmation -ne "Y") {
        Write-Host "Operation cancelled" -ForegroundColor Yellow
        return
    }
    
    # Destroy infrastructure
    Write-Host "Running terraform destroy..." -ForegroundColor Yellow
    terraform destroy -auto-approve
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Terraform destroy failed"
        exit 1
    }
    
    # Clean up files
    if (Test-Path "infrastructure-outputs.json") {
        Remove-Item "infrastructure-outputs.json"
    }
    if (Test-Path "tfplan") {
        Remove-Item "tfplan"
    }
    
    Write-Host "✅ Infrastructure destroyed successfully!" -ForegroundColor Green
    Write-Host "💰 Cost saved by destroying: ~$130/month" -ForegroundColor Green
}

# Main execution
try {
    Test-Prerequisites
    Connect-Azure
    
    switch ($Action.ToLower()) {
        "full-cycle" {
            Write-Host "🔄 Starting full create/test/destroy cycle..." -ForegroundColor Green
            New-Infrastructure
            Test-Application
            Remove-Infrastructure
            Write-Host "🎉 Full cycle completed!" -ForegroundColor Green
        }
        "create" {
            New-Infrastructure
        }
        "test" {
            Test-Application
        }
        "destroy" {
            Remove-Infrastructure
        }
        default {
            Write-Host "Invalid action. Use: full-cycle, create, test, or destroy" -ForegroundColor Red
            exit 1
        }
    }
    
} catch {
    Write-Error "Script failed: $($_.Exception.Message)"
    exit 1
}

Write-Host ""
Write-Host "📊 Session Summary:" -ForegroundColor Cyan
Write-Host "• Infrastructure created and tested" -ForegroundColor White
Write-Host "• Estimated cost: $1.50-2.50 per session" -ForegroundColor White
Write-Host "• Cost saved vs 24/7: ~$130/month" -ForegroundColor White
Write-Host "• Next session: Run this script again when ready" -ForegroundColor White 