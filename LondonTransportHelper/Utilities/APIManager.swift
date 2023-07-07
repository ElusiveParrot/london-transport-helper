/*
 Represents singular API's data (base url and key)
 */
struct API {
    let key: String // API Key
    let url: String // Base URL to which endpoints will be added for ex. https://google.com/
};

struct APIManager {
    static let tfl = API(key: "YOUR_API_KEY_HERE", url: "https://api.tfl.gov.uk/")
};
