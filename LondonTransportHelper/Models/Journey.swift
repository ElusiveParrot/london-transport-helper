/*
 Represents a single 'journey' from TFL API.
 
 Each journey has 'legs' (represented as JoruneyStep) which contain individual instructions and a fare.
 */
struct Journey: Hashable, Decodable {
    let startDateTime:   String
    let arrivalDateTime: String
    let duration:        Int
    let fare:            Fare?
    let legs:            [JourneyStep]
}

/*
 Represents a disambiguation hint when the API cannot use the user's origin/destination.
 */
struct JourneyLocationDisambiguation: Decodable {
    /*
     List       - Disambiguation needed, list provided.
     Empty      - No disambiguation needed (usually for unused 'via' parameter)
     Identified - No disambiguation needed.
     */
    let matchStatus:           String
    
    // List of possible disambiguation.
    let disambiguationOptions: [JourneyLocationDisambiguationOption]?
}

/*
 Represents a single disambiguation option.
 */
struct JourneyLocationDisambiguationOption: Decodable {
    let parameterValue: String                             // Paramater value that can be used in a query.
    let place:          JourneyLocationDisambiguationPlace // Place that this disambiguation represents.
}

/*
 Represents a place of a disambiguation
 */
struct JourneyLocationDisambiguationPlace: Decodable {
    let commonName: String // Common name of the place, can be presented to the user as an option.
}

/*
 Represents a single step in a journey, called a 'leg' in TFL's API.
 */
struct JourneyStep: Hashable, Decodable {
    let departureTime:  String
    let arrivalTime:    String
    let duration:       Int // In minutes
    let instruction:    JourneyStepInstruction
    let mode:           JourneyStepMode
    let departurePoint: JourneyPoint
    let arrivalPoint:   JourneyPoint
    let fare:           Fare?
    let isDisrupted:    Bool
}

/*
 Represents an instruction for a journey step.
 */
struct JourneyStepInstruction: Hashable, Decodable {
    // These are usually almost the same, a bit counterintuitive but summary usually provides a more useful infromation.
    let summary:  String
    let detailed: String
}

/*
 Represents the mode of transportation used in that journey step.
 */
struct JourneyStepMode: Hashable, Decodable {
    let id: String
}

/*
 Represents a 'StopPoint' in the journey, not to be confused with StopPoint from the TFL API (example of TFL's horrible api design).
 
 Only location is useful as it's only used to show the finishing location of the journey (by looking at last JourneyPoint's arrival location).
 */
struct JourneyPoint: Hashable, Decodable {
    let lat: Double
    let lon: Double
}

/*
 Represents the cost of the journey.
 */
struct Fare: Hashable, Decodable {
    let totalCost: Int // This is adult PAYG fare. Divided by 100 to get pounds value.
}
