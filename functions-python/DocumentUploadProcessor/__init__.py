import azure.functions as func
import logging
import os
import json
from datetime import datetime
from azure.storage.blob import BlobServiceClient
from azure.search.documents import SearchClient
from azure.core.credentials import AzureKeyCredential
from azure.cognitiveservices.vision.formrecognizer import FormRecognizerClient
from azure.cognitiveservices.vision.formrecognizer.models import AnalyzeDocumentRequest
import PyPDF2
import docx
import io
from PIL import Image
import pytesseract

def main(blob: func.InputStream, name: str):
    """
    Process uploaded documents: extract text, store processed content, and index in search
    """
    logging.info(f"Processing document: {name}")
    
    try:
        # Extract text from document
        content = extract_document_text(blob, name)
        
        # Store processed content
        store_processed_content(name, content)
        
        # Index document in search
        index_document(name, content)
        
        # Track document access
        track_document_access(name, "upload")
        
        logging.info(f"Document {name} processed successfully")
        
    except Exception as e:
        logging.error(f"Error processing document {name}: {str(e)}")
        raise

def extract_document_text(blob, filename):
    """
    Extract text from various document formats
    """
    file_content = blob.read()
    file_extension = filename.lower().split('.')[-1]
    
    try:
        if file_extension == 'pdf':
            return extract_pdf_text(file_content)
        elif file_extension == 'docx':
            return extract_docx_text(file_content)
        elif file_extension == 'txt':
            return file_content.decode('utf-8')
        elif file_extension in ['jpg', 'jpeg', 'png', 'tiff']:
            return extract_image_text(file_content)
        else:
            # Try Form Recognizer for other formats
            return extract_with_form_recognizer(file_content, filename)
    except Exception as e:
        logging.warning(f"Could not extract text from {filename}: {str(e)}")
        return f"Document: {filename}\nType: {file_extension}\nSize: {len(file_content)} bytes"

def extract_pdf_text(file_content):
    """Extract text from PDF files"""
    pdf_reader = PyPDF2.PdfReader(io.BytesIO(file_content))
    text = ""
    for page in pdf_reader.pages:
        text += page.extract_text() + "\n"
    return text.strip()

def extract_docx_text(file_content):
    """Extract text from DOCX files"""
    doc = docx.Document(io.BytesIO(file_content))
    text = ""
    for paragraph in doc.paragraphs:
        text += paragraph.text + "\n"
    return text.strip()

def extract_image_text(file_content):
    """Extract text from images using OCR"""
    try:
        image = Image.open(io.BytesIO(file_content))
        text = pytesseract.image_to_string(image)
        return text.strip()
    except Exception as e:
        logging.warning(f"OCR failed: {str(e)}")
        return "Image document - OCR processing failed"

def extract_with_form_recognizer(file_content, filename):
    """Extract text using Azure Form Recognizer"""
    try:
        endpoint = os.environ.get("FORM_RECOGNIZER_ENDPOINT")
        key = os.environ.get("FORM_RECOGNIZER_KEY")
        
        if not endpoint or not key:
            return f"Document: {filename} - Form Recognizer not configured"
        
        form_recognizer_client = FormRecognizerClient(endpoint, AzureKeyCredential(key))
        
        poller = form_recognizer_client.begin_analyze_document(
            "prebuilt-document", file_content
        )
        result = poller.result()
        
        text = ""
        for page in result.pages:
            for line in page.lines:
                text += line.content + "\n"
        
        return text.strip()
    except Exception as e:
        logging.warning(f"Form Recognizer failed: {str(e)}")
        return f"Document: {filename} - Form Recognizer processing failed"

def store_processed_content(filename, content):
    """Store processed text content in the processed container"""
    try:
        connection_string = os.environ.get("STORAGE_CONNECTION_STRING")
        blob_service_client = BlobServiceClient.from_connection_string(connection_string)
        
        container_name = "processed"
        container_client = blob_service_client.get_container_client(container_name)
        
        # Create container if it doesn't exist
        try:
            container_client.get_container_properties()
        except:
            blob_service_client.create_container(container_name)
        
        # Store processed content
        blob_name = f"{filename}.txt"
        blob_client = container_client.get_blob_client(blob_name)
        
        blob_client.upload_blob(content.encode('utf-8'), overwrite=True)
        logging.info(f"Stored processed content for {filename}")
        
    except Exception as e:
        logging.error(f"Failed to store processed content for {filename}: {str(e)}")
        raise

def index_document(filename, content):
    """Index document in Azure Cognitive Search"""
    try:
        endpoint = os.environ.get("SEARCH_ENDPOINT")
        key = os.environ.get("SEARCH_API_KEY")
        
        if not endpoint or not key:
            logging.warning("Search service not configured, skipping indexing")
            return
        
        search_client = SearchClient(
            endpoint=endpoint,
            index_name="documents",
            credential=AzureKeyCredential(key)
        )
        
        # Prepare document for indexing
        document = {
            "id": filename,
            "filename": filename,
            "content": content,
            "upload_date": datetime.utcnow().isoformat(),
            "file_type": filename.split('.')[-1].lower(),
            "content_length": len(content)
        }
        
        # Index the document
        search_client.upload_documents([document])
        logging.info(f"Indexed document {filename} in search")
        
    except Exception as e:
        logging.error(f"Failed to index document {filename}: {str(e)}")
        # Don't raise here - indexing failure shouldn't fail the whole process

def track_document_access(filename, access_type):
    """Track document access for analytics"""
    try:
        # Store access metadata
        connection_string = os.environ.get("STORAGE_CONNECTION_STRING")
        blob_service_client = BlobServiceClient.from_connection_string(connection_string)
        
        container_name = os.environ.get("METADATA_CONTAINER_NAME", "metadata")
        container_client = blob_service_client.get_container_client(container_name)
        
        # Create container if it doesn't exist
        try:
            container_client.get_container_properties()
        except:
            blob_service_client.create_container(container_name)
        
        # Store access metadata
        metadata = {
            "filename": filename,
            "access_type": access_type,
            "access_time": datetime.utcnow().isoformat(),
            "access_count": 1
        }
        
        blob_name = f"access_logs/{filename}_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}.json"
        blob_client = container_client.get_blob_client(blob_name)
        blob_client.upload_blob(json.dumps(metadata).encode('utf-8'))
        
    except Exception as e:
        logging.warning(f"Failed to track access for {filename}: {str(e)}")
        # Don't raise here - tracking failure shouldn't fail the whole process 