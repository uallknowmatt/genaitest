# Terraform Modules Documentation

## 🏗️ Module Structure

This project has been modularized for better maintainability and resource management. Each Azure service is now in its own module with dedicated variables, outputs, and documentation.

## 📁 Module Directory Structure

```
modules/
├── resource-group/          # Azure Resource Group
├── storage/                 # Storage Account & Containers
├── database/                # SQL Server & Database
├── cognitive-services/      # Search, Form Recognizer, OpenAI
├── app-service/             # Web App & Functions
├── bot-service/             # Bot Service
├── key-vault/               # Key Vault
└── monitoring/              # Logic App & Application Insights
```

## 🔧 Module Details

### **1. Resource Group Module**
**Location**: `modules/resource-group/`

**Purpose**: Creates the Azure Resource Group that contains all other resources.

**Resources**:
- `azurerm_resource_group`

**Key Variables**:
- `resource_group_name` - Name of the resource group
- `location` - Azure region
- `tags` - Resource tags

**Outputs**:
- `resource_group_id` - ID of the resource group
- `resource_group_name` - Name of the resource group
- `resource_group_location` - Location of the resource group

### **2. Storage Module**
**Location**: `modules/storage/`

**Purpose**: Creates storage account with intelligent lifecycle management and multiple containers for document tiering.

**Resources**:
- `azurerm_storage_account` - Cool tier storage with lifecycle management
- `azurerm_storage_management_policy` - Automatic tiering rules
- `azurerm_storage_container` - Multiple containers (documents, processed, archive, hot-documents, metadata)

**Key Variables**:
- `storage_account_name` - Name of the storage account
- `resource_group_name` - Resource group name
- `location` - Azure region

**Outputs**:
- `storage_account_id` - Storage account ID
- `storage_account_name` - Storage account name
- `storage_account_primary_connection_string` - Connection string
- `storage_account_endpoint` - Blob endpoint
- `containers` - Map of container IDs

### **3. Database Module**
**Location**: `modules/database/`

**Purpose**: Creates SQL Server and Database for application data and document metadata.

**Resources**:
- `azurerm_mssql_server` - SQL Server instance
- `azurerm_mssql_database` - SQL Database
- `azurerm_mssql_firewall_rule` - Firewall rule for Azure services

**Key Variables**:
- `sql_server_name` - SQL Server name
- `sql_database_name` - Database name
- `sql_admin_username` - Admin username
- `sql_admin_password` - Admin password

**Outputs**:
- `sql_server_id` - SQL Server ID
- `sql_server_name` - SQL Server name
- `sql_database_id` - Database ID
- `sql_connection_string` - Connection string

### **4. Cognitive Services Module**
**Location**: `modules/cognitive-services/`

**Purpose**: Creates Azure Cognitive Services for AI and search capabilities.

**Resources**:
- `azurerm_search_service` - Cognitive Search service
- `azurerm_cognitive_account` - Form Recognizer service
- `azurerm_cognitive_account` - OpenAI service

**Key Variables**:
- `search_service_name` - Search service name
- `form_recognizer_name` - Form Recognizer name
- `openai_service_name` - OpenAI service name

**Outputs**:
- `search_service_id` - Search service ID
- `search_service_primary_key` - Search API key
- `form_recognizer_endpoint` - Form Recognizer endpoint
- `openai_endpoint` - OpenAI endpoint
- `openai_primary_key` - OpenAI API key

### **5. App Service Module**
**Location**: `modules/app-service/`

**Purpose**: Creates web application and Azure Functions for document processing.

**Resources**:
- `azurerm_service_plan` - App Service Plan for web app
- `azurerm_windows_web_app` - Web application
- `azurerm_service_plan` - App Service Plan for functions
- `azurerm_windows_function_app` - Functions application

**Key Variables**:
- `web_app_name` - Web application name
- `functions_app_name` - Functions application name
- Various connection strings and API keys

**Outputs**:
- `web_app_id` - Web app ID
- `web_app_url` - Web app URL
- `functions_app_id` - Functions app ID
- `functions_app_url` - Functions app URL

### **6. Bot Service Module**
**Location**: `modules/bot-service/`

**Purpose**: Creates Azure Bot Service for chatbot functionality.

**Resources**:
- `azurerm_bot_service_azure_bot` - Bot service
- `azurerm_bot_channel_registration` - Bot registration

