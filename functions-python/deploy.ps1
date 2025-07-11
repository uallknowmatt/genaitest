# PowerShell script to deploy Python Azure Functions
param(
    [Parameter(Mandatory=$true)]
    [string]$FunctionAppName,
    
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory=$false)]
    [string]$Location = "East US"
)

Write-Host "Deploying Python Azure Functions..." -ForegroundColor Green

# Check if Azure CLI is installed
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Error "Azure CLI is not installed. Please install it first."
    exit 1
}

# Check if Azure Functions Core Tools is installed
if (-not (Get-Command func -ErrorAction SilentlyContinue)) {
    Write-Error "Azure Functions Core Tools is not installed. Please install it first."
    exit 1
}

# Check if Python is installed
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Error "Python is not installed. Please install it first."
    exit 1
}

try {
    # Install Python dependencies
    Write-Host "Installing Python dependencies..." -ForegroundColor Yellow
    pip install -r requirements.txt
    
    # Create Function App if it doesn't exist
    Write-Host "Checking if Function App exists..." -ForegroundColor Yellow
    $functionApp = az functionapp show --name $FunctionAppName --resource-group $ResourceGroupName 2>$null
    
    if (-not $functionApp) {
        Write-Host "Creating Function App..." -ForegroundColor Yellow
        
        # Create App Service Plan
        $planName = "$FunctionAppName-plan"
        az appservice plan create --name $planName --resource-group $ResourceGroupName --location $Location --sku B1 --is-linux
        
        # Create Function App
        az functionapp create --name $FunctionAppName --resource-group $ResourceGroupName --plan $planName --runtime python --runtime-version 3.9 --functions-version 4 --storage-account $FunctionAppName"storage"
        
        Write-Host "Function App created successfully!" -ForegroundColor Green
    } else {
        Write-Host "Function App already exists." -ForegroundColor Yellow
    }
    
    # Deploy functions
    Write-Host "Deploying functions..." -ForegroundColor Yellow
    func azure functionapp publish $FunctionAppName
    
    Write-Host "Deployment completed successfully!" -ForegroundColor Green
    
    # Get Function App URL
    $functionAppUrl = az functionapp show --name $FunctionAppName --resource-group $ResourceGroupName --query "defaultHostName" --output tsv
    
    Write-Host "Function App URL: https://$functionAppUrl" -ForegroundColor Cyan
    Write-Host "AI Query Endpoint: https://$functionAppUrl/api/query" -ForegroundColor Cyan
    
} catch {
    Write-Error "Deployment failed: $($_.Exception.Message)"
    exit 1
}

Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Configure Application Settings in Azure Portal" -ForegroundColor White
Write-Host "2. Set up Azure Storage containers" -ForegroundColor White
Write-Host "3. Configure Azure Cognitive Search index" -ForegroundColor White
Write-Host "4. Set up Azure OpenAI service" -ForegroundColor White 