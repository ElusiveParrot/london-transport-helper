/*
 Represents a prediction from the TFL API.
 
 Shows when the bus will arrive at each of it's next stops.
 */
struct VehiclePrediction: Decodable, Hashable {
    /*
     Used for sorting.
     
     Compare based on arrival time.
     */
    static func < (lhs: VehiclePrediction, rhs: VehiclePrediction) -> Bool {
        return lhs.timeToStation < rhs.timeToStation
    }
    
    let naptanId:      String
    let stationName:   String
    let timeToStation: Int
    let towards:       String
    let lineName:      String
    
    /*
     Null on some bus stops but always present for rail based transportation modes.
     
     Some bus stops don't have the letter to diffrentiate them by which is why it can be null.
     */
    let platformName:  String?
}
