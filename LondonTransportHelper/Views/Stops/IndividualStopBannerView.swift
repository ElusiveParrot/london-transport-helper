import SwiftUI

/*
 Entry for an indivdual bus stop in stop group view
 */
struct IndividualStopBannerView: View {
    var stop: StopPoint
    
    var transportMode: TransportMode
    
    var direction: String {
        if (stop.lines.isEmpty || stop.modes[0] != .bus) {
            return ""
        }
        
        for property in stop.additionalProperties {
            if (property.key.lowercased() == "towards" && property.value != "") {
                return "Towards " + property.value
            }
        }
        
        return ""
    }
    
    var stopMode: String {
        switch (stop.modes.count) {
        case 0:
            return "unknown" // Never happened in my testing but it's here just to prevent a crash just in case
            
        case 1:
            return stop.modes[0].rawValue
            
        default:
            // More than 1 then decide based on line
            let id = stop.lines[0].id
            switch (id) {
                // Transform line id into transport mode string for some transport types
            case "london-overground":
                return "overground"
                
            case "elizabeth":
                return "elizabeth-line"
                
            case "dlr":
                return "dlr"
                
            default:
                return id
            }
        }
    }
    
    var stopName: String {
        if (TransportMode(rawValue: stopMode) == .bus) {
            return stop.indicator ?? "Stop"
        } else {
            let suffix: String
            switch (TransportMode(rawValue: stopMode)) {
            case .overground:
                suffix = "Overground Station"
                
            case .elizabethLine:
                suffix = "Elizabeth Line Station"
                
            default:
                suffix = ""
            }
            
            return stop.commonName + " \(suffix)"
        }
    }
    
    var body: some View {
        NavigationLink(destination: ArrivalsView(stopIdOrNaptan: stop.naptanId, arrivalsFilter: TFLHelper.filterArrivalsBasedOnTransportationMode(mode: transportMode))) {
            HStack {
                VStack {
                    HStack {
                        Image("tfl-\(stopMode)")
                            .resizable()
                            .frame(width: 25, height: 20)
                            .padding(.top)
                        Text(stopName)
                        Text("\(direction)")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .padding()
                        Spacer()
                    }
                    ScrollView(.horizontal) {
                        LazyHGrid(rows: [GridItem(.fixed(2))], spacing: 7) {
                            ForEach(stop.lines.sorted(by: <), id: \.self) { line in
                                LineRectangleView(color: TFLHelper.getColourNameForLine(name: line.name), name: line.name)
                                    .fixedSize()
                            }
                        }
                    }
                    Spacer()
                }
            }
        }
    }
}

struct IndividualStopBannerView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            IndividualStopBannerView(stop: StopPoint(stopType: "", naptanId: "", commonName: "Bus Stop", stationNaptan: "123", stopLetter: "X", indicator: "Stop X", modes: [.bus], lines: [Line(id: "100", name: "100"), Line(id: "101", name: "101"), Line(id: "102", name: "102")], children: [], additionalProperties: []), transportMode: .bus)
                .previewLayout(PreviewLayout.sizeThatFits)
                .padding()
            
            IndividualStopBannerView(stop: StopPoint(stopType: "", naptanId: "", commonName: "Bus Stop", stationNaptan: "123", stopLetter: "X", indicator: "Stop X", modes: [.tube], lines: [Line(id: "100", name: "100"), Line(id: "101", name: "101"), Line(id: "102", name: "102")], children: [], additionalProperties: []), transportMode: .tube)
                .previewLayout(PreviewLayout.sizeThatFits)
                .padding()
        }
    }
}
