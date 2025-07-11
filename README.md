# DocAI Chatbot Infrastructure

## 🎯 Overview

This repository contains Terraform infrastructure code for a comprehensive document management and AI chatbot system built on Azure. The system includes intelligent document lifecycle management with cost optimization through storage tiering.

## 🏗️ Architecture

### **Core Components**
- **Azure Storage Account** (Cool Tier) with intelligent lifecycle management
- **Azure SQL Database** for metadata and user management
- **Azure Cognitive Services** (Form Recognizer, Search, OpenAI)
- **Azure Bot Service** for chatbot interface
- **Azure App Service** for web application
- **Azure Functions** for document processing and management
- **Azure Logic Apps** for workflow automation
- **Azure Key Vault** for secure secret management
- **Application Insights** for monitoring and analytics

### **Storage Strategy**
The system implements a **3-tier storage strategy** for cost optimization:

1. **Hot Tier** (`hot-documents`): Frequently accessed documents (30-day retention)
2. **Cool Tier** (`documents`): Infrequently accessed documents (90-day retention)  
3. **Archive Tier** (`archive`): Historical documents (365-day retention)

**Cost Savings**: Up to 73% compared to hot-only storage

## 📊 Document Lifecycle Management

### **Automatic Tiering**
- Documents move to cool tier after 30 days of no access
- Documents move to archive after 90 days of no access
- Documents are deleted after 365 days of no access
- Frequently accessed documents are automatically promoted to hot tier

### **Intelligent Features**
- **Access Pattern Analysis**: Tracks document usage and predicts future access
- **Smart Retrieval**: Automatically retrieves archived documents when queried
- **Cost Optimization**: Balances storage costs with access performance
- **Metadata Tracking**: Maintains document information across all tiers

## 🚀 Quick Start

### **Prerequisites**
- Azure CLI installed and authenticated
- Terraform installed
- GitHub CLI (for secrets management)

### **1. Clone and Setup**
```bash
git clone https://github.com/your-org/genaitest.git
cd genaitest
```

### **2. Configure Variables**
Edit `terraform.tfvars` with your specific values:
```hcl
subscription_id = "your-subscription-id"
location        = "East US"
environment     = "dev"
```

### **3. Deploy Infrastructure**
```bash
# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Apply infrastructure
terraform apply
```

### **4. Setup GitHub Secrets**
```bash
# Run the automated setup script
.\scripts\setup-github-secrets.ps1
```

### **5. Deploy via GitHub Actions**
- Push changes to trigger the workflow
- Monitor deployment in GitHub Actions tab

## 💰 Cost Optimization

### **Storage Costs (per GB/month)**
- **Hot Tier**: $0.0184
- **Cool Tier**: $0.01  
- **Archive Tier**: $0.00099

### **Estimated Monthly Costs**
- **Small deployment** (100 documents, 5GB): ~$15/month
- **Medium deployment** (1000 documents, 50GB): ~$75/month
- **Large deployment** (10000 documents, 500GB): ~$750/month

### **Cost Savings Examples**
- **1000 documents, 10GB**: 73% savings with tiering
- **10000 documents, 100GB**: 80% savings with tiering

## 🔧 Configuration

### **Storage Lifecycle Rules**
```hcl
# Automatic tiering thresholds
hot_to_cool_days     = 30
cool_to_archive_days = 90
archive_to_delete_days = 365

# Access thresholds for promotion
min_access_count_for_hot = 5
max_hot_documents = 1000
```

### **Container Policies**
- **Hot Documents**: Limited to 1000 documents, auto-cleanup enabled
- **Archive**: Compression enabled, longer retrieval times
- **Metadata**: Separate container for document tracking

## 📈 Monitoring

### **Key Metrics**
- Storage costs by tier
- Document access patterns
- Retrieval times from different tiers
- User satisfaction with document availability

### **Alerts**
- High storage costs in hot tier
- Slow retrieval times from archive
- Failed document moves between tiers
- Search index inconsistencies

## 🔐 Security

### **Data Protection**
- All data encrypted at rest and in transit
- Azure Key Vault for secret management
- Role-based access control (RBAC)
- Network security groups and private endpoints

### **Compliance**
- GDPR-ready with data lifecycle management
- Audit logging for all document operations
- Data residency controls

## 📚 Documentation

- [Document Management Strategy](./docs/document-management-strategy.md)
- [API Documentation](./docs/api.md)
- [Deployment Guide](./docs/deployment.md)
- [Troubleshooting](./docs/troubleshooting.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:
- Create an issue in this repository
- Check the troubleshooting guide
- Review the documentation

---

**Note**: This infrastructure is designed for production use with proper monitoring, backup, and disaster recovery procedures in place.
