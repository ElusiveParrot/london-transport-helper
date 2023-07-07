import SwiftUI

/*
 View for each entry in arrivals view
 */
struct ArrivalEntryView: View {
    // Use app's settings to decide how the arrival time is formatted
    @AppStorage(AppSetting.arrivalTimeFormat.rawValue) private var arrivalTimeFormat = AppSettingArrivalTimeFormat.minutes
    
    var arrival: Arrival
    
    // Format arrival time based on app's settings
    var timeToArrival: String {
        switch (arrivalTimeFormat) {
            /*
             Arrival time below 1 minute:
                    Due
             Arrival Time above 1 minute:
                    12 Minutes
             */
        case .minutes:
            let minutes = Int(arrival.timeToStation / 60)
            
            return minutes == 0 ? "Due" : "\(minutes) Minutes"
          
            /*
             Arrival time below 1 minute:
                    Due
             Arrival Time above 1 minute:
                    126 Seconds
             */
        case .seconds:
            let seconds = Int(arrival.timeToStation)
            
            return seconds == 0 ? "Due" : "\(seconds) Seconds"
            
            /*
             Arrival time below 1 minute:
                    12:45
             Arrival Time above 1 minute:
                    12:45
             */
        case .clock:
            let startDate = Date.now
            let arrivalDate = Calendar.current.date(byAdding: .second, value: Int(arrival.timeToStation), to: startDate)
            
            guard let arrivalDate else {
                return "Unknown Arrival Time"
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            
            return dateFormatter.string(from: arrivalDate)
        }
    }
    
    // Show empty string if there is no vehicle id
    var vehicleIdText: String {
        if (!arrival.vehicleId.isEmpty) {
            return "(\(arrival.vehicleId))"
        } else {
            return ""
        }
    }
    
    var body: some View {
        NavigationLink(destination: VehicleView(vechicleId: arrival.vehicleId)) {
            HStack {
                Text(arrival.destinationName ?? "Unknown Destination")
                Text(vehicleIdText)
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
                Text(timeToArrival)
            }
        }
    }
}

struct ArrivalEntryView_Previews: PreviewProvider {
    static var previews: some View {
        ArrivalEntryView(arrival: Arrival(vehicleId: "TEST", lineName: "116", lineId: "116", modeName: .bus, timeToStation: 512, destinationName: "test destination"))
        
        ArrivalEntryView(arrival: Arrival(vehicleId: "TEST", lineName: "116", lineId: "116", modeName: .bus, timeToStation: 12, destinationName: "test destination"))
    }
}
