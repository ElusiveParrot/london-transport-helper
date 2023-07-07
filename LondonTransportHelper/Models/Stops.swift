/*
 Represents a StopPoint from the TFL API.
 
 It is a group of bus/tube/train stops, for example: Most bus stops have inbound and outbound stops
 (for example: Bethany Way towards Hounslow (Stop F), Bethany Way towards Hatton Cross (Stop K))
 so they will be grouped together in a StopPoint, some stops have both bus and tube so they will be grouped as well.
 */
struct StopPointGroup: Hashable, Decodable {
    let id:    String
    let name:  String
    let lat:   Double
    let lon:   Double
    let modes: [TransportMode]
}

/*
 Represents a singular stop from inside a StopPointGroup
 */
struct StopPoint: Decodable, Hashable {
    /*
     Used to filter unwanted lines from the stop
     */
    mutating func filterUnwantedLines(filter: (Line) -> Bool) {
        self.lines.removeAll(where: filter)
    }
    
    let stopType:      String
    let naptanId:      String
    let commonName:    String
    
    // Some mode of transportations don't have those values (ex. overground) so they are nullable
    let stationNaptan: String? // Possible 'null' when using nearby stops
    let stopLetter:    String?
    let indicator:     String?
    
    let modes:         [TransportMode]
    var lines:         [Line]
    
    /*
     Many stop points have stop points within them in a "children" object.
     
     TFLHelper class has a function that scans it recursively.
     */
    let children:      [StopPoint]
    
    // Mainly used for infromations where the vehicles are going "towards"
    let additionalProperties: [AddtionalProperty]
}

/*
 Represents a single line (for example: bus 116 or Picaddily tube line)
 */
struct Line: Decodable, Hashable, Comparable {
    /*
     Used for sorting
     
     For UI consistency as API returns them in random order, the actual order doesnt matter, just need to be the same every time so sort by char count
     */
    static func < (lhs: Line, rhs: Line) -> Bool {
        lhs.name.count < rhs.name.count
    }
    
    let id:   String
    let name: String
}

/*
 Found in stops, contain additional data such as where the buses go
 
 You can see it on a bus stop it says above line numbers for ex: - 'Buses Towards Hounslow'
 */
struct AddtionalProperty: Decodable, Hashable {
    let key:   String
    let value: String
}
