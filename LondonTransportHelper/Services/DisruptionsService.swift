import Foundation

/*
 List of disruptions based on different rail based transportation modes.
 
 Tube is represented with a dictionary as there are different lines of tube which is not the case for ex: for overground.
 */
struct DisruptionForRailBasedTransportsList {
    var tube:          [String : [Disruption]]
    var dlr:           [Disruption]
    var overground:    [Disruption]
    var elizabethLine: [Disruption]
}

/*
 Service that deals with disruptions from TFL API
 */
class DisruptionsService: Service {
    init() {
        super.init(url: APIManager.tfl.url)
    }
    
    /*
     Gets disruptions for specific mode (ex. bus, dlr) from TFL's API
     */
    func getDisruptionsForMode(mode: TransportMode, completion: @escaping (Result<[Disruption], APIError>) -> Void) {
        let endPoint = "Line/Mode/\(mode.rawValue)/Disruption"
        let queryItems = [
            URLQueryItem(name: "app_key", value: APIManager.tfl.key),
        ]
        
        api.get(endPoint: endPoint, queryItems: queryItems) { result in
            switch result {
            case .success(let data):
                do {
                    let disruptions = try JSONDecoder().decode([Disruption].self, from: data)
                    
                    completion(.success(disruptions))
                } catch {
                    completion(.failure(APIError.badData))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /*
     Gets disruptions for specific line ID from TFL API
     */
    func getDisruptionsForLine(line: String, completion: @escaping (Result<[Disruption], APIError>) -> Void) {
        let endPoint = "Line/\(line)/Disruption"
        let queryItems = [
            URLQueryItem(name: "app_key", value: APIManager.tfl.key),
        ]
        
        api.get(endPoint: endPoint, queryItems: queryItems) { result in
            switch result {
            case .success(let data):
                do {
                    let disruptions = try JSONDecoder().decode([Disruption].self, from: data)
                    
                    completion(.success(disruptions))
                } catch {
                    completion(.failure(APIError.badData))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /*
     Gets disruptuions for specific stop from TFL's API (Individiual stop point - NOT a stop group)
     */
    func getDisruptionsForStop(stationIdOrNaptan: String, completion: @escaping (Result<[Disruption], APIError>) -> Void) {
        let endPoint = "StopPoint/\(stationIdOrNaptan)/Disruption"
        let queryItems = [
            URLQueryItem(name: "app_key", value: APIManager.tfl.key),
        ]
        
        api.get(endPoint: endPoint, queryItems: queryItems) { result in
            switch result {
            case .success(let data):
                do {
                    let disruptions = try JSONDecoder().decode([Disruption].self, from: data)
                    
                    completion(.success(disruptions))
                } catch {
                    completion(.failure(APIError.badData))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
