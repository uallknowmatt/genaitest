# 🆓 DocAI Local - Free Document Management & AI Chatbot

A **100% free** local document management and AI chatbot system that runs entirely on your computer with zero ongoing costs.

## 🎯 **Features**

- ✅ **Document Upload** - Upload and store documents locally
- ✅ **AI Chat** - Ask questions about your documents using OpenAI
- ✅ **Local Storage** - All data stored on your computer
- ✅ **No Monthly Costs** - Completely free to run
- ✅ **Offline Capable** - Works without internet (except for AI responses)
- ✅ **Modern UI** - Beautiful, responsive web interface
- ✅ **Drag & Drop** - Easy file upload interface

## 🚀 **Quick Start**

### **Prerequisites**
- Node.js (version 14 or higher)
- OpenAI API key (optional, for AI responses)

### **1. Install Dependencies**
```bash
cd local-app
npm install
```

### **2. Set OpenAI API Key (Optional)**
```bash
# Windows
set OPENAI_API_KEY=your-openai-api-key-here

# macOS/Linux
export OPENAI_API_KEY=your-openai-api-key-here
```

**Note**: If you don't set the API key, the system will still work but won't provide AI-powered responses.

### **3. Start the Application**
```bash
npm start
```

### **4. Access the Application**
Open your browser and go to: `http://localhost:3000`

## 📁 **Project Structure**

```
local-app/
├── app.js              # Main server application
├── package.json        # Node.js dependencies
├── public/
│   └── index.html      # Web interface
├── documents/          # Local document storage (created automatically)
└── README.md          # This file
```

## 🛠️ **How It Works**

### **Architecture**
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Local Files   │    │  In-Memory DB   │    │  OpenAI API     │
│   System        │    │  (Documents)    │    │  (AI Responses) │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │  Express.js     │
                    │  Web Server     │
                    └─────────────────┘
```

### **Data Flow**
1. **Upload** → Document saved to local file system
2. **Index** → Document content stored in memory
3. **Search** → Simple text search through documents
4. **AI Chat** → OpenAI generates responses based on document context

## 💰 **Cost Breakdown**

| Component | Cost | Notes |
|-----------|------|-------|
| **Local Storage** | $0 | Uses your computer's hard drive |
| **Web Server** | $0 | Runs on your computer |
| **Database** | $0 | In-memory storage |
| **AI Responses** | $0-5/month | OpenAI free tier ($5 credit) |
| **Total** | **$0-5/month** | Much cheaper than cloud solutions |

## 🔧 **Configuration**

### **Environment Variables**
```bash
# Required for AI responses
OPENAI_API_KEY=your-openai-api-key

# Optional: Change port
PORT=3000
```

### **File Size Limits**
- **Default**: 10MB per file
- **Supported formats**: .txt, .pdf, .doc, .docx, .md
- **Storage location**: `./documents/` folder

## 📊 **API Endpoints**

### **Upload Document**
```http
POST /api/upload
Content-Type: multipart/form-data

Response: {
  "success": true,
  "id": 1234567890,
  "filename": "document.pdf",
  "message": "Document uploaded successfully"
}
```

### **Get Documents**
```http
GET /api/documents

Response: {
  "documents": [
    {
      "id": 1234567890,
      "filename": "document.pdf",
      "uploadDate": "2024-01-15T10:30:00.000Z",
      "accessCount": 5,
      "lastAccess": "2024-01-15T11:00:00.000Z"
    }
  ]
}
```

### **Chat with AI**
```http
POST /api/chat
Content-Type: application/json

{
  "question": "What is the main topic of the documents?"
}

Response: {
  "answer": "Based on the documents, the main topic is...",
  "documentsFound": 2,
  "relevantDocuments": ["document1.pdf", "document2.txt"]
}
```

### **Delete Document**
```http
DELETE /api/documents/1234567890

Response: {
  "success": true,
  "message": "Document deleted successfully"
}
```

### **Health Check**
```http
GET /api/health

Response: {
  "status": "healthy",
  "documentsCount": 5,
  "openaiAvailable": true
}
```

## 🎨 **Features**

### **Document Management**
- ✅ Upload multiple file types
- ✅ Drag & drop interface
- ✅ Document metadata tracking
- ✅ Delete documents
- ✅ Access count tracking

### **AI Chat**
- ✅ Context-aware responses
- ✅ Document-based answers
- ✅ Search through all documents
- ✅ Relevant document highlighting

### **User Interface**
- ✅ Modern, responsive design
- ✅ Real-time chat interface
- ✅ Document list with metadata
- ✅ Status notifications
- ✅ Loading indicators

## 🔒 **Security & Privacy**

### **Data Privacy**
- ✅ **100% Local** - No data sent to external servers (except OpenAI)
- ✅ **No Cloud Storage** - All documents stay on your computer
- ✅ **No Analytics** - No tracking or monitoring
- ✅ **No Registration** - No accounts or personal data required

### **Security Features**
- ✅ **File Validation** - Checks file types and sizes
- ✅ **Path Sanitization** - Prevents directory traversal attacks
- ✅ **Error Handling** - Graceful error management
- ✅ **CORS Protection** - Configurable cross-origin requests

## 🚀 **Development**

### **Development Mode**
```bash
npm run dev
```
Uses nodemon for automatic server restart on file changes.

### **Adding Features**
1. **New File Types**: Modify the upload handler in `app.js`
2. **Better Search**: Replace the simple search with Elasticsearch
3. **Database**: Add SQLite for persistent storage
4. **Authentication**: Add user login system

### **Customization**
- **UI Colors**: Modify CSS variables in `index.html`
- **File Limits**: Change limits in `app.js`
- **Port**: Set PORT environment variable
- **Storage Location**: Modify `documentsDir` in `app.js`

## 🐛 **Troubleshooting**

### **Common Issues**

#### **Port Already in Use**
```bash
# Change port
set PORT=3001
npm start
```

#### **OpenAI API Errors**
- Check your API key is correct
- Verify you have credits in your OpenAI account
- Check internet connection

#### **File Upload Fails**
- Check file size (max 10MB)
- Verify file type is supported
- Ensure you have write permissions to the documents folder

#### **Documents Not Loading**
- Check the documents folder exists
- Verify file permissions
- Restart the application

### **Logs**
The application logs to the console. Check for:
- Upload confirmations
- Search results
- Error messages
- API responses

## 📈 **Scaling Options**

### **For More Documents**
- Add SQLite database for persistent storage
- Implement document compression
- Add file deduplication

### **For Better Search**
- Integrate Elasticsearch
- Add full-text search capabilities
- Implement fuzzy matching

### **For Multiple Users**
- Add user authentication
- Implement document sharing
- Add role-based access control

## 🤝 **Contributing**

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 **Support**

For support and questions:
- Create an issue in the repository
- Check the troubleshooting section
- Review the API documentation

---

**Enjoy your free, local document management and AI chatbot system! 🎉** 