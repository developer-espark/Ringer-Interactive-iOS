import UIKit

extension RingerInteractiveNotification {
    
    public func ringerInteractiveLogin(username: String, password: String,CompanyName companyName : String? = "") {
        totalCount = 0
        UserDefaults.standard.set(companyName, forKey: Constant.localStorage.companyName)
        var header: [String : String] = [:]
        header["Content-Type"] = "application/json"
        
        var authDic = [String:Any]()
        authDic["username"] = username
        authDic["password"] = password
        
        let boundary = WebAPIManager().generateBoundary()
        
        WebAPIManager.makeAPIRequest(method: "GET", isFormDataRequest: false, header: header, path: Constant.Api.token_with_authorities, isImageUpload: false, images: [], auth: true, authDic: authDic, params: [:], baseUrl: "https://sandbox.thrio.io/", boundary: boundary) { response, status in
            if status == 200 || status == 201  {
                let responseDataDic = response as! [String :Any]
                baseURL = "\(responseDataDic["location"] ?? "")/"
                UserDefaults.standard.set("\(responseDataDic["token"] ?? "")", forKey: Constant.localStorage.token)
                UserDefaults.standard.set("\(responseDataDic["location"] ?? "")/", forKey: Constant.localStorage.baseUrl)
                self.showDeviceInfo()
            } else {
                let responseDataDic = response as! [String :Any]
                print("\(responseDataDic["error"] ?? "")")
            }
        }
    }
    
    func showDeviceInfo() {
        let device = UIDevice.current
        print("Device Name : \(device.name)")
        print("Current Os : \(UIDevice.current.systemName) \(device.systemVersion)")
        print("Current Time Zone : \(TimeZone.current.description)")
        self.ringerInteractiveDeviceRegistartion()
    }
    
    func ringerInteractiveDeviceRegistartion() {
        var header: [String : String] = [:]
        header["Content-Type"] = "application/json"
        header["Authorization"] = GlobalFunction.getUserToken()
        
        var param : [String : Any] = [:]
        param["firebaseToken"] = firebaseToken
        param["os"] = "ios"
        param["uuid"] = UIDevice.current.identifierForVendor?.uuidString ?? .none
        
        let boundary = WebAPIManager().generateBoundary()
        WebAPIManager.makeAPIRequest(method: "POST", isFormDataRequest: false, header: header, path: Constant.Api.registerMobile, isImageUpload: false, images: [], params: param, boundary: boundary) { response, status in
            if status == 200 || status == 201 {
                self.ringerInteractiveGetContact()
            }
        }
    }
    
    func ringerInteractiveGetContact() {
        
        var header: [String : String] = [:]
        header["Content-Type"] = "application/json"
        header["Authorization"] = GlobalFunction.getUserToken()
        
        let boundary = WebAPIManager().generateBoundary()
        WebAPIManager.makeAPIRequest(method: "GET", isFormDataRequest: false, header: header, path: Constant.Api.getContact, isImageUpload: false, images: [], params: [:], boundary: boundary) { response, status in
            if status == 200 || status == 201 {
                let responseDataDic = response as! [String :Any]
                contactListModel = ContactListModel(fromDictionary: responseDataDic)
                for i in 0..<contactListModel.objects.count {
                    if contactListModel.objects[i].galleryId != nil && contactListModel.objects[i].galleryId != "" {
                        self.group.enter()
                        self.ringerInteractiveGetContactImage(contactId: contactListModel.objects[i].galleryId, contactNumber:contactListModel.objects[i].phone[0], index: i)
                    } else {
                        self.count += 1
                        if self.count == contactListModel.objects.count {
                            self.count = 0
                            self.saveAndUpdateContact(index: 0)
                        }
                    }
                }
            } else {
                let responseDataDic = response as! [String :Any]
                print("\(responseDataDic["error"] ?? "")")
            }
        }
    }
    
    func ringerInteractiveGetContactImage(contactId : String, contactNumber : String, index: Int) {
        var header: [String : String] = [:]
        header["Authorization"] = GlobalFunction.getUserToken()
        
        let boundary = WebAPIManager().generateBoundary()
        
        WebAPIManager.makeAPIRequest(method: "GET", isFormDataRequest: false, header: header, path: Constant.Api.getGalleryImage + "\(contactId)/avatar?phone=\(contactNumber)", isImageUpload: false, images: [], params: [:], boundary: boundary) { response, status in
            self.group.leave()
            if status == 200 || status == 201 {
                self.count += 1
                contactListModel.objects[index].imageUrl = "\(response["imgUrl"]!)"
                if self.count == contactListModel.objects.count {
                    self.count = 0
                    self.saveAndUpdateContact(index: 0)
                }
            } else {
                let responseDataDic = response as! [String :Any]
                print("\(responseDataDic["error"] ?? "")")
            }
        }
    }
    
//    func saveAndUpdateContact() {
//        for j in self.contactListModel.objects {
//            ContactSave().downloadImageAndContactSave(name: j.firstName + " " + j.lastName, number: j.phone, editNumber: j.phone, imageUrl: j.imageUrl)
//        }
//    }
    
    func saveAndUpdateContact(index:Int) {
        if index < contactListModel.objects.count {
            for contacts in contactListModel.objects[index].phone {
                self.group.enter()
                ContactSave().downloadImageAndContactSave(name: contactListModel.objects[index].firstName + "^" + contactListModel.objects[index].lastName, number: contactListModel.objects[index].phone, editNumber: contacts, imageUrl: contactListModel.objects[index].imageUrl)
            }
        }
    }
}
