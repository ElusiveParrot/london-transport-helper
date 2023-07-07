import Foundation

class ArrivalsViewModel: ObservableObject {
    @Published var arrivals:   [String : [Arrival]] = [:]
    
    private var arrivalsService = ArrivalsService()
    
    /*
     For buses: naptanId
     For other: stationId
     */
    private var stopIdOrNaptan: String
    
    init(stopIdOrNaptan: String) {
        self.stopIdOrNaptan = stopIdOrNaptan
    }
    
    /*
     Get all the arrivals for an individual stop (or stop group in case of integrated stops)
     */
    func getArrivals(filter: @escaping (Arrival) -> Bool) {
        arrivalsService.getArrivalsForStop(naptanId: stopIdOrNaptan) { result in
            switch (result) {
            case .success(let arrivals):
                DispatchQueue.main.async {
                    // Reset old arrivals
                    self.arrivals = [:]
                    
                    for arrival in arrivals {
                        if (filter(arrival)) {
                            if (self.arrivals[arrival.lineName] == nil) {
                                // If empty then make it equal to array with just that one entry
                                self.arrivals[arrival.lineName] = [arrival]
                            } else {
                                // If not then just add the arrival
                                self.arrivals[arrival.lineName]?.append(arrival)
                            }
                        }
                    }
                }
            case .failure(let error):
#if DEBUG
                print("Unable to fetch arrivals from API, \(error)")
#endif
                DispatchQueue.main.async {
                    // If the API fails just show empty results
                    self.arrivals = [:]
                }
            }
        }
    }
    
    /*
     Reset the view model's API data, fixes CG bug
     */
    func resetData() {
        arrivals = [:]
    }
}
