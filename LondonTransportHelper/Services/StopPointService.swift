import Foundation
import SwiftUI

/*
 Represents all the values that are needed from TFL's API's /StopPoint/Search/QUERY endpoint.
 
 Other data (not the stops) is useless so can be discarded
 */
struct StopPointGroupsSearchResult: Decodable {
    let matches: [StopPointGroup]
}

/*
 Represents all the values that are needed from TFL's API's /StopPoint/ID endpoint.
 */
struct StopSearchResult: Decodable {
    // Used to get parent of individual stops
    let id:          String
    let commonName:  String
    let lat:         Double
    let lon:         Double
    let modes:       [TransportMode]
    
    // Used to get individual stop points
    let children: [StopPoint]
    let lines:    [Line]
}

/*
 Represents all the values that are needed from tflapi /StopPoint/Search (by location) endpoint.
 */
struct StopsNearbyResult: Decodable {
    let stopPoints: [StopPoint]
}

/*
 Represents a list of different stops based on their transport mode from the TFL's API.
 */
struct StopList {
    var bus:           [StopPoint]
    var dlr:           [StopPoint]
    var tube:          [StopPoint]
    var overground:    [StopPoint]
    var elizabethLine: [StopPoint]
    
    /*
     TFL removed National Rail arrivals from their API.
     
     The boolean is stored in case the support for national rail is added. (Most likely as a link to National Rail website) but it's unused for now.
     */
    var nationalRail:  Bool
}

/*
 Service that deals with TFL API's StopPoints (StopPoints are explained in their model file)
 */
class StopPointService: Service {
    @AppStorage(AppSetting.nearbySearchRange.rawValue) private var nearbySearchRange = 200
    
    init() {
        super.init(url: APIManager.tfl.url)
    }
    
    /*
     Fetch StopPoint groups from the API based on the 'common name' (name of the stop group)
     */
    func getStopPointGroups(name: String, completion: @escaping (Result<[StopPointGroup], APIError>) -> Void) {
        let endPoint = "StopPoint/Search"
        let queryItems = [
            URLQueryItem(name: "query",   value: name),
            URLQueryItem(name: "app_key", value: APIManager.tfl.key),
        ]
        
        api.get(endPoint: endPoint, queryItems: queryItems) { result in
            switch result {
            case .success(let data):
                do {
                    let stops = try JSONDecoder().decode(StopPointGroupsSearchResult.self, from: data)
                    
                    completion(.success(stops.matches))
                } catch {
                    completion(.failure(APIError.badData))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /*
     Get parent stop group of an individual stop
     */
    func getStopPointsParentGroups(stopPoints: [StopPoint], completion: @escaping (Result<[StopPointGroup], APIError>) -> Void) {
        var parentIds: [String] = []
        
        for stop in stopPoints {
            guard let stationNaptan = stop.stationNaptan else {
                continue
            }
            
            // Make sure they are unique
            if (!parentIds.contains(stationNaptan)) {
                parentIds.append(stationNaptan)
            }
        }
        
        // Concat ids for API request
        var parentIdsString = ""
        for parentId in Array(parentIds.prefix(10)) {
            parentIdsString += (parentId + ",")
        }
        
        let endPoint = "StopPoint/\(parentIdsString)"
        let queryItems = [
            URLQueryItem(name: "app_key", value: APIManager.tfl.key)
        ]
        
        api.get(endPoint: endPoint, queryItems: queryItems) { result in
            switch result {
            case .success(let data):
                do {
                    var groupsRes: [StopSearchResult] = []
                    
                    // If only one is provided then API returns single instead of array so turn it into array
                    if (parentIds.count == 1) {
                        groupsRes.append(try JSONDecoder().decode(StopSearchResult.self, from: data))
                    } else {
                        groupsRes = try JSONDecoder().decode([StopSearchResult].self, from: data)
                    }
                    
                    var groups: [StopPointGroup] = []
                    for stop in groupsRes {
                        // Construct stop group from its info
                        groups.append(StopPointGroup(id: stop.id, name: stop.commonName, lat: stop.lat, lon: stop.lon, modes: stop.modes))
                    }
                    
                    completion(.success(groups))
                } catch {
                    completion(.failure(APIError.badData))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /*
     Fetch StopPoint groups nearby from the API
     */
    func getStopsGroupsNearby(lat: Double, lon: Double, completion: @escaping (Result<[StopPointGroup], APIError>) -> Void) {
        let endPoint = "StopPoint"
        let queryItems = [
            URLQueryItem(name: "app_key",   value: APIManager.tfl.key),
            URLQueryItem(name: "lat",       value: String(lat)),
            URLQueryItem(name: "lon",       value: String(lon)),
            URLQueryItem(name: "radius",    value: String(nearbySearchRange)),
            URLQueryItem(name: "stopTypes", value: "NaptanBusCoachStation," +
                         "NaptanBusWayPoint," +
                         "NaptanMetroAccessArea," +
                         "NaptanMetroEntrance," +
                         "NaptanMetroPlatform," +
                         "NaptanMetroStation," +
                         "NaptanOnstreetBusCoachStopCluster," +
                         "NaptanOnstreetBusCoachStopPair," +
                         "NaptanPrivateBusCoachTram," +
                         "NaptanPublicBusCoachTram," +
                         "NaptanRailAccessArea," +
                         "NaptanRailEntrance," +
                         "NaptanRailPlatform," +
                         "NaptanRailStation,"/* +
                                              "TransportInterchange"*/),
            
            URLQueryItem(name: "useStopPointHierarchy", value: "true"),
        ]
        
        api.get(endPoint: endPoint, queryItems: queryItems) { [self] result in
            switch result {
            case .success(let data):
                do {
                    let stops = try JSONDecoder().decode(StopsNearbyResult.self, from: data)
                    
                    getStopPointsParentGroups(stopPoints: stops.stopPoints) { result in
                        switch (result) {
                        case .success(let groupList):
                            completion(.success(groupList))
                            
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                    
                } catch {
                    completion(.failure(APIError.badData))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /*
     Fetch individual stops from Stop Point Group
     */
    func getStops(stopGroup: StopPointGroup, completion: @escaping (Result<StopList, APIError>) -> Void) {
        let endPoint = "StopPoint/\(stopGroup.id)"
        let queryItems = [
            URLQueryItem(name: "app_key", value: APIManager.tfl.key),
        ]
        
        api.get(endPoint: endPoint, queryItems: queryItems) { result in
            switch result {
            case .success(let data):
                do {
                    let stops = try JSONDecoder().decode(StopSearchResult.self, from: data)
                    
                    // Use TFLHelper's recursive scanning
                    completion(.success(TFLHelper.scanStopGroupChildrenForStops(data: stops.children, group: stopGroup, stationModes: stopGroup.modes, integratedLines: stops.lines)))
                } catch {
                    completion(.failure(APIError.badData))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
