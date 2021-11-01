import UIKit
import Foundation

class GlobalFunction: NSObject {
    
    //MARK:- Get User Token
    static func getUserToken() -> String{
        if isKeyPresentInUserDefaults(key: Constant.localStorage.token) {
            return UserDefaults.standard.string(forKey: Constant.localStorage.token)!
        } else {
            return ""
        }
    }
    
    //MARK: check key present in UserDefaults
    static func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}
