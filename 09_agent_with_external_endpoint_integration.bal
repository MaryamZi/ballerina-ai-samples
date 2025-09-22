// Modified from https://github.com/ballerina-platform/module-ballerina-ai/tree/main/examples/personal-ai-assistant 

import ballerina/ai;
import ballerina/io;
import ballerinax/googleapis.calendar;
import ballerinax/googleapis.gmail;

configurable string refreshToken = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshUrl = ?;

configurable string userEmail = ?;

final gmail:Client gmailClient = check new ({
    auth: {refreshToken: refreshToken, clientId, clientSecret, refreshUrl}
});

final calendar:Client calendarClient = check new (config = {
    auth: {clientId, clientSecret, refreshToken: refreshToken, refreshUrl}
});

@ai:AgentTool
isolated function readUnreadEmails() returns gmail:Message[]|error {
    gmail:ListMessagesResponse messageList = 
        check gmailClient->/users/me/messages(q = "label:INBOX is:unread");
    gmail:Message[]? messages = messageList.messages;

    if messages is () {
        return [];
    }

    gmail:Message[] completeMessages = from gmail:Message message in messages
        select check gmailClient->/users/me/messages/[message.id](format = "full");
    return completeMessages;
}

@ai:AgentTool
isolated function sendEmail(string[] to, string subject, string body) returns gmail:Message|error {
    return gmailClient->/users/me/messages/send.post({to, subject, bodyInText: body});
}

@ai:AgentTool
isolated function getCalendarEvents() returns stream<calendar:Event, error?>|error {
    return calendarClient->getEvents(userEmail);
}

@ai:AgentTool
isolated function createCalendarEvent(calendar:InputEvent event) returns calendar:Event|error {
    return calendarClient->createEvent(userEmail, event);
}

ai:SystemPrompt systemPrompt = {
    role: "Personal AI Assistant",
    instructions: string `You are an intelligent personal AI assistant designed to 
        help users stay organized and efficient.

        ...

        Guidelines:
        - Respond in a natural, friendly, and professional tone.
        - Always confirm before making changes to the user's calendar or sending emails.
        - Provide concise summaries when retrieving information unless the user requests details.
        - Prioritize clarity, efficiency, and user convenience in all tasks.`
};

final ai:Agent personalAssistantAgent = check new (
    systemPrompt = systemPrompt,
    model = check ai:getDefaultModelProvider(),
    tools = [readUnreadEmails, sendEmail, getCalendarEvents, createCalendarEvent],
    memory = new ai:MessageWindowChatMemory(20),
    verbose = true
);

public function main() returns error? {
    while true {
        string user = io:readln("User: ");
        string agent = check personalAssistantAgent.run(user);
        io:println("Agent: " + agent);
    }
}
