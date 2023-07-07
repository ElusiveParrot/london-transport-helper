import Foundation
import CoreLocation

class StopGroupNearbyViewModel: ObservableObject {
    @Published var stops: [StopPointGroup] = []
    
    private let stopPointService = StopPointService()
    
    var locationManager = CLLocationManager()
    
    // Check if user has authorised the app to access the location data
    var locationAvailable: Bool {
        return (locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus ==  .authorizedAlways) && locationManager.location != nil
    }
    
    /*
     Searches for stops based on the provided location using the TFL's API
     */
    func searchForStopGroupsNearby() {
        guard let location = locationManager.location else {
#if DEBUG
            print("Unable to access location")
#endif
            return
        }
        
        stopPointService.getStopsGroupsNearby(lat: location.coordinate.latitude, lon: location.coordinate.longitude) { result in
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
