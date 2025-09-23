import ballerina/ai;
import ballerina/io;

final ai:ModelProvider model = check ai:getDefaultModelProvider();

final string subject = "programming";

public function main() returns error? {
    ai:ChatUserMessage userMessage = {
        role: ai:USER,
        content: string `Tell me a joke about ${subject}!`
    };
    ai:ChatMessage[] messages = [userMessage];

    ai:ChatAssistantMessage assistantMessage = check model->chat(userMessage);

    messages.push(assistantMessage);
    string? joke = assistantMessage?.content;
    io:println(joke);

    messages.push({
        role: ai:USER,
        content: "Can you explain it?"
    });
    ai:ChatAssistantMessage assistantMessage2 = check model->chat(messages);
    string? explanation = assistantMessage2?.content;
    io:println(explanation);
}
