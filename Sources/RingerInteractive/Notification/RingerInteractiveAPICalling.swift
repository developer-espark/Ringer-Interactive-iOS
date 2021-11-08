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
                self.contactListModel = ContactListModel(fromDictionary: responseDataDic)
                for i in 0..<self.contactListModel.objects.count {
                    if self.contactListModel.objects[i].avatar != nil && self.contactListModel.objects[i].avatar != "" {
                        self.group.enter()
                        self.ringerInteractiveGetContactImage(contactId: self.contactListModel.objects[i].contactId, index: i)
                    } else {
                        self.count += 1
                        if self.count == self.contactListModel.objects.count {
                            self.saveAndUpdateContact()
                        }
                    }
                }
            } else {
                let responseDataDic = response as! [String :Any]
                print("\(responseDataDic["error"] ?? "")")
            }
        }
    }
    
    func ringerInteractiveGetContactImage(contactId : String, index: Int) {
        var header: [String : String] = [:]
        header["Authorization"] = GlobalFunction.getUserToken()
        
        let boundary = WebAPIManager().generateBoundary()
        
        WebAPIManager.makeAPIRequest(method: "GET", isFormDataRequest: false, header: header, path: Constant.Api.getContactImage + "\(contactId)/avatar", isImageUpload: false, images: [], params: [:], boundary: boundary) { response, status in
            self.group.leave()
            if status == 200 {
                self.count += 1
                self.contactListModel.objects[index].imageUrl = "\(response["imgUrl"]!)"
                if self.count == self.contactListModel.objects.count {
                    self.saveAndUpdateContact()
                }
            } else {
                let responseDataDic = response as! [String :Any]
                print("\(responseDataDic["error"] ?? "")")
            }
        }
    }
    
    func saveAndUpdateContact() {
        for j in self.contactListModel.objects {
            ContactSave().downloadImageAndContactSave(name: j.firstName + "" + j.lastName, number: j.phone, editNumber: j.phone, imageUrl: j.imageUrl)
        }
    }
}