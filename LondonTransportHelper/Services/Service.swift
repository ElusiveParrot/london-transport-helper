/*
 Base class for services
 */
class Service {
    var api: APIHelper
    
    init(url: String) {
        self.api = APIHelper(url: url)
    }
}
