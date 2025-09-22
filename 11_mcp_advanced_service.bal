// Modified from https://github.com/AzeemMuzammil/module-ballerina-mcp/tree/fb-documentation/examples/servers/mcp-weather-server

import ballerina/mcp;
import ballerina/time;
import ballerina/random;

type Weather record {|
    string location;
    decimal temperature;
    int humidity;
    int pressure;
    string condition;
    string timestamp;
|};

type ForecastItem record {|
    string date;
    int high;
    int low;
    string condition;
    int precipitation_chance;
    int wind_speed;
|};

type WeatherForecast record {|
    string location;
    ForecastItem[] forecast;
|};

@mcp:ServiceConfig {
    info: {
        name: "MCP Weather Server",
        version: "1.0.0"
    }
}
isolated service mcp:AdvancedService /mcp on new mcp:Listener(9090) {

    isolated remote function onCallTool(mcp:CallToolParams params) 
            returns mcp:CallToolResult|mcp:ServerError {
        do {
            if params.name == "getCurrentWeather" {
                record { string city; } {city} = check params.arguments.cloneWithType();
                Weather weather = check getMockWeather(city);
                return {content: [{'type: "text", text: weather.toJsonString()}]};
            } 
            
            if params.name == "getWeatherForecast" {
                record { string location; int days; } {location, days} = check params.arguments.cloneWithType();
                WeatherForecast forecast = check getMockForecast(location, days);
                return {content: [{'type: "text", text: forecast.toJsonString()}]};
            }
        } on fail {
            return error("Invalid arguments");
        }
        
        return error("Tool not found: " + params.name);
    }

    isolated remote function onListTools() returns mcp:ListToolsResult|mcp:ServerError => {
        tools: [
            {
                name: "getCurrentWeather",
                description: "Get current weather conditions for a location",
                inputSchema: {
                    "type": "object",
                    "properties": {
                        "city": {
                            "type": "string",
                            "description": "City name or coordinates (e.g., 'London', '40.7128,-74.0060')"
                        }
                    },
                    "required": ["city"]
                }
            },
            {
                name: "getWeatherForecast",
                description: "Get a 5-day weather forecast for a location",
                inputSchema: {
                    "type": "object",
                    "properties": {
                        "city": {
                            "type": "string",
                            "description": "City name or coordinates (e.g., 'London', '40.7128,-74.0060')"
                        }
                    },
                    "required": ["city"]
                }
            }
        ]
    };
}

isolated function getMockWeather(string city) returns Weather|error {
    decimal temperature = 10.0 + 
        <decimal>(check random:createIntInRange(0, 25)) + 
            <decimal>(random:createDecimal()) * 1.0;
    int humidity = check random:createIntInRange(30, 90);
    int pressure = check random:createIntInRange(980, 1030);

    string[] conditions = ["Sunny", "Partly cloudy", "Cloudy", 
        "Light rain", "Heavy rain", "Snow", "Foggy"];
    string condition = conditions[check random:createIntInRange(0, conditions.length())];

    time:Utc currentTime = time:utcNow();
    string timestamp = time:utcToString(currentTime);

    return {
        location: city,
        temperature: (temperature * 10) / 10.0,
        humidity,
        pressure,
        condition,
        timestamp
    };
}

isolated function getMockForecast(string location, int days) returns WeatherForecast|error {
    ForecastItem[] forecastItems = [];
    time:Utc currentTime = time:utcNow();

    foreach int i in 0 ..< days {
        int high = check random:createIntInRange(15, 35);
        int low = check random:createIntInRange(5, high - 2);

        string[] conditions = ["Sunny", "Partly cloudy", "Cloudy", "Light rain",
             "Heavy rain", "Snow", "Thunderstorm"];
        string condition = conditions[check random:createIntInRange(0, conditions.length())];

        int precipitationChance = check random:createIntInRange(0, 100);
        int windSpeed = check random:createIntInRange(5, 25);

        // Calculate future date
        time:Utc futureTime = time:utcAddSeconds(currentTime, <decimal>(i * 24 * 60 * 60));
        time:Civil civilTime = time:utcToCivil(futureTime);
        string date = string `${civilTime.year}-${civilTime.month < 10 ? 
            "0" + civilTime.month.toString() : civilTime.month.toString()}-${civilTime.day < 10 ? 
            "0" + civilTime.day.toString() : civilTime.day.toString()}`;

        forecastItems.push({
            date,
            high,
            low,
            condition,
            precipitation_chance: precipitationChance,
            wind_speed: windSpeed
        });
    }

    return {
        location,
        forecast: forecastItems
    };
}

