using System;
using System.Threading.Tasks;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;
using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using System.Text.Json;
using System.Collections.Generic;
using System.Linq;

namespace DocAI.Functions
{
    public class DocumentManagementFunction
    {
        private readonly BlobServiceClient _blobServiceClient;
        private readonly ILogger<DocumentManagementFunction> _logger;

        public DocumentManagementFunction(BlobServiceClient blobServiceClient, ILogger<DocumentManagementFunction> logger)
        {
            _blobServiceClient = blobServiceClient;
            _logger = logger;
        }

        [FunctionName("DocumentAccessTracker")]
        public async Task RunDocumentAccessTracker(
            [TimerTrigger("0 */5 * * * *")] TimerInfo myTimer, // Every 5 minutes
            ILogger log)
        {
            log.LogInformation($"Document access tracker executed at: {DateTime.Now}");

            try
            {
                await ProcessDocumentAccess();
                await MoveDocumentsBetweenTiers();
                await CleanupOldDocuments();
            }
            catch (Exception ex)
            {
                log.LogError($"Error in document access tracker: {ex.Message}");
                throw;
            }
        }

        [FunctionName("DocumentUploadProcessor")]
        public async Task RunDocumentUploadProcessor(
            [BlobTrigger("documents/{name}", Connection = "STORAGE_CONNECTION_STRING")] BlobClient blob,
            string name,
            ILogger log)
        {
            log.LogInformation($"Processing uploaded document: {name}");

            try
            {
                // Extract text from document
                var extractedText = await ExtractTextFromDocument(blob);
                
                // Store in processed container
                await StoreProcessedContent(name, extractedText);
                
                // Index in search
                await IndexDocumentInSearch(name, extractedText);
                
                // Track initial access
                await TrackDocumentAccess(name, "upload");
                
                log.LogInformation($"Successfully processed document: {name}");
            }
            catch (Exception ex)
            {
                log.LogError($"Error processing document {name}: {ex.Message}");
                throw;
            }
        }

        private async Task ProcessDocumentAccess()
        {
            var hotContainer = _blobServiceClient.GetBlobContainerClient(Environment.GetEnvironmentVariable("HOT_CONTAINER_NAME"));
            var archiveContainer = _blobServiceClient.GetBlobContainerClient(Environment.GetEnvironmentVariable("ARCHIVE_CONTAINER_NAME"));

            // Process hot documents
            await foreach (var blob in hotContainer.GetBlobsAsync())
            {
                var lastAccess = blob.Properties.LastAccessedOn;
                if (lastAccess.HasValue && lastAccess.Value < DateTime.UtcNow.AddDays(-30))
                {
                    // Move to cool tier
                    await MoveBlobBetweenContainers(hotContainer, "documents", blob.Name);
                    _logger.LogInformation($"Moved {blob.Name} from hot to cool tier");
                }
            }

            // Process cool documents
            var documentsContainer = _blobServiceClient.GetBlobContainerClient("documents");
            await foreach (var blob in documentsContainer.GetBlobsAsync())
            {
                var lastAccess = blob.Properties.LastAccessedOn;
                if (lastAccess.HasValue && lastAccess.Value < DateTime.UtcNow.AddDays(-90))
                {
                    // Move to archive
                    await MoveBlobBetweenContainers(documentsContainer, "archive", blob.Name);
                    _logger.LogInformation($"Moved {blob.Name} from cool to archive tier");
                }
            }
        }

        private async Task MoveDocumentsBetweenTiers()
        {
            var accessThreshold = int.Parse(Environment.GetEnvironmentVariable("ACCESS_THRESHOLD_DAYS") ?? "30");
            var archiveThreshold = int.Parse(Environment.GetEnvironmentVariable("ARCHIVE_THRESHOLD_DAYS") ?? "90");

            // Get document access statistics from database
            var documentStats = await GetDocumentAccessStatistics();

            foreach (var stat in documentStats)
            {
                if (stat.AccessCount > 10 && stat.DaysSinceLastAccess < 7)
                {
                    // Frequently accessed document - move to hot tier
                    await PromoteToHotTier(stat.DocumentName);
                }
                else if (stat.DaysSinceLastAccess > archiveThreshold)
                {
                    // Old document - move to archive
                    await ArchiveDocument(stat.DocumentName);
                }
            }
        }

