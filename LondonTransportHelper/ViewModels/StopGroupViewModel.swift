import Foundation

class StopGroupViewModel: ObservableObject {
    @Published var stopList = StopList(bus: [], dlr: [], tube: [], overground: [], elizabethLine: [], nationalRail: false)
    
    private let stopPointService = StopPointService()
    
    // Stop group represented by the view
    var stopGroup: StopPointGroup
    
    init(stopGroup: StopPointGroup) {
        self.stopGroup = stopGroup
    }
    
    func searchForStops() {
        stopPointService.getStops(stopGroup: stopGroup) { result in
            switch (result) {
            case .success(let stopList):
                DispatchQueue.main.async {
                    self.stopList = stopList
                }
            case .failure(let error):
#if DEBUG
                print("Error: Unable to fetch stops from API, \(error)")
#endif
                DispatchQueue.main.async {
                    // If the API fails just show empty results
                    self.stopList.bus           = []
                    self.stopList.tube          = []
                    self.stopList.dlr           = []
                    self.stopList.overground    = []
                    self.stopList.elizabethLine = []
                    self.stopList.nationalRail  = false
                }
            }
        }
    }
    
    /*
     Reset the view model's API data, fixes CG bug
     */
    func resetData() {
        stopList = StopList(bus: [], dlr: [], tube: [], overground: [], elizabethLine: [], nationalRail: false)
    }
}
