import Foundation

/*
 Service that deals with retrieving arrivals from TFL API
 */
class ArrivalsService: Service {
    init() {
        super.init(url: APIManager.tfl.url)
    }
    
    /*
     Requests arrivals for a specific stop based on it's naptanId (or [technically] stationId for rail based stops)
     */
    func getArrivalsForStop(naptanId: String, completion: @escaping (Result<[Arrival], APIError>) -> Void) {
        let endPoint = "StopPoint/\(naptanId)/Arrivals"
        let queryItems = [
            URLQueryItem(name: "app_key", value: APIManager.tfl.key),
        ]
        
        api.get(endPoint: endPoint, queryItems: queryItems) { result in
            switch result {
            case .success(let data):
                do {
                    let arrivals = try JSONDecoder().decode([Arrival].self, from: data)
                    
                    completion(.success(arrivals))
                } catch {
                    completion(.failure(APIError.badData))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
