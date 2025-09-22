// Note: not generally expected to be used directly.

import ballerina/mcp;

final mcp:StreamableHttpClient mcpClient = check new ("http://localhost:9090/mcp");

public function main() returns mcp:ClientError? {
    mcp:ListToolsResult tools = check mcpClient->listTools();

    mcp:CallToolResult result = check mcpClient->callTool({
        name: "getCurrentWeather",
        arguments: { "city": "New York" }
    });
}
