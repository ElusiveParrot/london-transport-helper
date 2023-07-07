import Foundation

/*
 Represents all the values that are needed from tflapi /Joruney/ endpoint.
 */
struct JourneyPlannerResult: Decodable {
    // These are present if disambiguations are NOT needed
    let journeys: [Journey]?
    let lines:    [Line]?
    
    /*
     This is present if disambiguations are need
     
     One or both can present.
     */
    let toLocationDisambiguation:   JourneyLocationDisambiguation?
    let fromLocationDisambiguation: JourneyLocationDisambiguation?
}

/*
 Service that deals with journey planning based on TFL API
 */
class JourneyPlannerService: Service {
    init() {
        super.init(url: APIManager.tfl.url)
    }
    
    /*
     Format swift's Date object into TFL's Journey API format
     */
    private func formatDateAndTimeForJourneyPlanner(date: Date) -> (date: String, time: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        let formattedDate = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "HHmm"
        
        let formattedTime = dateFormatter.string(from: date)
        
        return (date: formattedDate, time: formattedTime)
    }
    
    /*
     Use TFL's Journey Planner to get a route from one point to another
     */
    func getJourneyPlan(from: String, to: String, date: Date, dateType: String, completion: @escaping (Result<JourneyPlannerResult, APIError>) -> Void) {
        let formattedDateTime = formatDateAndTimeForJourneyPlanner(date: date)
        
        let endPoint = "Journey/JourneyResults/\(WebHelper.encodeForUrl(string: from))/to/\(WebHelper.encodeForUrl(string: to))"
        let queryItems = [
            URLQueryItem(name: "app_key",           value: APIManager.tfl.key),
            URLQueryItem(name: "taxiOnlyTrip",      value: "false"),
            URLQueryItem(name: "journeyPreference", value: "leastTime"),
            URLQueryItem(name: "date",              value: formattedDateTime.date),
            URLQueryItem(name: "time",              value: formattedDateTime.time),
            URLQueryItem(name: "timeIs",            value: dateType),
            URLQueryItem(name: "mode",              value: "bus,overground,elizabeth-line,international-rail,tram,national-rail,dlr,tube,walking") // Everything
        ]
        
        api.get(endPoint: endPoint, queryItems: queryItems, allow300: true) { result in
            switch result {
            case .success(let data):
                do {
                    let res = try JSONDecoder().decode(JourneyPlannerResult.self, from: data)
                    
                    /*
                     This is a single occurence where the service returns the actual results object instead of the filtered data to the view model.
                     
                     This is done due to the fact that every single object in the result is nullable as there might be disambiguations needed and these will need to be handled by the view model so that they can be applied for the next (correct) request.
                     */
                    completion(.success(res))
                } catch {
                    completion(.failure(APIError.badData))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
