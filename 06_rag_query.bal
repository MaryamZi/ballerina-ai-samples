import ballerina/ai;
import ballerinax/ai.pinecone;
import ballerina/io;

configurable string pineconeServiceUrl = ?;
configurable string pineconeApiKey = ?;

final ai:VectorStore vectorStore = 
            check new pinecone:VectorStore(pineconeServiceUrl, pineconeApiKey);

final ai:EmbeddingProvider embeddingProvider = 
            check ai:getDefaultEmbeddingProvider();

final ai:KnowledgeBase knowledgeBase = 
            new ai:VectorKnowledgeBase(vectorStore, embeddingProvider);

final ai:ModelProvider modelProvider = check ai:getDefaultModelProvider();

function queryWithContext(string query) returns error? {
    ai:QueryMatch[] queryMatches = check knowledgeBase.retrieve(query, 10);
    ai:Chunk[] context = from ai:QueryMatch queryMatch in queryMatches
                            select queryMatch.chunk;

    // The `generate` method
    string? res1 = check modelProvider->generate(`Answer the query based on the 
	    following context:

        Context: ${context}

        Query: ${query}

        Answer only if you are absolutely sure, based on the provided context.`);
    io:println(res1);

    // The `natural` expression
    string? res2 = check natural (modelProvider) {
        Answer the query based on the following context:

        Context: ${context}

        Question: ${query}

        Answer only if you are absolutely sure, based on the provided context.
    };    
    io:println(res2);

    // The `generate` method with the `augmentUserQuery` function
    ai:ChatUserMessage augmentedQuery = ai:augmentUserQuery(context, query);
    ai:Prompt prompt = check augmentedQuery.content.ensureType();
    string res3 = check modelProvider->generate(prompt);
    io:println(res3);
}