import ballerina/ai;
import ballerina/io;
// import ballerinax/ai.azure;

// For the default model provider (with configuration in the Config.toml file)
final ai:ModelProvider model = check ai:getDefaultModelProvider();

// // Or for specific models
// configurable string serviceUrl = ?;
// configurable string apiKey = ?;
// configurable string deploymentId = ?;
// configurable string apiVersion = ?;
// final ai:ModelProvider azureOpenAIModel = check new azure:OpenAiModelProvider(
//                                         serviceUrl, apiKey, deploymentId, apiVersion);

final string subject = "programming";

public function main() returns error? {
    // The `generate` method
    string joke1 = check model->generate(`Tell me a joke about ${subject}!`);
    io:println(joke1);

    // The `natural` expression
    string joke2 = check natural (model) {
        Tell me a joke about ${subject}!
    };
    io:println(joke2);
}
