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
    
    static func getBaseUrl() -> String{
        if isKeyPresentInUserDefaults(key: Constant.localStorage.baseUrl) {
            return UserDefaults.standard.string(forKey: Constant.localStorage.baseUrl)!
        } else {
            return ""
        }
    }
    
    static func setContactList(contactListModel: [ContactListObject]?) {
        if let contactModel = contactListModel {
            do {
                let archivedServerModules = try NSKeyedArchiver.archivedData(withRootObject: contactModel, requiringSecureCoding: false)
                UserDefaults.standard.set(archivedServerModules, forKey: Constant.localStorage.contactList)
                UserDefaults.standard.synchronize()
            }catch {
                
            }
        }
    }
    
    static func getContactList() -> [ContactListObject]! {
        if isKeyPresentInUserDefaults(key: "contactList"){
            do {
                let data = UserDefaults.standard.data(forKey: Constant.localStorage.contactList)
                let decodedUserData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data!) as! [ContactListObject]
                return decodedUserData
            } catch {
                return []
            }
        } else {
            return []
        }
    }
    
}
