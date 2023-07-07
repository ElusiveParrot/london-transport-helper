import SwiftUI

/*
 Result of the stop group search, shown in the list
 */
struct StopGroupBannerView: View {
    var stop: StopPointGroup
    
    private func getIconName(mode: TransportMode) -> String? {
        if (mode.isSupported) {
            return "tfl-\(mode.rawValue)"
        } else {
            return nil
        }
    }
    
    var body: some View {
        NavigationLink(destination: StopGroupStopsView(stop: stop)) {
            HStack {
                VStack {
                    HStack {
                        Text(stop.name)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    
                    HStack {
                        // Show icon for each transport mode that the stop has
                        ForEach(stop.modes.sorted(by: >), id: \.self) { mode in
                            if let iconName = getIconName(mode: mode) {
                                Image(iconName)
                                    .resizable()
                                    .frame(width: 25, height: 20)
                            }
                        }
                        Spacer()
                    }
                }
            }
        }
    }
}

struct StopGroupBannerView_Previews: PreviewProvider {
    static var previews: some View {
        StopGroupBannerView(stop: StopPointGroup(id: "TESTID", name: "This is a very long bus stop name", lat: 1.0, lon: 2.0, modes: [.bus, .elizabethLine, .nationalRail, .overground, .tube]))
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
    }
}
