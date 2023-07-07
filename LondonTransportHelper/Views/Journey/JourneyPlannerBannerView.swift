import SwiftUI

/*
 Banner shown when searching for a journey
 */
struct JourneyPlannerBannerView: View {
    var journey: Journey
    
    // Checks whether any leg of a journey has any disruptions
    var isDisrupted: Bool {
        for leg in journey.legs {
            if (leg.isDisrupted) {
                return true
            }
        }
        
        return false
    }
    
    /*
     Convert departure time and arrival time to more presentable format (and remove the date part as it's not useful. There are no multiple day journeys and if the journey is made light at night and continutes the next day then it is implied)
     */
    var departureTime: String {
        return TFLHelper.convertTflApiTimeString(time: journey.startDateTime, format: "HH:mm")
    }
    
    var arrivalTime: String {
        return TFLHelper.convertTflApiTimeString(time: journey.arrivalDateTime, format: "HH:mm")
    }
    
    var body: some View {
        NavigationLink(destination: JourneyView(journey: journey)) {
            HStack {
                VStack {
                    HStack {
                        Text("\(departureTime) - \(arrivalTime)")
                        Spacer()
                        Text("\(journey.duration) Minutes")
                            .bold()
                    }
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                    
                    // Sometimes the fare is not in the API
                    if let fare = journey.fare {
                        let fareCost = Double(fare.totalCost) / 100.0
                        
                        HStack {
                            Text("Predicted Cost:")
                            Spacer()
                            Text("£\(fareCost, specifier: "%.2f")")
                                .bold()
                        }
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                    }
                    
                    
                    // Show a warning in case there might be some disruptions
                    if (isDisrupted) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                            Text("This Route Might Be Disrupted")
                        }
                        .font(.subheadline)
                        .foregroundColor(.red)
                    }
                }
                Image(systemName: "chevron.right")
            }
        }
    }
}

struct JourneyPlannerBannerView_Previews: PreviewProvider {
    static var previews: some View {
        JourneyPlannerBannerView(journey: Journey(startDateTime: "2023-04-01T12:41:00", arrivalDateTime: "2023-04-01T12:58:00", duration: 17, fare: Fare(totalCost: 175), legs: [JourneyStep(departureTime: "2023-04-01T12:41:00", arrivalTime: "2023-04-01T12:46:00", duration: 5, instruction: JourneyStepInstruction(summary: "Test Summary", detailed: "Test Detailed"), mode: JourneyStepMode(id: "bus"), departurePoint: JourneyPoint(lat: 51.453288, lon: -0.43247), arrivalPoint: JourneyPoint(lat: 51.453288, lon: -0.43247), fare: Fare(totalCost: 521), isDisrupted: true)]))
    }
}
