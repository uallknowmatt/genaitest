# Document Management and AI Chatbot Infrastructure

This project provides infrastructure as code (IaC) for creating a comprehensive document management and AI chatbot system using Azure services, with automated deployment and destruction through GitHub Actions.

## 🏗️ Architecture Overview

### **Document Storage & Processing:**
- **Azure Blob Storage** - Secure document storage with versioning
- **Azure Functions** - Serverless document processing
- **Azure Form Recognizer** - Text extraction from PDFs and images

### **AI & Search:**
- **Azure Cognitive Search** - Intelligent document indexing
- **Azure OpenAI Service** - GPT models for document Q&A
- **Azure Bot Service** - Conversational AI interface

### **Web Application:**
- **Azure App Service** - Web application hosting
- **Azure SQL Database** - User data and document metadata
- **Azure Key Vault** - Secure credential management

## 📋 Resources Created

- **Resource Group**: `rg-docai-chatbot-dev`
- **Storage Account**: `stdocai001` (with document containers)
- **SQL Database**: `docai-db` on `sql-docai-dev`
- **Cognitive Search**: `search-docai-dev`
- **OpenAI Service**: `openai-docai-dev`
- **Bot Service**: `bot-docai-chatbot`
- **App Service**: `app-docai-web` (web application)
- **Functions App**: `func-docai-processor` (document processing)
- **Key Vault**: `kv-docai-secrets`

## 🚀 Quick Start

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

## 🔧 Configuration

### Variables

Edit `variables.tf` to customize:
- `resource_group_name`: Name of the resource group
- `location`: Azure region (default: East US)
- `storage_account_name`: Storage account name (must be globally unique)
- `sql_admin_password`: SQL Server administrator password
- `bot_app_id` & `bot_app_password`: Bot service credentials
- `tags`: Resource tags

### Example Customization

```hcl
# terraform.tfvars
resource_group_name = "rg-docai-chatbot-prod"
location           = "West US 2"
storage_account_name = "stdocai001prod"
sql_admin_password = "YourSecurePassword123!"
tags = {
  Environment = "Production"
  Project     = "DocAI-Chatbot"
  ManagedBy   = "Terraform"
}
```

## 🔄 Data Flow

1. **Document Upload**: Users upload documents to Azure Blob Storage
2. **Processing**: Azure Functions process documents and extract text
3. **Indexing**: Text is indexed in Azure Cognitive Search
4. **User Query**: Users ask questions via the chatbot
5. **AI Processing**: OpenAI searches documents and generates answers
6. **Response**: Bot returns contextual answers to users

## 🔒 Security Features

- **Encryption**: All data encrypted at rest and in transit
- **Key Vault**: Secure storage of sensitive credentials
- **Private Access**: Storage containers with private access
- **TLS 1.2**: Minimum TLS version enforced
- **Managed Identity**: App Service uses managed identity for Key Vault access

## 📊 Monitoring & Analytics

- **Application Insights**: Built-in monitoring for App Service
- **Azure Monitor**: Infrastructure monitoring
- **Log Analytics**: Centralized logging

## 💰 Cost Optimization

- **Consumption Plan**: Functions use pay-per-use pricing
- **Basic Tier**: SQL Database and App Service use basic tiers
- **Reserved Capacity**: Consider reserved instances for production

## 🚨 Important Notes

- **OpenAI Service**: Requires approval from Microsoft
- **Bot Registration**: Bot App ID and password must be configured
- **Storage Names**: Storage account names must be globally unique
- **SQL Password**: Use strong passwords for production

## 🔧 Troubleshooting

### Common Issues

1. **Storage Account Name Already Exists**:
   - Change `storage_account_name` in variables.tf
   - Storage account names must be globally unique

2. **OpenAI Service Not Available**:
   - Request access to Azure OpenAI Service
   - Check region availability

3. **Bot Service Configuration**:
   - Register bot in Azure Bot Service
   - Configure App ID and password

## 📚 Next Steps

After infrastructure deployment:

1. **Deploy Application Code** to App Service
2. **Configure Bot Framework** for the chatbot
3. **Set up Document Processing** workflows
4. **Configure Cognitive Search** indexes
5. **Test End-to-End** functionality

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `terraform plan`
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.