        private async Task CleanupOldDocuments()
        {
            var archiveContainer = _blobServiceClient.GetBlobContainerClient("archive");
            
            await foreach (var blob in archiveContainer.GetBlobsAsync())
            {
                var lastAccess = blob.Properties.LastAccessedOn;
                if (lastAccess.HasValue && lastAccess.Value < DateTime.UtcNow.AddDays(-365))
                {
                    // Delete old archived documents
                    await archiveContainer.DeleteBlobAsync(blob.Name);
                    _logger.LogInformation($"Deleted old archived document: {blob.Name}");
                }
            }
        }

        private async Task<string> ExtractTextFromDocument(BlobClient blob)
        {
            // This would integrate with Azure Form Recognizer or similar service
            // For now, return placeholder
            return $"Extracted text from {blob.Name}";
        }

        private async Task StoreProcessedContent(string documentName, string extractedText)
        {
            var processedContainer = _blobServiceClient.GetBlobContainerClient("processed");
            var blobClient = processedContainer.GetBlobClient($"{documentName}.txt");
            
            using var stream = new MemoryStream(System.Text.Encoding.UTF8.GetBytes(extractedText));
            await blobClient.UploadAsync(stream, overwrite: true);
        }

        private async Task IndexDocumentInSearch(string documentName, string content)
        {
            // This would integrate with Azure Cognitive Search
            // For now, just log the action
            _logger.LogInformation($"Indexing document {documentName} in search");
        }

        private async Task TrackDocumentAccess(string documentName, string accessType)
        {
            // This would update the database with access information
            _logger.LogInformation($"Tracking access to {documentName} with type {accessType}");
        }

        private async Task MoveBlobBetweenContainers(BlobContainerClient sourceContainer, string targetContainerName, string blobName)
        {
            var targetContainer = _blobServiceClient.GetBlobContainerClient(targetContainerName);
            var sourceBlob = sourceContainer.GetBlobClient(blobName);
            var targetBlob = targetContainer.GetBlobClient(blobName);

            // Copy to target
            await targetBlob.StartCopyFromUriAsync(sourceBlob.Uri);
            
            // Wait for copy to complete
            while (true)
            {
                var properties = await targetBlob.GetPropertiesAsync();
                if (properties.Value.CopyStatus == CopyStatus.Success)
                    break;
                await Task.Delay(1000);
            }

            // Delete from source
            await sourceBlob.DeleteAsync();
        }

        private async Task<List<DocumentStat>> GetDocumentAccessStatistics()
        {
            // This would query the database for document access statistics
            // For now, return empty list
            return new List<DocumentStat>();
        }

        private async Task PromoteToHotTier(string documentName)
        {
            var documentsContainer = _blobServiceClient.GetBlobContainerClient("documents");
            var hotContainer = _blobServiceClient.GetBlobContainerClient("hot-documents");
            
            await MoveBlobBetweenContainers(documentsContainer, "hot-documents", documentName);
            _logger.LogInformation($"Promoted {documentName} to hot tier");
        }

        private async Task ArchiveDocument(string documentName)
        {
            var documentsContainer = _blobServiceClient.GetBlobContainerClient("documents");
            var archiveContainer = _blobServiceClient.GetBlobContainerClient("archive");
            
            await MoveBlobBetweenContainers(documentsContainer, "archive", documentName);
            _logger.LogInformation($"Archived {documentName}");
        }
    }

    public class DocumentStat
    {
        public string DocumentName { get; set; }
        public int AccessCount { get; set; }
        public int DaysSinceLastAccess { get; set; }
        public string CurrentTier { get; set; }
    }
} 