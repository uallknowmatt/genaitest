const express = require('express');
const multer = require('multer');
const cors = require('cors');
const path = require('path');
const fs = require('fs');
const { OpenAI } = require('openai');

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// Configure multer for file uploads
const upload = multer({ 
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 10 * 1024 * 1024 // 10MB limit
  }
});

// Initialize OpenAI (you'll need to set OPENAI_API_KEY environment variable)
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY
});

// Create documents directory if it doesn't exist
const documentsDir = path.join(__dirname, 'documents');
if (!fs.existsSync(documentsDir)) {
  fs.mkdirSync(documentsDir, { recursive: true });
}

// In-memory storage for documents (in production, use a proper database)
let documents = [];
let documentIndex = {};

// Simple text search function
function searchDocuments(query) {
  const results = [];
  const queryLower = query.toLowerCase();
  
  documents.forEach(doc => {
    if (doc.content.toLowerCase().includes(queryLower) || 
        doc.filename.toLowerCase().includes(queryLower)) {
      results.push(doc);
    }
  });
  
  return results;
}

// Routes

// Serve the main page
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Upload document
app.post('/api/upload', upload.single('document'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No file uploaded' });
    }

    const file = req.file;
    const filename = file.originalname;
    
    // Extract text content (for demo, we'll use the file buffer as text)
    let content = '';
    if (file.mimetype === 'text/plain') {
      content = file.buffer.toString();
    } else {
      // For other file types, you'd need to implement text extraction
      content = `Document: ${filename}\nType: ${file.mimetype}\nSize: ${file.size} bytes`;
    }
    
    // Save file to local storage
    const filePath = path.join(documentsDir, filename);
    fs.writeFileSync(filePath, file.buffer);
    
    // Store document metadata
    const document = {
      id: Date.now(),
      filename: filename,
      filepath: filePath,
      content: content,
      uploadDate: new Date().toISOString(),
      accessCount: 0,
      lastAccess: new Date().toISOString()
    };
    
    documents.push(document);
    documentIndex[document.id] = document;
    
    console.log(`Document uploaded: ${filename}`);
    
    res.json({ 
      success: true, 
      id: document.id,
      filename: filename,
      message: 'Document uploaded successfully'
    });
    
  } catch (error) {
    console.error('Upload error:', error);
    res.status(500).json({ error: 'Upload failed: ' + error.message });
  }
});

// Get all documents
app.get('/api/documents', (req, res) => {
  try {
    const docList = documents.map(doc => ({
      id: doc.id,
      filename: doc.filename,
      uploadDate: doc.uploadDate,
      accessCount: doc.accessCount,
      lastAccess: doc.lastAccess
    }));
    
    res.json({ documents: docList });
  } catch (error) {
    res.status(500).json({ error: 'Failed to get documents' });
  }
});

// Chat with AI
app.post('/api/chat', async (req, res) => {
  try {
    const { question } = req.body;
    
    if (!question) {
      return res.status(400).json({ error: 'Question is required' });
    }
    
    // Search documents for relevant content
    const searchResults = searchDocuments(question);
    
    // Create context from search results
    let context = '';
    if (searchResults.length > 0) {
      context = searchResults.map(doc => 
        `Document: ${doc.filename}\nContent: ${doc.content.substring(0, 500)}...`
      ).join('\n\n');
    } else {
      context = 'No relevant documents found.';
    }
    
    // Update access counts
    searchResults.forEach(doc => {
      doc.accessCount++;
      doc.lastAccess = new Date().toISOString();
    });
    
    // Generate AI response
    let aiResponse = '';
    
    if (process.env.OPENAI_API_KEY) {
      try {
        const completion = await openai.chat.completions.create({
          model: "gpt-3.5-turbo",
          messages: [
            {
              role: "system",
              content: `You are a helpful assistant that answers questions based on the provided document context. 
              If the context doesn't contain relevant information, say so. 
              Keep responses concise and accurate.`
            },
            {
              role: "user",
              content: `Context:\n${context}\n\nQuestion: ${question}`
            }
          ],
          max_tokens: 500,
          temperature: 0.7
        });
        
        aiResponse = completion.choices[0].message.content;
      } catch (openaiError) {
        console.error('OpenAI error:', openaiError);
        aiResponse = `I'm sorry, I couldn't process your request. Error: ${openaiError.message}`;
      }
    } else {
      aiResponse = `I found ${searchResults.length} relevant document(s). 
      To get AI-powered responses, please set the OPENAI_API_KEY environment variable.`;
    }
    
    res.json({ 
      answer: aiResponse,
      documentsFound: searchResults.length,
      relevantDocuments: searchResults.map(doc => doc.filename)
    });
    
  } catch (error) {
    console.error('Chat error:', error);
    res.status(500).json({ error: 'Chat failed: ' + error.message });
  }
});

// Delete document
app.delete('/api/documents/:id', (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const document = documentIndex[id];
    
    if (!document) {
      return res.status(404).json({ error: 'Document not found' });
    }
    
    // Remove file from storage
    if (fs.existsSync(document.filepath)) {
      fs.unlinkSync(document.filepath);
    }
    
    // Remove from memory
    documents = documents.filter(doc => doc.id !== id);
    delete documentIndex[id];
    
    res.json({ success: true, message: 'Document deleted successfully' });
    
  } catch (error) {
    res.status(500).json({ error: 'Delete failed: ' + error.message });
  }
});

// Health check
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'healthy',
    documentsCount: documents.length,
    openaiAvailable: !!process.env.OPENAI_API_KEY
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 DocAI Local Server running on http://localhost:${PORT}`);
  console.log(`📁 Documents stored in: ${documentsDir}`);
  console.log(`🤖 OpenAI API: ${process.env.OPENAI_API_KEY ? 'Available' : 'Not configured'}`);
  console.log(`📊 Total documents: ${documents.length}`);
});

module.exports = app; 