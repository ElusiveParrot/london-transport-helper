import Foundation

/*
 Common errros that can happen when using external API
 */
enum APIError: Error {
    case badUrl(url: String)                     // Wrongly formatted URL
    case requestFailed(_ error: Error, url: URL) // Request failed (the actual request failed, not a bad response)
    case badResponse(statusCode: Int, url: URL)  // Unexpected/bad response
    case noData                                  // No data returned from the request
    case badData                                 // Data returned from the request is in unexpected/bad format
}

/*
 Helper class that helps with fetching resources from an external API
 */
class APIHelper {
    // Base URL for example https://randomapiwebsite.com/" to which end points are added
    private var apiUrl: String
    
    init(url: String) {
        self.apiUrl = url
        
        // If the URL doesn't end with '/' then add it
        if let lastChar = self.apiUrl.last {
            if (lastChar != "/") {
                self.apiUrl += "/"
            }
        }
    }
    
    /*
     Perform HTTP Get request
     */
    func get(endPoint: String, queryItems: [URLQueryItem], allow300: Bool = false, completion: @escaping (Result<Data, APIError>) -> Void) {
        let fullUrl = WebHelper.createUrl(baseUrl: self.apiUrl, endPoint: endPoint, queryItems: queryItems)
        
#if DEBUG
        print("API Request: \(fullUrl)")
#endif
        
        guard let url = URL(string: fullUrl) else {
            completion(.failure(APIError.badUrl(url: fullUrl)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if error != nil {
                completion(.failure(APIError.requestFailed(error!, url: url)))
                return
            }
            
            // Success API responses are usually between 200 and 299 but 300 can be allowed with 'allow300' parameter
            let successRange = allow300 ? (200..<301) : (200..<300)
            guard let httpResponse = response as? HTTPURLResponse, successRange.contains(httpResponse.statusCode) else {
                completion(.failure(APIError.badResponse(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0, url: url)))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }
            
            completion(.success(data))
        }.resume()
    }
}
