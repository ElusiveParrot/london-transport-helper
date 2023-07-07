import SwiftUI

/*
 Helper class to deal with data from TFL API
 */
class TFLHelper {
    // User can decide if stops without any lines should be filtered (ON by default)
    @AppStorage(AppSetting.filterStopsWithoutLines.rawValue) private static var filterEmptyStops = true
    
    // A list of tube lines along with their API's IDs
    static var tubeLines: [(name: String, id: String)] {
        return [
            (name: "District",           id: "district"),
            (name: "Waterloo & City",    id: "waterloo-city"),
            (name: "Northern",           id: "northern"),
            (name: "Jubilee",            id: "jubilee"),
            (name: "Bakerloo",           id: "bakerloo"),
            (name: "Central",            id: "central"),
            (name: "Circle",             id: "circle"),
            (name: "Metropolitan",       id: "metropolitan"),
            (name: "Piccadilly",         id: "piccadilly"),
            (name: "Victoria",           id: "victoria"),
            (name: "Hammersmith & City", id: "hammersmith-city")
        ]
    }
    
    /*
     Arrival view uses filter to filter out unwanted arrivals, this function can be passed as a default filter.
     
     The arrivals are filtered by their mode of transportation.
     */
    static func filterArrivalsBasedOnTransportationMode(mode: TransportMode) -> (Arrival) -> Bool {
        return { arrival in
            return arrival.modeName == mode
        }
    }
    
    /*
     Convert time string in the format of TFL api to desired one
     */
    static func convertTflApiTimeString(time: String, format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        if let date = dateFormatter.date(from: time) {
            dateFormatter.dateFormat = format
            let timeString = dateFormatter.string(from: date)
            
            return timeString
        } else {
            // The API supplied the date and time in a different format, never seen this happen but it's here just in case.
            return "Unknown"
        }
    }
    
    /*
     Returns a color that is a signature color of the line (always red for buses)
     */
    static func getColourNameForLine(name: String) -> Color {
        switch (name.lowercased()) {
        case "district", "waterloo & city":
            return .green
            
        case "northern", "jubilee":
            return .gray // Gray instead of black for Northern to make sure it's visible in dark mode
            
        case "london overground":
            return .orange
            
        case "bakerloo":
            return .brown
            
        case "central":
            return .red
            
        case "circle":
            return .yellow
            
        case "metropolitan":
            return .pink
            
        case "piccadilly":
            return .indigo
            
        case "victoria":
            return .cyan
            
        case "elizabeth line":
            return .purple
            
        case "hammersmith & city":
            return .pink
            
        case "dlr":
            return .teal
            
        default:
            return .red // Bus
        }
    }
    
