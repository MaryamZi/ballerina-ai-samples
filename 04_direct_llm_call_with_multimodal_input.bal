import ballerina/ai;
import ballerina/io;
import ballerinax/ai.anthropic;

configurable anthropic:ANTHROPIC_MODEL_NAMES model = ?;
configurable string apiKey = ?;

final ai:ModelProvider llm =
    check new anthropic:ModelProvider(apiKey, modelType = model, maxTokens = 1024);

public function main() returns error? {
    ai:ImageDocument image = {
        content: "https://upload.wikimedia.org/wikipedia/commons/a/a7/Camponotus_flavomarginatus_ant.jpg"
    };

    // The `generate` method
    string description1 = check llm->generate(`
        Describe this image.

        ${image}`);
    io:println(description1);

    // The `natural` expression
    string description2 = check natural (llm) {
        Describe this image.

        ${image}
    };
    io:println(description2);

    // With in-line image record
    string description3 = check natural (llm) {
        Describe this image.

        ${<ai:ImageDocument> {
            content: "https://upload.wikimedia.org/wikipedia/commons/a/a7/Camponotus_flavomarginatus_ant.jpg"
        }}
    };
    io:println(description3);
}
