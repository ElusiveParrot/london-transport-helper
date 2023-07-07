import SwiftUI

/*
 Single disruption inside disruption list
 */
struct DisruptionEntryView: View {
    // If it's nil then the serivce is fully operational
    var disruption: Disruption?
    
    var body: some View {
        if let disruption {
            Text(disruption.description)
        } else {
            Text("Service Fully Operational")
        }
    }
}

struct DisruptionEntryView_Previews: PreviewProvider {
    static var previews: some View {
        DisruptionEntryView(disruption: Disruption(description: "Hello, World", created: "2023-03-22T08:15:00Z", lastUpdate: "2023-03-22T08:15:00Z"))
        
        DisruptionEntryView(disruption: nil)
    }
}
