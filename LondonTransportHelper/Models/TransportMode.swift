/*
 Each Stop has at least one mode of transportation that's available for it
 */
enum TransportMode: String, Decodable, Comparable {
    /*
     For sorting based on number of characters
     
     The actual order doesn't really matter, it just needs to be consistent as in the API the modes of transporation may appear in any order
     */
    static func < (lhs: TransportMode, rhs: TransportMode) -> Bool {
        return lhs.rawValue.count > rhs.rawValue.count
    }
    
    var isSupported: Bool {
        switch (self) {
        case .taxi, .coach, .cycle, .walking, .replacementBus, .interchangeS, .interchangeKS:
            return false
            
        default:
            return true
        }
    }
    
    // Below string values are how they are represented in the TFL API
    case dlr            = "dlr"
    case bus            = "bus"
    case tube           = "tube"
    case tram           = "tram"
    case cableCar       = "cable-car"
    case cableBus       = "river-bus"
    case overground     = "overground"
    case elizabethLine  = "elizabeth-line"
    
    // There show up as an icons but they are technically not supported
    case plane          = "plane"
    case cycleHire      = "cycle-hire"
    case nationalRail   = "national-rail"
    case abroadTrain    = "international-rail"
    
    // These are only added so that the enum matches api 1:1 but they will NOT be implemented
    case taxi           = "taxi"
    case cycle          = "cycle"
    case coach          = "coach"
    case walking        = "walking"
    case interchangeS   = "interchange-secure"
    case interchangeKS  = "interchange-keep-sitting"
    
    // While this may look like it's useful to implement it's actually not used by the API, the normal 'bus' is used instead
    case replacementBus = "replacement-bus"
}
