import UIKit

extension RingerInteractiveNotification {
    
    public func ringerInteractiveLogin(username: String, password: String) {
        var header: [String : String] = [:]
        header["Content-Type"] = "application/json"
        
        var authDic = [String:Any]()
        authDic["username"] = username
        authDic["password"] = password
        
        let boundary = WebAPIManager().generateBoundary()
        
        WebAPIManager.makeAPIRequest(method: "GET", isFormDataRequest: false, header: header, path: Constant.Api.token_with_authorities, isImageUpload: false, images: [], auth: true, authDic: authDic, params: [:], baseUrl: "https://sandbox.thrio.io/", boundary: boundary) { response, status in
            if status == 200 {
                let responseDataDic = response as! [String :Any]
                baseURL = "\(responseDataDic["location"] ?? "")/"
                UserDefaults.standard.set("\(responseDataDic["token"] ?? "")", forKey: Constant.localStorage.token)
                UserDefaults.standard.set("\(responseDataDic["location"] ?? "")/", forKey: Constant.localStorage.baseUrl)
                self.ringerInteractiveGetContact()
            } else {
                let responseDataDic = response as! [String :Any]
                print("\(responseDataDic["error"] ?? "")")
            }
        }
    }
    
    func ringerInteractiveGetContact() {
        
        var header: [String : String] = [:]
        header["Content-Type"] = "application/json"
        header["Authorization"] = GlobalFunction.getUserToken()
        
        let boundary = WebAPIManager().generateBoundary()
        WebAPIManager.makeAPIRequest(method: "GET", isFormDataRequest: false, header: header, path: Constant.Api.getContact, isImageUpload: false, images: [], params: [:], boundary: boundary) { response, status in
            if status == 200 {
                let responseDataDic = response as! [String :Any]
                let contactListModel = ContactListModel(fromDictionary: responseDataDic)
                for i in contactListModel.objects {
                    if i.avatar != nil && i.avatar != "" {
                        self.group.enter()
                        ContactSave().downloadImageAndContactSave(name: i.firstName + " " + i.lastName, number: i.phone, editNumber: i.phone, imageUrl: self.ringerInteractiveGetContactImage(contactId: i.contactId))
                    } else {
                        ContactSave().downloadImageAndContactSave(name: i.firstName + " " + i.lastName, number: i.phone)
                    }
                }
            } else {
                let responseDataDic = response as! [String :Any]
                print("\(responseDataDic["error"] ?? "")")
            }
        }
    }
    
    func ringerInteractiveGetContactImage(contactId : String) -> String{
        var header: [String : String] = [:]
        header["Authorization"] = GlobalFunction.getUserToken()
        
        let boundary = WebAPIManager().generateBoundary()
        
        var imageUrl = ""
        
        WebAPIManager.makeAPIRequest(method: "GET", isFormDataRequest: false, header: header, path: Constant.Api.getContactImage + "\(contactId)/avatar", isImageUpload: false, images: [], params: [:], boundary: boundary) { response, status in
            self.group.leave()
            if status == 200 {
                imageUrl = "\(response["imgUrl"]!)"
            } else {
                let responseDataDic = response as! [String :Any]
                print("\(responseDataDic["error"] ?? "")")
            }
        }
        
        return imageUrl
    }
}
