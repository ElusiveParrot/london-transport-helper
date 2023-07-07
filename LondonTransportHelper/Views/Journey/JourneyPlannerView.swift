import SwiftUI

/*
 Used to search for a plan of a journey between two locations
 */
struct JourneyPlannerView: View {
    @ObservedObject var viewModel = JourneyPlannerViewModel()
    
    @State var originText:      String = ""
    @State var destinationText: String = ""
    
    /*
     The date can be treated as either a date of arrival or departure.
     
     It is decided based on the 'dataType' which is changed by the Picker in the view
     */
    @State var dateType: String = "Departing"
    @State var date:     Date   = Date.now
    
    /*
     Update view model based on the entered data
     */
    private func getJourneys() {
        viewModel.getJourneyPlan(from: originText, to: destinationText, date: date, dateType: dateType)
    }
    
    var body: some View {
        VStack {
            VStack {
                // Origin Text field
                HStack {
                    CustomTextFieldView(text: $originText, imageName: "airplane.departure", backgroundText: "Origin") {
                        getJourneys()
                    } onChangeAction: {
                        viewModel.resetDisambiguations()
                    }
                    
                    Button {
                        originText = viewModel.getUserLocationString()
                    } label: {
                        Label("", systemImage: "location")
                    }
                }
                .padding()
                
                Divider()
                
                // Destination Text field
                HStack {
                    CustomTextFieldView(text: $destinationText, imageName: "airplane.arrival", backgroundText: "Destination") {
                        getJourneys()
                    } onChangeAction: {
                        viewModel.resetDisambiguations()
                    }
                    
                    Button {
                        destinationText = viewModel.getUserLocationString()
                    } label: {
                        Label("", systemImage: "location")
                    }
                }
                .padding()
                
                Divider()
                
                // Picker for date interpretation
                HStack {
                    Picker(selection: $dateType, label: EmptyView()) {
                        Text("Departure").tag("Departing")
                        Text("Arrival")  .tag("Arriving")
                    }
                    
                    DatePicker("", selection: $date)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(20)
            .padding(5)
            
            Divider()
            Spacer()
            
            // Show all the found journeys
            if (!viewModel.possibleJourneys.isEmpty) {
                ScrollView {
                    ForEach(viewModel.possibleJourneys, id: \.self) { journey in
                        JourneyPlannerBannerView(journey: journey)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(20)
                            .padding(5)
                    }
                }
            } else {
                if (viewModel.disambiguationNeeded) {
                    /*
                     For each origin and destination location (if needed) show disambiguation options based on the view model.
                     
                     If user selects any option then the text in text field should be updated with it
                     */
                    if (!viewModel.originDisambiguationOptions.isEmpty) {
                        DisambiguationOptionsView(userQuery: originText, options: viewModel.originDisambiguationOptions ,onSelection: { selection in
                            // paramaterValue is UGLY but commonName does NOT work.. (thanks TFL)
                            originText = selection.parameterValue
                            
                            // Reset origin disambiguations
                            viewModel.originDisambiguationOptions = []
                            
                            // If destination disambiguations empty then make a request
                            if (viewModel.destinationDisambiguationOptions.isEmpty) {
                                getJourneys()
                            }
                        })
                    }
                    // Else if so they're not shown together but one after another
                    else if (!viewModel.destinationDisambiguationOptions.isEmpty) {
                        DisambiguationOptionsView(userQuery: destinationText, options: viewModel.destinationDisambiguationOptions, onSelection: { selection in
                            // paramaterValue is UGLY but commonName does NOT work.. (thanks TFL)
                            destinationText = selection.parameterValue
                            
                            // Reset destination disambiguations
                            viewModel.destinationDisambiguationOptions = []
                            
                            // This code running implies that origin disambiguations are empty so make a request
                            getJourneys()
                        })
                    }
                } else {
                    if (viewModel.journeyNotFound) {
                        InfoTextView(text: "Journey Not Found.")
                    } else {
                        InfoTextView(text: "Enter the origin and destination points above, you can use postal code, landmark name or an address.")
                    }
                }
            }
            
            Spacer()
        }
        .navigationTitle("Journey Planner")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear() {
            // Reset view model
            viewModel.resetData()
        }
    }
}

struct JourneyPlannerView_Previews: PreviewProvider {
    static var previews: some View {
        JourneyPlannerView()
    }
}
