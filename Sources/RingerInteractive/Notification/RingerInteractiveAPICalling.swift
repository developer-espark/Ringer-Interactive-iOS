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
            if status == 200 || status == 201 || status == 409 {
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
                var contactList = self.getContactList()
                if (contactList?.count ?? 0) > 0 {
                    let localContacts = contactList!.map{$0.contactId ?? ""}
                    let apiContacts = contactListModel.objects.map{$0.contactId ?? ""}
                    var set1:Set<String> = Set(localContacts)
                    let set2:Set<String> = Set(apiContacts)
                    set1.subtract(set2)
                    let uniqueContact = Array(set1)
                    if uniqueContact.count > 0 {
                        for i in uniqueContact {
                            let index = contactList?.firstIndex(where: {$0.contactId == i})
                            if index != nil {
                                contactList!.remove(at: Int(index!))
                            }
                        }
                        self.setContactList(contactListModel: contactList)
                        self.addNewContact()
                    } else {
                        self.addNewContact()
                    }
                } else {
                    self.setContactList(contactListModel: contactListModel.objects)
                    self.ringerInteractiveGetContactCheck()
                }
            } else {
                let responseDataDic = response as! [String :Any]
                print("\(responseDataDic["error"] ?? "")")
            }
        }
    }
    
    func ringerInteractiveGetContactCheck() {
        var localContactList = self.getContactList()
        for i in 0..<contactListModel.objects.count {
            let localContactData = localContactList?.filter {($0.contactId == contactListModel.objects[i].contactId) && ($0.modifiedAt < contactListModel.objects[i].modifiedAt)}
            if (localContactData?.count ?? 0) > 0 {
                let index = localContactList?.firstIndex(where: {$0.contactId == contactListModel.objects[i].contactId})
                if index != nil {
                    localContactList![Int(index!)] = localContactData!.first!
                    self.setContactList(contactListModel: localContactList)
                }
                if contactListModel.objects[i].galleryId != nil && contactListModel.objects[i].galleryId != "" {
                    self.group.enter()
                    self.ringerInteractiveGetContactImage(contactId: contactListModel.objects[i].galleryId, firstName: contactListModel.objects[i].firstName, lastName: contactListModel.objects[i].lastName, contactNumber: contactListModel.objects[i].phone[0], index: i)
                } else {
                    self.count += 1
                    if self.count == contactListModel.objects.count {
                        self.count = 0
                        self.saveAndUpdateContact(index: 0)
                    }
                }
            } else {
                self.count += 1
            }
        }
    }
    
    func ringerInteractiveGetContactImage(contactId : String,firstName: String, lastName: String, contactNumber : String, index: Int) {
        var header: [String : String] = [:]
        header["Authorization"] = GlobalFunction.getUserToken()
        
        let boundary = WebAPIManager().generateBoundary()
        
        let parameterString: String! = "\(contactId)/avatar?phone=\(contactNumber)&firstName=\(firstName)&lastName=\(lastName)&contactId=\(contactId)"
        let url: String = parameterString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""

        WebAPIManager.makeAPIRequest(method: "GET", isFormDataRequest: false, header: header, path: Constant.Api.getGalleryImage + "\(url)", isImageUpload: false, images: [], params: [:], boundary: boundary) { response, status in
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
    
    func addNewContact() {
        var contactList = self.getContactList()
        if (contactList?.count ?? 0) > 0 {
            let localContacts = contactList!.map{$0.contactId ?? ""}
            let apiContacts = contactListModel.objects.map{$0.contactId ?? ""}
            let set1:Set<String> = Set(localContacts)
            var set2:Set<String> = Set(apiContacts)
            set2.subtract(set1)
            let newContact = Array(set2)
            if newContact.count > 0 {
                for i in newContact {
                    let newContactModel = contactListModel.objects.filter {$0.contactId == i}
                    if newContactModel.count > 0 {
                        contactList?.append(newContactModel.first!)
                    }
                }
                self.setContactList(contactListModel: contactList)
                self.ringerInteractiveGetContactCheck()
            } else {
                self.ringerInteractiveGetContactCheck()
            }
        }
    }
    
    func setContactList(contactListModel: [ContactListObject]?) {
        if let contactModel = contactListModel {
            do {
                let archivedServerModules = try NSKeyedArchiver.archivedData(withRootObject: contactModel, requiringSecureCoding: false)
                UserDefaults.standard.set(archivedServerModules, forKey: "contactList")
                UserDefaults.standard.synchronize()
            }catch {
                
            }
        }
    }
    
    func getContactList() -> [ContactListObject]! {
        if GlobalFunction.isKeyPresentInUserDefaults(key: "contactList"){
            do {
                let data = UserDefaults.standard.data(forKey: "contactList")
                let decodedUserData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data!) as! [ContactListObject]
                return decodedUserData
            } catch {
                return []
            }
        } else {
            return []
        }
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}