**Key Variables**:
- `bot_name` - Bot service name
- `bot_app_id` - Microsoft App ID
- `bot_app_password` - Microsoft App password

**Outputs**:
- `bot_id` - Bot service ID
- `bot_name` - Bot service name
- `bot_endpoint` - Bot endpoint

### **7. Key Vault Module**
**Location**: `modules/key-vault/`

**Purpose**: Creates Azure Key Vault for secure secret management.

**Resources**:
- `azurerm_key_vault` - Key Vault instance
- `azurerm_key_vault_access_policy` - Access policy for current user

**Key Variables**:
- `key_vault_name` - Key Vault name

**Outputs**:
- `key_vault_id` - Key Vault ID
- `key_vault_name` - Key Vault name
- `key_vault_uri` - Key Vault URI

### **8. Monitoring Module**
**Location**: `modules/monitoring/`

**Purpose**: Creates monitoring and workflow automation resources.

**Resources**:
- `azurerm_logic_app_workflow` - Logic App for document management
- `azurerm_application_insights` - Application Insights for monitoring

**Key Variables**:
- `logic_app_name` - Logic App name
- `app_insights_name` - Application Insights name

**Outputs**:
- `logic_app_id` - Logic App ID
- `app_insights_id` - Application Insights ID
- `app_insights_instrumentation_key` - Instrumentation key

## 🔄 Module Dependencies

The modules have the following dependency order:

1. **Resource Group** (no dependencies)
2. **Storage** (depends on Resource Group)
3. **Database** (depends on Resource Group)
4. **Cognitive Services** (depends on Resource Group)
5. **Key Vault** (depends on Resource Group)
6. **App Service** (depends on Storage, Database, Cognitive Services, Key Vault)
7. **Bot Service** (depends on Resource Group)
8. **Monitoring** (depends on Resource Group)

## 🛠️ Using Individual Modules

### **Deploy Single Module**
```bash
# Deploy only storage module
terraform plan -target=module.storage
terraform apply -target=module.storage
```

### **Modify Specific Module**
```bash
# Edit storage module variables
terraform plan -var="storage_account_name=new-name"
```

### **Destroy Specific Module**
```bash
# Destroy only monitoring module
terraform destroy -target=module.monitoring
```

## 📝 Module Customization

### **Adding New Resources to a Module**
1. Edit the module's `main.tf`
2. Add new variables to `variables.tf`
3. Add new outputs to `outputs.tf`
4. Update the main `main.tf` to pass new variables

### **Creating New Modules**
1. Create new directory in `modules/`
2. Add `main.tf`, `variables.tf`, and `outputs.tf`
3. Update main `main.tf` to include the new module
4. Update main `outputs.tf` to expose module outputs

### **Module Versioning**
```hcl
module "storage" {
  source = "./modules/storage"
  version = "1.0.0"  # Add version constraints
  # ... variables
}
```

## 🔍 Best Practices

### **Module Design**
- Keep modules focused on a single responsibility
- Use consistent naming conventions
- Include comprehensive variable validation
- Document all inputs and outputs

### **Variable Management**
- Use descriptive variable names
- Provide sensible defaults where appropriate
- Mark sensitive variables appropriately
- Use variable validation for constraints

### **Output Strategy**
- Expose only necessary outputs
- Use consistent output naming
- Mark sensitive outputs appropriately
- Provide meaningful descriptions

### **Testing**
- Test modules individually
- Use `terraform plan` to validate changes
- Test module dependencies
- Validate outputs after deployment

## 🚀 Benefits of Modularization

### **Maintainability**
- ✅ Easier to locate and modify specific resources
- ✅ Clear separation of concerns
- ✅ Reduced complexity in individual files

### **Reusability**
- ✅ Modules can be reused across projects
- ✅ Consistent resource configurations
- ✅ Standardized naming and tagging

### **Scalability**
- ✅ Easy to add new resources
- ✅ Simple to modify existing resources
- ✅ Clear dependency management

### **Collaboration**
- ✅ Multiple developers can work on different modules
- ✅ Reduced merge conflicts
- ✅ Clear ownership of resources

## 📚 Additional Resources

- [Terraform Modules Documentation](https://www.terraform.io/docs/language/modules/index.html)
- [Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html) 