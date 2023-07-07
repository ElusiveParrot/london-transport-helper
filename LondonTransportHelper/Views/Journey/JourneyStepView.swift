import SwiftUI

/*
 Shows information about individual steps of a journey
 */
struct JourneyStepView: View {
    var step: JourneyStep
    
    /*
     Convert departure time and arrival time to more presentable format (and remove the date part as it's not useful. There are no multiple day journeys and if the journey is made light at night and continutes the next day then it is implied)
     */
    var departureTime: String {
        return TFLHelper.convertTflApiTimeString(time: step.departureTime, format: "HH:mm")
    }
    
    var arrivalTime: String {
        return TFLHelper.convertTflApiTimeString(time: step.arrivalTime, format: "HH:mm")
    }
    
    var iconName: String {
        switch (step.mode.id) {
            // Transform some strings for edge cases
        case "london-overground":
            return "overground"
            
        case "elizabeth":
            return "elizabeth-line"
            
        case "international-rail":
            return "national-rail"
            
        default:
            return step.mode.id
        }
    }
    
    var body: some View {
        HStack {
            VStack {
                HStack {
                    Image("tfl-\(iconName)")
                        .resizable()
                        .frame(width: 25, height: 20)
                        .padding(.top)
                    Text(step.instruction.summary)
                    Spacer()
                }
                VStack {
                    HStack {
                        Text("Departure:")
                            .font(.subheadline)
                        Spacer()
                        Text(departureTime)
                            .font(.system(.subheadline, design: .monospaced)) // Use monospaced font so the times allign
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Text("Arrival:")
                            .font(.subheadline)
                        Spacer()
                        Text(arrivalTime)
                            .font(.system(.subheadline, design: .monospaced)) // Use monospaced font so the times allign
                    }
                    .padding(.horizontal)
                    
                    if let fare = step.fare {
                        let fareCost = Double(fare.totalCost) / 100.0
                        
                        HStack {
                            Text("Fare:")
                                .font(.subheadline)
                            Spacer()
                            Text("£\(fareCost, specifier: "%.2f")")
                                .font(.system(.subheadline, design: .monospaced)) // Use monospaced font so the price allign with the time
                        }
                        .padding(.horizontal)
                    }
                    
                    // Show a warning in case there might be some disruptions
                    if (step.isDisrupted) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                            Text("This Route Might Be Disrupted")
                        }
                        .font(.subheadline)
                        .foregroundColor(.red)
                    }
                }
                Spacer()
            }
        }
    }
}

struct JourneyStepView_Previews: PreviewProvider {
    static var previews: some View {
        JourneyStepView(step: JourneyStep(departureTime: "2023-04-01T12:41:00", arrivalTime: "2023-04-01T12:46:00", duration: 5, instruction: JourneyStepInstruction(summary: "116 Bus To Hounslow Bus Station", detailed: "Test Detailed"), mode: JourneyStepMode(id: "bus"), departurePoint: JourneyPoint(lat: 51.453288, lon: -0.43247), arrivalPoint: JourneyPoint(lat: 51.453288, lon: -0.43247), fare: Fare(totalCost: 521), isDisrupted: true))
    }
}
