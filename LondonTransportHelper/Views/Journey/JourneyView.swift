import SwiftUI

/*
 Shows detailed information about a singular journey
 */
struct JourneyView: View {
    var journey: Journey
    
    var body: some View {
        VStack {
            /*
             Center the map on the arrival's location.
             
             Default value is provided just in case, there was no occurence of a journey without "legs" in my testing but making the map wrong is assumed to be better than a crash as the information below would still be correct)
             */
            MapView(lat: journey.legs.last?.arrivalPoint.lat ?? 0.0, lon: journey.legs.last?.arrivalPoint.lon ?? 0.0)
                .frame(height: 200)
            VStack {
                if let fare = journey.fare {
                    let fareCost = Double(fare.totalCost) / 100.0
                    HStack {
                        Text("Expected Fare: ")
                            .padding()
                        Text("Based on PAYG Adult Ticket")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .padding()
                        Spacer()
                        Text("£\(fareCost, specifier: "%.2f")")
                            .bold()
                    }
                    .padding(.horizontal)
                }
                
                Divider()
                
                HStack {
                    Text("Journey Duration: ")
                        .padding()
                    Spacer()
                    Text("\(journey.duration) Minutes")
                        .bold()
                }
                .padding(.horizontal)
            }
            List {
                // Show each journey's "leg" in a list
                ForEach(journey.legs, id: \.self) { step in
                    JourneyStepView(step: step)
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("Journey")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct JourneyView_Previews: PreviewProvider {
    static var previews: some View {
        JourneyView(journey: Journey(startDateTime: "2023-04-01T12:41:00", arrivalDateTime: "2023-04-01T12:58:00", duration: 17, fare: Fare(totalCost: 275), legs: [JourneyStep(departureTime: "2023-04-01T12:41:00", arrivalTime: "2023-04-01T12:46:00", duration: 5, instruction: JourneyStepInstruction(summary: "Test Summary", detailed: "Test Detailed"), mode: JourneyStepMode(id: "bus"), departurePoint: JourneyPoint(lat: 51.453288, lon: -0.43247), arrivalPoint: JourneyPoint(lat: 51.453288, lon: -0.43247), fare: Fare(totalCost: 521), isDisrupted: true)]))
    }
}
