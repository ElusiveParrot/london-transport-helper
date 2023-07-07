/*
 Represents single arrival for ANY mode of transportation from the TFL API
 */
struct Arrival: Decodable, Hashable {
    /*
     Used for sorting.
     
     Compare based on arrival time.
     */
    static func < (lhs: Arrival, rhs: Arrival) -> Bool {
        return lhs.timeToStation < rhs.timeToStation
    }
    
    let vehicleId:       String
    let lineName:        String
    let lineId:          String
    let modeName:        TransportMode
    let timeToStation:   Int  // In seconds
    
    // Possible bug in TFL API, but better to have it as nullable just in case
    let destinationName: String?
}
