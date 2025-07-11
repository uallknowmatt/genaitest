# GitHub Secrets Setup Scripts

This directory contains scripts to automatically set up GitHub secrets for Azure Terraform deployment.

## Option 1: Using GitHub CLI (Recommended)

### Prerequisites:
1. Install GitHub CLI: https://cli.github.com/
2. Install Azure CLI: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
3. Authenticate with GitHub: `gh auth login`

### Usage:
```powershell
# Navigate to the scripts directory
cd scripts

# Run the setup script
.\setup-github-secrets.ps1 -GitHubRepo "uallknowmatt/genaitest"
```

## Option 2: Using REST API

### Prerequisites:
1. GitHub Personal Access Token with `repo` scope
2. Azure CLI installed and authenticated

### Usage:
```powershell
# Navigate to the scripts directory
cd scripts

# Run the setup script
.\setup-github-secrets-api.ps1 -GitHubToken "your-github-token" -GitHubRepo "uallknowmatt/genaitest"
```

## Option 3: From Existing Service Principal JSON File

### Prerequisites:
1. Azure service principal JSON file (from `az ad sp create-for-rbac` output)
2. GitHub CLI OR GitHub Personal Access Token

### Usage:
```powershell
# Navigate to the scripts directory
cd scripts

# Using GitHub CLI
.\setup-github-secrets-from-file.ps1 -GitHubRepo "uallknowmatt/genaitest" -JsonFilePath "path\to\your\service-principal.json"

# Using REST API with token
.\setup-github-secrets-from-file.ps1 -GitHubRepo "uallknowmatt/genaitest" -JsonFilePath "path\to\your\service-principal.json" -GitHubToken "your-github-token"
```

### Example JSON File Format:
See `example-service-principal.json` for the expected format. Your JSON should contain:
- `clientId`
- `clientSecret`
- `subscriptionId`
- `tenantId`

## What the scripts do:

1. **Create Azure Service Principal** with contributor role on your subscription (Options 1 & 2)
2. **Read existing Service Principal** from JSON file (Option 3)
3. **Add GitHub Secrets**:
   - `AZURE_CLIENT_ID`
   - `AZURE_CLIENT_SECRET`
   - `AZURE_SUBSCRIPTION_ID`
   - `AZURE_TENANT_ID`

## Manual Setup (Alternative)

If you prefer to set up manually:

### 1. Create Service Principal:
```powershell
az ad sp create-for-rbac --name "terraform-github-actions" --role contributor --scopes /subscriptions/d8797220-f5cf-4668-a271-39ce114bb150 --sdk-auth
```

### 2. Add GitHub Secrets:
Go to your repository → Settings → Secrets and variables → Actions → New repository secret

Add the 4 secrets from the service principal output.

## Testing the Setup:

After running any script, you can test the GitHub Actions:

1. Go to your GitHub repository
2. Click **Actions** tab
3. Click **Terraform Azure Infrastructure**
4. Click **Run workflow**
5. Select action: `plan`
6. Click **Run workflow**

The workflow should now run successfully with the Azure credentials! 