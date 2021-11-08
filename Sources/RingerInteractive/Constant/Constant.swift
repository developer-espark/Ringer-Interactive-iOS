import Foundation

var baseURL = "https://sandbox.thrio.io/"

class Constant: NSObject {
    
    struct Api {
        static let token_with_authorities = "provider/token-with-authorities"
        static let getContact = "data/api/types/contact"
        static let getContactImage = "data/api/types/contact/"
    }
    
    struct localStorage {
        static let token = "token"
        static let baseUrl = "baseUrl"
    }
    
}
