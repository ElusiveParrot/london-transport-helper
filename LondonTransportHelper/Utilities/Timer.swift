import SwiftUI

/*
 Used for automatic repeatable actions within the UI
 */
class TimerHelper: ObservableObject {
    @Published var counter = 0
    
    // Upon timer reaching this value 'actionOnLimit' will be called
    private var limit: Int
    
    private var actionOnLimit: () -> ()
    
    // Actual iOS timer, my class is a 'wrapper' around it
    private var internalTimer: Timer?
    
    init(limit: Int, actionOnLimit: @escaping () -> ()) {
        self.actionOnLimit = actionOnLimit
        self.limit         = limit
        
        internalTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.counter += 1
            
            if (self.counter == self.limit) {
                self.actionOnLimit()
                
                self.reset()
            }
        }
    }
    
    func changeOnLimitAction(actionOnLimit: @escaping () -> ()) {
        self.actionOnLimit = actionOnLimit
    }
    
    func reset() {
        counter = 0
    }
}
