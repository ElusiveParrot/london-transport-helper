import CoreData

struct PersistenceController {
    // Singleton for the application to use
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "UserStorage")
        
        container.loadPersistentStores { description, error in
            if let error {
                print("Unable to load persistent storage: \(error.localizedDescription)")
            }
        }
    }
    
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch (let error) {
                print("Unable to save persistent storage changes: \(error.localizedDescription)")
            }
        }
    }
}
