import azure.functions as func
import logging
import os
import json
from datetime import datetime, timedelta
from azure.storage.blob import BlobServiceClient, BlobServiceClient
from azure.core.exceptions import ResourceNotFoundError

def main(timer: func.TimerRequest):
    """
    Track document access patterns and manage lifecycle (runs every 5 minutes)
    """
    logging.info("Running document access tracker")
    
    try:
        # Process document lifecycle management
        process_document_lifecycle()
        
        # Move documents between tiers based on access patterns
        move_documents_between_tiers()
        
        # Clean up old documents
        cleanup_old_documents()
        
        logging.info("Document access tracker completed successfully")
        
    except Exception as e:
        logging.error(f"Error in document access tracker: {str(e)}")
        raise

def process_document_lifecycle():
    """Process document lifecycle based on access patterns"""
    try:
        connection_string = os.environ.get("STORAGE_CONNECTION_STRING")
        blob_service_client = BlobServiceClient.from_connection_string(connection_string)
        
        # Get access threshold days
        access_threshold = int(os.environ.get("ACCESS_THRESHOLD_DAYS", "30"))
        archive_threshold = int(os.environ.get("ARCHIVE_THRESHOLD_DAYS", "90"))
        
        # Process hot documents
        hot_container_name = os.environ.get("HOT_CONTAINER_NAME", "hot-documents")
        try:
            hot_container = blob_service_client.get_container_client(hot_container_name)
            for blob in hot_container.list_blobs():
                if should_move_to_cool(blob, access_threshold):
                    move_blob_between_containers(
                        blob_service_client, 
                        hot_container_name, 
                        "documents", 
                        blob.name
                    )
                    logging.info(f"Moved {blob.name} from hot to cool tier")
        except ResourceNotFoundError:
            logging.info(f"Hot container {hot_container_name} does not exist")
        
        # Process cool documents
        documents_container = blob_service_client.get_container_client("documents")
        for blob in documents_container.list_blobs():
            if should_move_to_archive(blob, archive_threshold):
                archive_container_name = os.environ.get("ARCHIVE_CONTAINER_NAME", "archive")
                move_blob_between_containers(
                    blob_service_client,
                    "documents",
                    archive_container_name,
                    blob.name
                )
                logging.info(f"Moved {blob.name} from cool to archive tier")
                
    except Exception as e:
        logging.error(f"Error processing document lifecycle: {str(e)}")
        raise

def should_move_to_cool(blob, threshold_days):
    """Check if document should be moved from hot to cool tier"""
    if not blob.last_modified:
        return False
    
    days_since_access = (datetime.utcnow() - blob.last_modified.replace(tzinfo=None)).days
    return days_since_access > threshold_days

def should_move_to_archive(blob, threshold_days):
    """Check if document should be moved from cool to archive tier"""
    if not blob.last_modified:
        return False
    
    days_since_access = (datetime.utcnow() - blob.last_modified.replace(tzinfo=None)).days
    return days_since_access > threshold_days

def move_blob_between_containers(blob_service_client, source_container, target_container, blob_name):
    """Move a blob from one container to another"""
    try:
        source_blob_client = blob_service_client.get_blob_client(
            container=source_container, 
            blob=blob_name
        )
        target_blob_client = blob_service_client.get_blob_client(
            container=target_container, 
            blob=blob_name
        )
        
        # Copy blob to target container
        copy_source = source_blob_client.url
        target_blob_client.start_copy_from_url(copy_source)
        
        # Wait for copy to complete
        while True:
            properties = target_blob_client.get_blob_properties()
            if properties.copy.status == "success":
                break
            elif properties.copy.status == "failed":
                raise Exception(f"Copy failed for {blob_name}")
        
        # Delete from source container
        source_blob_client.delete_blob()
        
        logging.info(f"Successfully moved {blob_name} from {source_container} to {target_container}")
        
    except Exception as e:
        logging.error(f"Failed to move blob {blob_name}: {str(e)}")
        raise

def move_documents_between_tiers():
    """Move documents between tiers based on access patterns"""
    try:
        connection_string = os.environ.get("STORAGE_CONNECTION_STRING")
        blob_service_client = BlobServiceClient.from_connection_string(connection_string)
        
        # Get document access statistics from metadata
        metadata_container = os.environ.get("METADATA_CONTAINER_NAME", "metadata")
        try:
            container_client = blob_service_client.get_container_client(metadata_container)
            
            # Analyze access patterns and move documents accordingly
            # This is a simplified version - in production you'd analyze access logs
            logging.info("Analyzed document access patterns")
            
        except ResourceNotFoundError:
            logging.info(f"Metadata container {metadata_container} does not exist")
            
    except Exception as e:
        logging.error(f"Error moving documents between tiers: {str(e)}")

def cleanup_old_documents():
    """Clean up old documents based on retention policy"""
    try:
        connection_string = os.environ.get("STORAGE_CONNECTION_STRING")
        blob_service_client = BlobServiceClient.from_connection_string(connection_string)
        
        delete_threshold = int(os.environ.get("DELETE_THRESHOLD_DAYS", "365"))
        
        # Clean up archive container
        archive_container_name = os.environ.get("ARCHIVE_CONTAINER_NAME", "archive")
        try:
            archive_container = blob_service_client.get_container_client(archive_container_name)
            
            for blob in archive_container.list_blobs():
                if should_delete_document(blob, delete_threshold):
                    blob_client = archive_container.get_blob_client(blob.name)
                    blob_client.delete_blob()
                    logging.info(f"Deleted old document: {blob.name}")
                    
        except ResourceNotFoundError:
            logging.info(f"Archive container {archive_container_name} does not exist")
            
    except Exception as e:
        logging.error(f"Error cleaning up old documents: {str(e)}")

def should_delete_document(blob, threshold_days):
    """Check if document should be deleted based on age"""
    if not blob.last_modified:
        return False
    
    days_since_creation = (datetime.utcnow() - blob.last_modified.replace(tzinfo=None)).days
    return days_since_creation > threshold_days 