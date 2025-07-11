# Azure Functions - Python Implementation

This directory contains Python Azure Functions for the document management and AI chatbot system.

## Functions Overview

### 1. DocumentUploadProcessor
**Trigger**: Blob Storage Trigger  
**Purpose**: Processes uploaded documents by extracting text, storing processed content, and indexing in search.

**Features**:
- Supports PDF, DOCX, TXT, and image files
- OCR processing for images using Tesseract
- Azure Form Recognizer integration for complex documents
- Automatic text extraction and storage
- Search indexing with Azure Cognitive Search

### 2. DocumentAccessTracker
**Trigger**: Timer Trigger (every 5 minutes)  
**Purpose**: Manages document lifecycle and access patterns.

**Features**:
- Moves documents between storage tiers (Hot → Cool → Archive)
- Tracks document access patterns
- Implements retention policies
- Automatic cleanup of old documents

### 3. AIQueryProcessor
**Trigger**: HTTP Trigger  
**Purpose**: Processes AI queries against document content using Azure OpenAI.

**Features**:
- Semantic search using Azure Cognitive Search
- AI-powered responses using Azure OpenAI GPT-4
- Query tracking and analytics
- Context-aware responses based on document content

## Setup Instructions

### Prerequisites
- Python 3.9 or higher
- Azure Functions Core Tools
- Azure CLI
- Required Python packages (see requirements.txt)

### Local Development Setup

1. **Install Dependencies**:
   ```bash
   cd functions-python
   pip install -r requirements.txt
   ```

2. **Configure Environment Variables**:
   Edit `local.settings.json` with your Azure service endpoints and keys:
   ```json
   {
     "IsEncrypted": false,
     "Values": {
       "AzureWebJobsStorage": "UseDevelopmentStorage=true",
       "FUNCTIONS_WORKER_RUNTIME": "python",
       "STORAGE_CONNECTION_STRING": "your_storage_connection_string",
       "SEARCH_ENDPOINT": "your_search_endpoint",
       "SEARCH_API_KEY": "your_search_api_key",
       "OPENAI_ENDPOINT": "your_openai_endpoint",
       "OPENAI_API_KEY": "your_openai_api_key",
       "FORM_RECOGNIZER_ENDPOINT": "your_form_recognizer_endpoint",
       "FORM_RECOGNIZER_KEY": "your_form_recognizer_key"
     }
   }
   ```

3. **Run Locally**:
   ```bash
   func start
   ```

### Deployment to Azure

1. **Deploy to Azure Functions**:
   ```bash
   func azure functionapp publish your-function-app-name
   ```

2. **Configure Application Settings**:
   Set the same environment variables in your Azure Function App's Application Settings.

## Function Details

### DocumentUploadProcessor

**Input**: Blob storage trigger on `documents/{name}`  
**Output**: Processed text stored in `processed` container and indexed in search

**Process Flow**:
1. Extract text from uploaded document
2. Store processed text in blob storage
3. Index document in Azure Cognitive Search
4. Track document access

**Supported File Types**:
- PDF (using PyPDF2)
- DOCX (using python-docx)
- TXT (direct text)
- Images (using Tesseract OCR)
- Other formats (using Azure Form Recognizer)

### DocumentAccessTracker

**Schedule**: Runs every 5 minutes  
**Purpose**: Lifecycle management

**Process Flow**:
1. Check document access patterns
2. Move documents between storage tiers
3. Apply retention policies
4. Clean up old documents

**Storage Tiers**:
- **Hot**: Frequently accessed documents
- **Cool**: Less frequently accessed documents
- **Archive**: Rarely accessed documents

### AIQueryProcessor

**Endpoint**: `POST /api/query`  
**Input**: JSON with `query` and `user_id`  
**Output**: AI-generated response with sources

**Process Flow**:
1. Search for relevant documents
2. Generate AI response using context
3. Track query for analytics
4. Return response with sources

**Example Request**:
```json
{
  "query": "What are the main features of our product?",
  "user_id": "user123"
}
```

**Example Response**:
```json
{
  "query": "What are the main features of our product?",
  "response": "Based on the documents, our product has the following main features...",
  "sources": ["product_spec.pdf", "feature_overview.docx"],
  "timestamp": "2024-01-15T10:30:00Z"
}
```

## Configuration

### Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `STORAGE_CONNECTION_STRING` | Azure Storage connection string | Yes |
| `SEARCH_ENDPOINT` | Azure Cognitive Search endpoint | Yes |
| `SEARCH_API_KEY` | Azure Cognitive Search API key | Yes |
| `OPENAI_ENDPOINT` | Azure OpenAI endpoint | Yes |
| `OPENAI_API_KEY` | Azure OpenAI API key | Yes |
| `FORM_RECOGNIZER_ENDPOINT` | Form Recognizer endpoint | No |
| `FORM_RECOGNIZER_KEY` | Form Recognizer API key | No |
| `HOT_CONTAINER_NAME` | Hot storage container name | No |
| `ARCHIVE_CONTAINER_NAME` | Archive container name | No |
| `ACCESS_THRESHOLD_DAYS` | Days before moving to cool tier | No |
| `ARCHIVE_THRESHOLD_DAYS` | Days before moving to archive | No |
| `DELETE_THRESHOLD_DAYS` | Days before deletion | No |

### Storage Containers

The functions expect the following containers:
- `documents` - Main document storage
- `hot-documents` - Frequently accessed documents
- `archive` - Archived documents
- `processed` - Processed text content
- `metadata` - Access logs and metadata

## Error Handling

All functions include comprehensive error handling:
- Graceful degradation when services are unavailable
- Detailed logging for troubleshooting
- Non-blocking operations for non-critical features
- Retry logic for transient failures

## Monitoring and Logging

- Application Insights integration for monitoring
- Structured logging for all operations
- Query and access tracking for analytics
- Performance metrics collection

## Security Considerations

- Function-level authentication
- Secure storage of API keys
- Input validation and sanitization
- Access control through Azure AD integration

## Performance Optimization

- Async operations where possible
- Efficient blob operations
- Semantic search for better relevance
- Content truncation for large documents
- Connection pooling for Azure services 