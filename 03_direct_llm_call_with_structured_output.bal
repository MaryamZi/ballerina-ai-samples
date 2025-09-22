import ballerina/ai;
import ballerina/io;

final ai:ModelProvider model = check ai:getDefaultModelProvider();

type Place record {|
    string city;
    string name;
    string highlight;
|};

function getPlacesToSee(string country, string interest, int number = 3) returns error? {
    // // The `generate` method
    // Place[]|error places1 = model->generate(`Tell me the top ${number} 
    //     places to visit in ${country} which are good for a tourist who has 
    //     an interest in ${interest} to visit and include a highlight 
    //     one-liner about that place`);
    // io:println(places1);

    // The `natural` expression
    Place[] places2 = check natural (model) {
        Tell me the top ${number} places to visit in ${country} which are 
        good for a tourist who has an interest in ${interest} to visit and 
        include a highlight one-liner about that place
    };
    io:println(places2);
};

public function main() returns error? {
    check getPlacesToSee("Sri Lanka", "surfing");
}
