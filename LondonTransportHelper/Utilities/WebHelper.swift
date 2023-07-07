import Foundation

/*
 Helps with various web related functions
 */
class WebHelper {
    
    /*
     Creates a full URL based on the base url (ex: https://website.com/), the API endpoint (api/search) and query arguments (?query=This%20Is%20Example)
     */
    static func createUrl(baseUrl: String, endPoint: String, queryItems: [URLQueryItem]) -> String {
        let urlComponents = NSURLComponents(string: baseUrl + endPoint)!
        urlComponents.queryItems = queryItems
        
        return urlComponents.url!.absoluteString
    }
    
    /*
     Encodes a string so that it can be used within an URL
     */
    static func encodeForUrl(string: String) -> String {
        return string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }
}
