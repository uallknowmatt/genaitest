# Azure Infrastructure with Terraform and GitHub Actions

This project provides infrastructure as code (IaC) for creating Azure resources using Terraform, with automated deployment and destruction through GitHub Actions.

## Resources Created

- **Resource Group**: `rg-genaitest-dev` (configurable)
- **Storage Account**: `stgenaitestdev001` (configurable, must be globally unique)
- **Storage Container**: `data` (configurable)

## Prerequisites

### For Local Development
1. [Terraform](https://www.terraform.io/downloads.html) (version >= 1.0)
2. [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
3. Azure subscription access

### For GitHub Actions
1. Azure Service Principal with appropriate permissions
2. GitHub repository secrets configured

## Quick Start

### Local Development

1. **Login to Azure**:
   ```bash
   az login
   az account set --subscription "d8797220-f5cf-4668-a271-39ce114bb150"
   ```

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

3. **Plan the deployment**:
   ```bash
   terraform plan
   ```

4. **Apply the infrastructure**:
   ```bash
   terraform apply
   ```

5. **Destroy the infrastructure**:
   ```bash
   terraform destroy
   ```

### GitHub Actions Setup

1. **Create Azure Service Principal**:
   ```bash
   az ad sp create-for-rbac --name "terraform-github-actions" --role contributor \
     --scopes /subscriptions/d8797220-f5cf-4668-a271-39ce114bb150 \
     --sdk-auth
   ```

2. **Add GitHub Secrets**:
   Go to your GitHub repository → Settings → Secrets and variables → Actions, and add:
   - `AZURE_CLIENT_ID`: Service principal client ID
   - `AZURE_CLIENT_SECRET`: Service principal client secret
   - `AZURE_SUBSCRIPTION_ID`: `d8797220-f5cf-4668-a271-39ce114bb150`
   - `AZURE_TENANT_ID`: Your Azure tenant ID

3. **Run the Pipeline**:
   - **Automatic**: Push to `main` branch triggers plan
   - **Manual**: Go to Actions tab → "Terraform Azure Infrastructure" → "Run workflow"
     - Select action: `plan`, `apply`, or `destroy`

## Configuration

### Variables

Edit `variables.tf` to customize:
- `resource_group_name`: Name of the resource group
- `location`: Azure region (default: East US)
- `storage_account_name`: Storage account name (must be globally unique)
- `container_name`: Storage container name
- `tags`: Resource tags

### Example Customization

```hcl
# terraform.tfvars
resource_group_name = "rg-myproject-prod"
location           = "West US 2"
storage_account_name = "stmyprojectprod001"
container_name     = "appdata"
tags = {
  Environment = "Production"
  Project     = "MyProject"
  ManagedBy   = "Terraform"
}
```

## Pipeline Features

- **Automatic Planning**: Runs on every push to main
- **Pull Request Validation**: Comments with plan details
- **Manual Actions**: Apply/Destroy via GitHub Actions UI
- **Security**: Uses Azure Service Principal authentication
- **State Management**: Terraform state stored locally (consider Azure Storage for production)

## Security Notes

- Storage account access keys are marked as sensitive in outputs
- Use Azure Key Vault for production secrets
- Consider enabling storage account encryption and firewall rules
- Review and adjust IAM permissions as needed

## Troubleshooting

### Common Issues

1. **Storage Account Name Already Exists**:
   - Change `storage_account_name` in variables.tf
   - Storage account names must be globally unique

2. **Authentication Errors**:
   - Verify Azure CLI login: `az account show`
   - Check service principal permissions for GitHub Actions

3. **Terraform State Issues**:
   - Delete `.terraform` folder and run `terraform init` again
   - Consider using remote state storage for team environments

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `terraform plan`
5. Submit a pull request

## License

This project is licensed under the MIT License.