    /*
     Parses response from /StopPoint/ID to find list of bus, tube etc stops that are inside the "children" object
     */
    static func scanStopGroupChildrenForStops(data: [StopPoint], group: StopPointGroup, stationModes: [TransportMode], integratedLines: [Line]) -> StopList {
        var stopList: StopList = StopList(bus: [], dlr: [], tube: [], overground: [], elizabethLine: [], nationalRail: false)
        
        for stop in data {
            if (filterEmptyStops && stop.lines.isEmpty) {
                continue
            }
            
            switch (stop.stopType) {
                // Regular bus stop
            case "NaptanPublicBusCoachTram", "NaptanPrivateBusCoachTram":
                stopList.bus.append(stop)
                
                // Bus stop cluster
            case "NaptanOnstreetBusCoachStopCluster", "NaptanBusCoachStation", "NaptanOnstreetBusCoachStopPair":
                stopList.bus.append(contentsOf: scanStopsForChildrenStops(stop: stop))
                
                // Metro station
            case "NaptanMetroStation":
                var tubeAdded = false // Prevents duplicate tube stations
                
                for line in stop.lines {
                    if (line.name.lowercased() == "dlr") {
                        stopList.dlr.append(stop)
                    }
                    else {
                        if (!tubeAdded && line.name.count > 4) {
                            tubeAdded = true
                            stopList.tube.append(stop)
                        }
                    }
                }
                // Also search for metro station's child bus stops
                stopList.bus.append(contentsOf: scanStopsForChildrenStops(stop: stop))
                
            case "NaptanRailStation":
                for line in stop.lines {
                    // Check which line the rail stations serves
                    if (line.name.lowercased() == "london overground") {
                        // Filter lines other than london overground
                        var newStop = stop
                        newStop.filterUnwantedLines() { line in
                            return line.name.lowercased() != "london overground"
                        }
                        stopList.overground.append(newStop)
                    }
                    if (line.name.lowercased() == "elizabeth line") {
                        // Filter lines other than elizabeth line
                        var newStop = stop
                        newStop.filterUnwantedLines() { line in
                            return line.name.lowercased() != "elizabeth line"
                        }
                        stopList.elizabethLine.append(newStop)
                    }
                    if (line.name.lowercased() == "dlr") {
                        // Filter lines other than dlr
                        var newStop = stop
                        newStop.filterUnwantedLines() { line in
                            return line.name.lowercased() != "dlr"
                        }
                        stopList.dlr.append(newStop)
                    }
                }
                // Also search for rail station's child bus stops
                stopList.bus.append(contentsOf: scanStopsForChildrenStops(stop: stop))
                
            default:
                // Something else (which means it does not have any stops)
                continue
            }
        }
        
        // Integrated stops
        
        // Filter integrated lines:
        var integratedTubeLines: [Line] = []
        for line in integratedLines {
            let lineColour = getColourNameForLine(name: line.name)
            // If line is not a color of a bus and DLR,overground,elizabeth line then it's a tube line
            if (line.name.count > 4 && lineColour != getColourNameForLine(name: "dlr") && lineColour != getColourNameForLine(name: "london overground") && lineColour != getColourNameForLine(name: "elizabeth line")) {
                integratedTubeLines.append(line)
            }
        }
        
        /*
         Add 'dummy' (they are real but they are inside the StopGroup and not included in the search) stations for integrated stations
         
         The stop group has integrated stations if:
         - It contains the mode transportation X
         BUT:
         - There is no child object with mode transportation X
         */
        if (stopList.tube.isEmpty && stationModes.contains(.tube)) {
            stopList.tube.append(StopPoint(stopType: "", naptanId: group.id, commonName: group.name, stationNaptan: group.id, stopLetter: nil, indicator: nil, modes: [.tube], lines: integratedTubeLines, children: [], additionalProperties: []))
        }
        if (stopList.overground.isEmpty && stationModes.contains(.overground)) {
            stopList.overground.append(StopPoint(stopType: "", naptanId: group.id, commonName: group.name, stationNaptan: group.id, stopLetter: nil, indicator: nil, modes: [.overground], lines: [Line(id: TransportMode.overground.rawValue, name: "London Overground")], children: [], additionalProperties: []))
        }
        if (stopList.elizabethLine.isEmpty && stationModes.contains(.elizabethLine)) {
            stopList.elizabethLine.append(StopPoint(stopType: "", naptanId: group.id, commonName: group.name, stationNaptan: group.id, stopLetter: nil, indicator: nil, modes: [.elizabethLine], lines: [Line(id: TransportMode.elizabethLine.rawValue, name: "Elizabeth Line")], children: [], additionalProperties: []))
        }
        if (stopList.elizabethLine.isEmpty && stationModes.contains(.dlr)) {
            stopList.dlr.append(StopPoint(stopType: "", naptanId: group.id, commonName: group.name, stationNaptan: group.id, stopLetter: nil, indicator: nil, modes: [.dlr], lines: [Line(id: TransportMode.dlr.rawValue, name: "Dlr")], children: [], additionalProperties: []))
        }
        
        // TODO: Remove national rail entirely since TFL removed it from their own API (thanks TFL)
        if (!stopList.nationalRail && stationModes.contains(.nationalRail)) {
            stopList.nationalRail = true
        }
        
        return stopList
    }
    
    /*
     Scans children of a StopPoint for more stops recursively
     */
    private static func scanStopsForChildrenStops(stop: StopPoint) -> [StopPoint] {
        var stopList: [StopPoint] = []
        
        for child in stop.children {
            switch (child.stopType) {
            case "NaptanPublicBusCoachTram", "NaptanPrivateBusCoachTram":
                // Filtering setting
                if (child.lines.isEmpty && filterEmptyStops) {
                    continue
                }
                
                stopList.append(child)
                
            default:
                stopList.append(contentsOf: scanStopsForChildrenStops(stop: child))
            }
        }
        
        return stopList
    }
}
