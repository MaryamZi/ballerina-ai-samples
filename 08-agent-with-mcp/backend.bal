// From https://github.com/AzeemMuzammil/module-ballerina-mcp/tree/fb-documentation/examples/servers/mcp-weather-server

import ballerina/log;
import ballerina/mcp;
import ballerina/random;
import ballerina/time;

listener mcp:Listener mcpListener = check new (9090);

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
        name: "Weather MCP server",
        version: "1.0"
    }
}
isolated service mcp:Service /mcp on mcpListener {
    @mcp:Tool {
        description: string `
            **Description**: Get current weather conditions for a location
            **Parameters**:
            - location (string, required): City name or coordinates (e.g., "London", "40.7128,-74.0060")
            `
    }
    remote function getCurrentWeather(string city) returns Weather|error {
        log:printInfo(string `Getting current weather for: ${city}`);

        // Generate random weather data
        decimal temperature = 10.0 + <decimal>(check random:createIntInRange(0, 25)) + <decimal>(random:createDecimal()) * 1.0;
        int humidity = check random:createIntInRange(30, 90);
        int pressure = check random:createIntInRange(980, 1030);

        string[] conditions = ["Sunny", "Partly cloudy", "Cloudy", "Light rain", "Heavy rain", "Snow", "Foggy"];
        string condition = conditions[check random:createIntInRange(0, conditions.length())];

        time:Utc currentTime = time:utcNow();
        string timestamp = time:utcToString(currentTime);

        Weather weather = {
            "location": city,
            "temperature": <decimal>(<int>(temperature * 10)) / 10.0,
            "humidity": humidity,
            "pressure": pressure,
            "condition": condition,
            "timestamp": timestamp
        };

        log:printInfo(string `Weather data retrieved for ${city}: ${weather.condition}, ${weather.temperature}°C`);
        return weather;
    };

    # Get weather forecast for upcoming days
    #
    # + location - City name or coordinates (e.g., "London", "40.7128,-74.0060") 
    # + days - Number of days to forecast (1-7)
    # + return - Weather forecast for the specified location and days
    remote function getWeatherForecast(string location, int days) returns WeatherForecast|error {
        log:printInfo(string `Getting ${days}-day weather forecast for: ${location}`);

        // Generate forecast items with random data
        ForecastItem[] forecastItems = [];
        time:Utc currentTime = time:utcNow();

        foreach int i in 0 ..< days {
            // Generate random weather data for each day
            int high = check random:createIntInRange(15, 35);
            int low = check random:createIntInRange(5, high - 2);

            string[] conditions = ["Sunny", "Partly cloudy", "Cloudy", "Light rain", "Heavy rain", "Snow", "Thunderstorm"];
            string condition = conditions[check random:createIntInRange(0, conditions.length())];

            int precipitationChance = check random:createIntInRange(0, 100);
            int windSpeed = check random:createIntInRange(5, 25);

            // Calculate future date
            time:Utc futureTime = time:utcAddSeconds(currentTime, <decimal>(i * 24 * 60 * 60));
            time:Civil civilTime = time:utcToCivil(futureTime);
            string date = string `${civilTime.year}-${civilTime.month < 10 ? "0" + civilTime.month.toString() : civilTime.month.toString()}-${civilTime.day < 10 ? "0" + civilTime.day.toString() : civilTime.day.toString()}`;

            ForecastItem item = {
                "date": date,
                "high": high,
                "low": low,
                "condition": condition,
                "precipitation_chance": precipitationChance,
                "wind_speed": windSpeed
            };
            forecastItems.push(item);
        }

        WeatherForecast forecast = {
            "location": location,
            "forecast": forecastItems
        };

        log:printInfo(string `Forecast generated for ${location}: ${days} days with random data`);
        return forecast;
    }
}
