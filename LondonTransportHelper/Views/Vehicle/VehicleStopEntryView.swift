import SwiftUI

/*
 Single entry for VehicleView, shows arrival time for the specific vehicle
 */
struct VehicleStopEntryView: View {
    // Use app's settings to decide how the arrival time is formatted
    @AppStorage(AppSetting.arrivalTimeFormat.rawValue) private var arrivalTimeFormat = AppSettingArrivalTimeFormat.minutes
    
    var prediction: VehiclePrediction
    
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
            let minutes = Int(prediction.timeToStation / 60)
            
            return minutes == 0 ? "Due" : "\(minutes) Minutes"
            
            /*
             Arrival time below 1 minute:
             Due
             Arrival Time above 1 minute:
             126 Seconds
             */
        case .seconds:
            let seconds = Int(prediction.timeToStation)
            
            return seconds == 0 ? "Due" : "\(seconds) Seconds"
            
            /*
             Arrival time below 1 minute:
             12:45
             Arrival Time above 1 minute:
             12:45
             */
        case .clock:
            let startDate = Date.now
            let arrivalDate = Calendar.current.date(byAdding: .second, value: Int(prediction.timeToStation), to: startDate)
            
            guard let arrivalDate else {
                return "Unknown Arrival Time"
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            
            return dateFormatter.string(from: arrivalDate)
        }
    }
    
    var platformName: String {
        let platform = prediction.platformName ?? ""
        
        return platform != "null" ? "(\(platform))" : ""
    }
    
    var body: some View {
        // Dont filter arrivals here
        NavigationLink(destination: ArrivalsView(stopIdOrNaptan: prediction.naptanId, arrivalsFilter: { _ in
            return true
        })) {
            HStack {
                Text(prediction.stationName)
                Text("\(platformName)")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
                Text(timeToArrival)
            }
        }
    }
}

struct VehicleStopEntryView_Previews: PreviewProvider {
    static var previews: some View {
        VehicleStopEntryView(prediction: VehiclePrediction(naptanId: "naptan", stationName: "Test Station", timeToStation: 421, towards: "Test Destination", lineName: "116", platformName: "A"))
        
        VehicleStopEntryView(prediction: VehiclePrediction(naptanId: "naptan", stationName: "Test Station", timeToStation: 11, towards: "Test Destination", lineName: "picadilly", platformName: "B"))
    }
}
