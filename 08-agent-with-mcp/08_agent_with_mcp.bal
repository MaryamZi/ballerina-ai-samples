import ballerina/ai;
import ballerina/io;

final ai:ModelProvider model = check ai:getDefaultModelProvider();

public function main() returns error? {
    final ai:McpToolKit|error weatherMcpConn = new (
        "http://localhost:9090/mcp", 
        ["getCurrentWeather"], 
        info = {
            name: "Weather MCP server",
            version: "1.0"
        });

    if weatherMcpConn is error {
        io:println("Error creating MCP tool kit: " + weatherMcpConn.message());
        return;
    }

    final ai:Agent weatherAgent = check new (
        systemPrompt = {
            role: "Weather AI Assistant",
            instructions: string `You are a smart AI assistant that can assist 
                a user based on accurate and timely weather information.`
        }, model = model, tools = [weatherMcpConn]
    );

    while true {
        string user = io:readln("User: ");
        string agent = check weatherAgent.run(user);
        io:println("Agent: " + agent);
    }
}
