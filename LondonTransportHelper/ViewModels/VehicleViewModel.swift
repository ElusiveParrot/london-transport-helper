import SwiftUI

class VehicleViewModel: ObservableObject {
    @Published var predictions: [VehiclePrediction] = []
    
    var vehicleService = VehicleService()
    
    var vehicleId: String
    
    init(vehicleId: String) {
        self.vehicleId = vehicleId
    }
    
    /*
     Get predictions for when a specific vehicle arrives at it's desginated stops
     */
    func getArrivalPredictions() {
        vehicleService.getArrivalsForVehicle(vehicleId: vehicleId) { result in
            switch (result) {
            case .success(let predictions):
                DispatchQueue.main.async {
                    self.predictions = predictions
                }
            case .failure(let error):
#if DEBUG
                print("Unable to fetch predictions from API, \(error)")
#endif
                DispatchQueue.main.async {
                    self.predictions = []
                }
            }
        }
    }
    
    /*
     Reset the view model's API data, fixes CG bug
     */
    func resetData() {
        predictions = []
    }
}
