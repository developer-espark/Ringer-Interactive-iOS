import UIKit
import Foundation

class GlobalFunction: NSObject {
    
    //MARK: Get User Token
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
    
    //MARK: Get BaseUrl from local Storage
    static func getBaseUrl() -> String{
        if isKeyPresentInUserDefaults(key: Constant.localStorage.baseUrl) {
            return UserDefaults.standard.string(forKey: Constant.localStorage.baseUrl)!
        } else {
            return ""
        }
    }
    
    //MARK: Store API contacts in local storage 
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
    
    //MARK: Get list of store local contacts
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
    
    //MARK: Function for remove country code
    static func removeCountryCode(from str: String) -> String {
        var str_ret = str
        let regex = try! NSRegularExpression(pattern: "\\+(?:998|996|995|994|993|992|977|976|975|974|973|972|971|970|968|967|966|965|964|963|962|961|960|886|880|856|855|853|852|850|692|691|690|689|688|687|686|685|683|682|681|680|679|678|677|676|675|674|673|672|670|599|598|597|595|593|592|591|590|509|508|507|506|505|504|503|502|501|500|423|421|420|389|387|386|385|383|382|381|380|379|378|377|376|375|374|373|372|371|370|359|358|357|356|355|354|353|352|351|350|299|298|297|291|290|269|268|267|266|265|264|263|262|261|260|258|257|256|255|254|253|252|251|250|249|248|246|245|244|243|242|241|240|239|238|237|236|235|234|233|232|231|230|229|228|227|226|225|224|223|222|221|220|218|216|213|212|211|98|95|94|93|92|91|90|86|84|82|81|66|65|64|63|62|61|60|58|57|56|55|54|53|52|51|49|48|47|46|45|44\\D?1624|44\\D?1534|44\\D?1481|44|43|41|40|39|36|34|33|32|31|30|27|20|7|1\\D?939|1\\D?876|1\\D?869|1\\D?868|1\\D?849|1\\D?829|1\\D?809|1\\D?787|1\\D?784|1\\D?767|1\\D?758|1\\D?721|1\\D?684|1\\D?671|1\\D?670|1\\D?664|1\\D?649|1\\D?473|1\\D?441|1\\D?345|1\\D?340|1\\D?284|1\\D?268|1\\D?264|1\\D?246|1\\D?242|1)\\D?", options: .caseInsensitive)
        str_ret = regex.stringByReplacingMatches(in: str, options: [], range: NSRange(0..<str.utf16.count), withTemplate: "")
        return str_ret
    }
    
    //MARK: Function for check valid URL
    static func isValidUrl(_ urlSring: String?) -> Bool {
        let urlPattern = "^(https?|http?|ftp|file)://[-a-zA-Z0-9+&@#/%?=~_|!:,.;]*[-a-zA-Z0-9+&@#/%=ō~_|]"
        let urlPred = NSPredicate(format: "SELF MATCHES %@", urlPattern)
        
        let result = urlPred.evaluate(with: urlSring)
        return result
    }
}
