import Foundation

/*
 Service that deals with vehicles from TFL's API
 */
class VehicleService: Service {
    init() {
        super.init(url: APIManager.tfl.url)
    }
    
    /*
     Get arrivals for a singular vehicle (it can be a bus, tube train or anything else)
     */
    func getArrivalsForVehicle(vehicleId: String, completion: @escaping (Result<[VehiclePrediction], APIError>) -> Void) {
        let endPoint = "Vehicle/\(vehicleId)/Arrivals"
        let queryItems = [
            URLQueryItem(name: "app_key", value: APIManager.tfl.key),
        ]
        
        api.get(endPoint: endPoint, queryItems: queryItems) { result in
            switch result {
            case .success(let data):
                do {
                    let predictions = try JSONDecoder().decode([VehiclePrediction].self, from: data)
                    
                    completion(.success(predictions))
                } catch {
                    completion(.failure(APIError.badData))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
