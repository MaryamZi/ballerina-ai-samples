import ballerina/ai;
import ballerina/io;
import ballerinax/ai.pinecone;

configurable string pineconeServiceUrl = ?;
configurable string pineconeApiKey = ?;

final ai:VectorStore vectorStore = 
            check new pinecone:VectorStore(pineconeServiceUrl, pineconeApiKey);

final ai:EmbeddingProvider embeddingProvider = 
            check ai:getDefaultEmbeddingProvider();

final ai:KnowledgeBase knowledgeBase = 
            new ai:VectorKnowledgeBase(vectorStore, embeddingProvider);

function ingest(string filePath) returns error? {
    ai:TextDocument doc = {content: check io:fileReadString(filePath)};
    check knowledgeBase.ingest(doc);
}

function ingestMdPdf(string filePath) returns error? {
    ai:TextDataLoader loader = check new (filePath);
    ai:Document|ai:Document[] documents = check loader.load();
    ai:Chunker chunker = new ai:MarkdownChunker();

    if documents is ai:Document {
        ai:Chunk[] chunks = check chunker.chunk(documents);
        check knowledgeBase.ingest(chunks);
        return;
    }
    
    foreach ai:Document document in documents {
        ai:Chunk[] chunks = check chunker.chunk(document);
        check knowledgeBase.ingest(chunks);        
    }
}
