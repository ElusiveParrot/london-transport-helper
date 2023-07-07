import CoreData

/*
 Class for CoreData to store favourite stops
 */
@objc(FavouriteStop)
class FavouriteStop: NSManagedObject {
    /*
     Simple function for fetch requests for CoreData
     */
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavouriteStop> {
        return NSFetchRequest<FavouriteStop>(entityName: "FavouriteStop")
    }
    
    /*
     1:1 StopPointGroup (/models/Stops.swift)
     */
    @NSManaged var id:    String
    @NSManaged var name:  String
    @NSManaged var lat:   Double
    @NSManaged var lon:   Double
    @NSManaged var modes: [String]
    
    // Used for sorting, not part of the actual stop group
    @NSManaged var dateAdded: Date
    
    // Can't store actual stop group so construct and deconstruct it as variable
    var stopGroup : StopPointGroup {
        get {
            // Construct from individual members
            StopPointGroup(id: id, name: name, lat: lat, lon: lon, modes: modes.map { val in
                TransportMode(rawValue: val)!
            })
        }
        set {
            // Deconstruct to individual members
            self.id    = newValue.id
            self.name  = newValue.name
            self.lat   = newValue.lat
            self.lon   = newValue.lon
            self.modes = newValue.modes.map { val in
                val.rawValue
            }
        }
    }
}
