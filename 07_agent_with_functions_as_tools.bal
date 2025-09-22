import ballerina/ai;
import ballerina/http;
import ballerina/io;
import ballerina/time;

final ai:Agent todoAgent = check new ({
    systemPrompt: {
        role: "Task Assistant", 
        instructions: string `You are a helpful assistant for 
            managing a to-do list. You can manage tasks and
            help a user plan their schedule.`
    },
    tools: [addTask, deleteTask, listTasks, completeTask],
    model: check ai:getDefaultModelProvider(),
    memory: new ai:MessageWindowChatMemory(20)
});

public function main() returns error? {
    string response = 
        check todoAgent.run("What's on my plate today?");
    io:println(response);
}

service /todo on new ai:Listener(8080) {
    resource function post chat(@http:Payload ai:ChatReqMessage request) returns ai:ChatRespMessage|error {
        string response = check todoAgent.run(request.message, request.sessionId);
        return {message: response};
    }
}

@ai:AgentTool
isolated function addTask(Task task) returns error? {
    
}

@ai:AgentTool
isolated function deleteTask(string task) returns error? {
    
}

@ai:AgentTool
isolated function listTasks() returns Task[]|error {
    return [];
}

@ai:AgentTool
isolated function completeTask(string task) returns error? {
    
}

type Task record {
    string id;
    string description;
    time:Date createdAt;
    time:Date? completedAt = ();
    boolean completed = false;
};