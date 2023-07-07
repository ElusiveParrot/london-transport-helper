import SwiftUI

/*
 Shows a list with possible options for disambiguation
 */
struct DisambiguationOptionsView: View {
    // The name of the location that user tried to input
    var userQuery: String
    
    // Options for the disambiguation as provided by the view model from the API
    var options: [JourneyDisambiguationOption]
    
    // Called when an option is selected by the user
    var onSelection: (JourneyDisambiguationOption) -> ()
    
    var body: some View {
        VStack {
            Text("Results for: \(userQuery)")
            List {
                ForEach(options, id: \.self) { option in
                    Button() {
                        onSelection(option)
                    } label: {
                        Text(option.commonName)
                    }
                }
            }
        }
    }
}

struct DisambiguationOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        DisambiguationOptionsView(userQuery: "Something", options: [JourneyDisambiguationOption(parameterValue: "firstoptionid", commonName: "First Option"), JourneyDisambiguationOption(parameterValue: "secondoptionid", commonName: "Second Option")], onSelection: {_ in })
    }
}
