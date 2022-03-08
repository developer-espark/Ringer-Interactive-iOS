import Foundation

var baseURL = "https://sandbox.thrio.io/"

class Constant: NSObject {
    
    struct Api {
        static let token_with_authorities = "provider/token-with-authorities"
        static let getContact = "data/api/types/contact"
        static let getContactImage = "data/api/types/contact/"
        static let getGalleryImage = "data/api/types/gallery/"
        static let registerMobile = "data/api/types/mobileregistration"
    }
    
    struct localStorage {
        static let token = "token"
        static let baseUrl = "baseUrl"
        static let companyName = "companyName"
        static let contactList = "contactList"
        static let firstSync = "firstSync"
        static let tokenTime = "tokenTime"
        static let mobileNumber = "mobileNumber"
    }
    
}
