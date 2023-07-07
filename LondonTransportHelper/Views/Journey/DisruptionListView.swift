import SwiftUI

/*
 Shows a list of disruptions
 */
struct DisruptionListView: View {
    var disruptions: [Disruption]
    
    var body: some View {
        // Simple VStack with all the disruptions as text
        if (!disruptions.isEmpty) {
            ForEach(disruptions, id: \.self) { disruption in
                DisruptionEntryView(disruption: disruption)
            }
        } else {
            // No disruptions = service fully operational
            DisruptionEntryView(disruption: nil)
        }
    }
}

struct DisruptionListView_Previews: PreviewProvider {
    static var previews: some View {
        DisruptionListView(disruptions: [Disruption(description: "Hello, World", created: "2023-03-22T08:15:00Z", lastUpdate: "2023-03-22T08:15:00Z")])
        
        DisruptionListView(disruptions: [])
    }
}
