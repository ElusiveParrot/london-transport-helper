import Foundation

class StopGroupSearchViewModel: ObservableObject {
    @Published var stops: [StopPointGroup] = []
    
    private let stopPointService = StopPointService()
    
    /*
     Searches for stops based on the provided query using the service
     */
    func searchForStopGroups(query: String) {
        stopPointService.getStopPointGroups(name: query) { result in
            switch (result) {
            case .success(let stops):
                DispatchQueue.main.async {
                    self.stops = stops
                }
            case .failure(let error):
#if DEBUG
                print("Unable to fetch stops from API, \(error)")
#endif
                DispatchQueue.main.async {
                    // If the API fails just show empty results
                    self.stops = []
                }
            }
        }
    }
    
    /*
     Reset the view model's API data, fixes CG bug
     */
    func resetData() {
        stops = []
    }
}
