import Foundation
import CoreLocation

/*
 Represents a choice of disambiguation for the user
 */
struct JourneyDisambiguationOption: Hashable {
    let parameterValue: String
    let commonName:     String
}

class JourneyPlannerViewModel: ObservableObject {
    @Published var possibleJourneys:                 [Journey] = []
    @Published var originDisambiguationOptions:      [JourneyDisambiguationOption] = []
    @Published var destinationDisambiguationOptions: [JourneyDisambiguationOption] = []
    
    var locationManager = CLLocationManager()
    
    // Toggled when journey was specifically not found
    var journeyNotFound = false
    
    // Disambiguation needed is there are no journeys and either origin or destination sisambiguations are not empty
    var disambiguationNeeded: Bool {
        return possibleJourneys.isEmpty && (!originDisambiguationOptions.isEmpty || !destinationDisambiguationOptions.isEmpty)
    }
    
    private let joruneyPlannerSerivce = JourneyPlannerService()
    
    private func getDisambiguationOptions(journeyPlanResult: JourneyPlannerResult) {
        // Origin disambiguation
        if let originDisambiguations = journeyPlanResult.fromLocationDisambiguation {
            // Check if needed
            if let options = originDisambiguations.disambiguationOptions {
                // Add each option's paramaterValue and commonName to list of options
                for option in options {
                    self.originDisambiguationOptions.append(JourneyDisambiguationOption(parameterValue: option.parameterValue, commonName: option.place.commonName))
                }
            }
        }
        
        // Destination disambiguation
        if let destinationDisambiguations = journeyPlanResult.toLocationDisambiguation {
            // Check if needed
            if let options = destinationDisambiguations.disambiguationOptions {
                // Add each option's paramaterValue and commonName to list of options
                for option in options {
                    self.destinationDisambiguationOptions.append(JourneyDisambiguationOption(parameterValue: option.parameterValue, commonName: option.place.commonName))
                    
                }
            }
        }
    }
    
    func getUserLocationString() -> String {
        guard let location = locationManager.location else {
            return "Unknown Location"
        }
        
        return "\(location.coordinate.latitude), \(location.coordinate.longitude)"
    }
    
    /*
     Get journeys for the query
     */
    func getJourneyPlan(from: String, to: String, date: Date, dateType: String) {
        joruneyPlannerSerivce.getJourneyPlan(from: from, to: to, date: date, dateType: dateType) { result in
            switch (result) {
            case .success(let journeyPlanResult):
                DispatchQueue.main.async {
                    // Clear old data
                    self.resetData()
                    
                    // No disambiguation needed - assign journeys
                    if let journeys = journeyPlanResult.journeys {
                        self.possibleJourneys = journeys
                        // Disambiguation needed
                    } else {
                        self.getDisambiguationOptions(journeyPlanResult: journeyPlanResult)
                    }
                }
                
            case .failure(let error):
#if DEBUG
                print("Unable to get journeys from \(from) to \(to) from the API, \(error)")
#endif
                DispatchQueue.main.async {
                    self.resetData()
                    
                    self.journeyNotFound = true
                }
            }
        }
    }
    
    /*
     Reset the view model, fixes CG bug.
     */
    func resetData() {
        possibleJourneys = []
        journeyNotFound  = false
        
        resetDisambiguations()
    }
    
    /*
     Reset disambiguations arrays only
     */
    func resetDisambiguations() {
        originDisambiguationOptions      = []
        destinationDisambiguationOptions = []
    }
}
