import azure.functions as func
import logging
import os
import json
from datetime import datetime
from azure.storage.blob import BlobServiceClient
from azure.search.documents import SearchClient
from azure.core.credentials import AzureKeyCredential
from openai import AzureOpenAI
import re

def main(req: func.HttpRequest) -> func.HttpResponse:
    """
    Process AI queries against document content using Azure OpenAI
    """
    logging.info('AI Query Processor function processed a request.')
    
    try:
        # Parse request body
        req_body = req.get_json()
        query = req_body.get('query', '')
        user_id = req_body.get('user_id', 'anonymous')
        
        if not query:
            return func.HttpResponse(
                json.dumps({"error": "Query is required"}),
                status_code=400,
                mimetype="application/json"
            )
        
        # Search for relevant documents
        relevant_docs = search_documents(query)
        
        # Generate AI response
        ai_response = generate_ai_response(query, relevant_docs)
        
        # Track query
        track_query(query, user_id, relevant_docs)
        
        # Return response
        response_data = {
            "query": query,
            "response": ai_response,
            "sources": [doc.get('filename', '') for doc in relevant_docs],
            "timestamp": datetime.utcnow().isoformat()
        }
        
        return func.HttpResponse(
            json.dumps(response_data),
            status_code=200,
            mimetype="application/json"
        )
        
    except Exception as e:
        logging.error(f"Error processing query: {str(e)}")
        return func.HttpResponse(
            json.dumps({"error": "Internal server error"}),
            status_code=500,
            mimetype="application/json"
        )

def search_documents(query):
    """Search for relevant documents using Azure Cognitive Search"""
    try:
        endpoint = os.environ.get("SEARCH_ENDPOINT")
        key = os.environ.get("SEARCH_API_KEY")
        
        if not endpoint or not key:
            logging.warning("Search service not configured")
            return []
        
        search_client = SearchClient(
            endpoint=endpoint,
            index_name="documents",
            credential=AzureKeyCredential(key)
        )
        
        # Perform semantic search
        search_results = search_client.search(
            search_text=query,
            select=["filename", "content", "upload_date"],
            top=5,
            query_type="semantic",
            query_language="en-us",
            semantic_configuration_name="default"
        )
        
        relevant_docs = []
        for result in search_results:
            relevant_docs.append({
                "filename": result.get("filename", ""),
                "content": result.get("content", ""),
                "upload_date": result.get("upload_date", ""),
                "score": result.get("@search.score", 0)
            })
        
        logging.info(f"Found {len(relevant_docs)} relevant documents")
        return relevant_docs
        
    except Exception as e:
        logging.error(f"Error searching documents: {str(e)}")
        return []

def generate_ai_response(query, relevant_docs):
    """Generate AI response using Azure OpenAI"""
    try:
        endpoint = os.environ.get("OPENAI_ENDPOINT")
        key = os.environ.get("OPENAI_API_KEY")
        
        if not endpoint or not key:
            return "AI service not configured. Please contact administrator."
        
        client = AzureOpenAI(
            azure_endpoint=endpoint,
            api_key=key,
            api_version="2024-02-15-preview"
        )
        
        # Prepare context from relevant documents
        context = prepare_context(relevant_docs)
        
        # Create system prompt
        system_prompt = """You are a helpful AI assistant that answers questions based on the provided document content. 
        Always provide accurate information based on the documents. If the documents don't contain relevant information, 
        say so clearly. Cite specific documents when possible."""
        
        # Create user message
        user_message = f"""Based on the following document content, please answer this question: {query}

Document Content:
{context}

Please provide a comprehensive answer based on the document content above."""
        
        # Generate response
        response = client.chat.completions.create(
            model="gpt-4",
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_message}
            ],
            max_tokens=1000,
            temperature=0.3
        )
        
        return response.choices[0].message.content
        
    except Exception as e:
        logging.error(f"Error generating AI response: {str(e)}")
        return f"Sorry, I encountered an error while processing your query: {str(e)}"

def prepare_context(relevant_docs):
    """Prepare context from relevant documents"""
    if not relevant_docs:
        return "No relevant documents found."
    
    context_parts = []
    for i, doc in enumerate(relevant_docs, 1):
        content = doc.get('content', '')
        filename = doc.get('filename', 'Unknown')
        
        # Truncate content if too long
        if len(content) > 2000:
            content = content[:2000] + "..."
        
        context_parts.append(f"Document {i} ({filename}):\n{content}\n")
    
    return "\n".join(context_parts)

def track_query(query, user_id, relevant_docs):
    """Track query for analytics"""
    try:
        connection_string = os.environ.get("STORAGE_CONNECTION_STRING")
        blob_service_client = BlobServiceClient.from_connection_string(connection_string)
        
        container_name = os.environ.get("METADATA_CONTAINER_NAME", "metadata")
        container_client = blob_service_client.get_container_client(container_name)
        
        # Create container if it doesn't exist
        try:
            container_client.get_container_properties()
        except:
            blob_service_client.create_container(container_name)
        
        # Store query metadata
        query_data = {
            "query": query,
            "user_id": user_id,
            "timestamp": datetime.utcnow().isoformat(),
            "documents_found": len(relevant_docs),
            "document_names": [doc.get('filename', '') for doc in relevant_docs]
        }
        
        blob_name = f"queries/{user_id}_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}.json"
        blob_client = container_client.get_blob_client(blob_name)
        blob_client.upload_blob(json.dumps(query_data).encode('utf-8'))
        
    except Exception as e:
        logging.warning(f"Failed to track query: {str(e)}")
        # Don't raise here - tracking failure shouldn't fail the whole process 