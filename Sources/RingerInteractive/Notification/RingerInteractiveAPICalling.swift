import UIKit
import AdSupport

extension RingerInteractiveNotification {
    
    public func ringerInteractiveLogin(username: String, password: String,CompanyName companyName : String? = "") {
        totalCount = 0
        UserDefaults.standard.set(companyName, forKey: Constant.localStorage.companyName)
        var header: [String : String] = [:]
        header["Content-Type"] = "application/json"
        
        var authDic = [String:Any]()
        authDic["username"] = username
        authDic["password"] = password
        
        let keychain = Keychain(service: "Ringer-Interactive-iOS")
        
        let token = keychain["Ringer-UUID"]
        
        if token == nil {
            let keychain = Keychain(service: "Ringer-Interactive-iOS")
            keychain["Ringer-UUID"] = UIDevice.current.identifierForVendor?.uuidString ?? .none
        }
        
        UserDefaults.standard.set(username, forKey: "ringer_username")
        UserDefaults.standard.set(password, forKey: "ringer_password")
        UserDefaults.standard.synchronize()
        
        let boundary = WebAPIManager().generateBoundary()
        
        WebAPIManager.makeAPIRequest(method: "GET", isFormDataRequest: false, header: header, path: Constant.Api.token_with_authorities, isImageUpload: false, images: [], auth: true, authDic: authDic, params: [:], boundary: boundary) { response, status in
            if status == 200 || status == 201  {
                let responseDataDic = response as! [String :Any]
                if responseDataDic["token"] != nil && responseDataDic["location"] != nil {
                    UserDefaults.standard.set("\(responseDataDic["token"] ?? "")", forKey: Constant.localStorage.token)
                    UserDefaults.standard.set("\(responseDataDic["location"] ?? "")", forKey: Constant.localStorage.baseUrl)
                    
//                    self.ringerInteractiveDeviceRegistartion()
                    
                    self.ringerInteractiveSearchMobileRegister(username: username, password: password) { status in
                        
                        if status == 1 {
                            
                        } else if status == 0 {
                            
                        }
                    }
                }
            } else {
                let responseDataDic = response as! [String :Any]
                print("\(responseDataDic["error"] ?? "")")
            }
        }
    }
    
    public func ringerInteractiveSearchMobileRegister(username: String, password: String, completion: @escaping (_ status: Int) -> Void) {
        
        let keychain = Keychain(service: "Ringer-Interactive-iOS")
        var header: [String : String] = [:]
        header["Content-Type"] = "application/json"
        header["Authorization"] = GlobalFunction.getUserToken()
        
        var authDic = [String:Any]()
        authDic["username"] = username
        authDic["password"] = password
        
        let boundary = WebAPIManager().generateBoundary()
        let uuid = try? keychain.getString("Ringer-UUID")
        
        WebAPIManager.makeAPIRequest(method: "GET", isFormDataRequest: false, header: header, path: "\(Constant.Api.registerMobile)?uuid=\(uuid ?? "")", isImageUpload: false, images: [], params: [: ], boundary: boundary) { response, status in
            if status == 200  {
                
                let responseDataDic = response as! [String :Any]
                let total = responseDataDic["total"] as? Int
                let object = responseDataDic["objects"] as? NSArray
                let mobileDic = object?[0] as? [String: Any]
                let mobileID = mobileDic["mobileregistrationId"] as? String
                completion(total ?? 0)
            } else {
                let responseDataDic = response as! [String :Any]
                print("\(responseDataDic["error"] ?? "")")
            }
        }
        
    }
    
    func ringerInteractiveDeviceRegistartion() {
        let keychain = Keychain(service: "Ringer-Interactive-iOS")
        var header: [String : String] = [:]
        header["Content-Type"] = "application/json"
        header["Authorization"] = GlobalFunction.getUserToken()
        
        var param : [String : Any] = [:]
        param["firebaseToken"] = firebaseToken
        param["os"] = "ios"
        param["uuid"] = try? keychain.getString("Ringer-UUID")
//        param["uuid"] = UIDevice.current.identifierForVendor?.uuidString ?? .none
        
        let boundary = WebAPIManager().generateBoundary()
        WebAPIManager.makeAPIRequest(method: "POST", isFormDataRequest: false, header: header, path: Constant.Api.registerMobile, isImageUpload: false, images: [], params: param, boundary: boundary) { response, status in
            if status == 200 || status == 201 || status == 409 {
                self.ringerInteractiveGetContact()
            }
        }
    }
    
    public func ringerInteractiveGetContact() {
        
        var header: [String : String] = [:]
        header["Content-Type"] = "application/json"
        header["Authorization"] = GlobalFunction.getUserToken()
        
        let boundary = WebAPIManager().generateBoundary()
        WebAPIManager.makeAPIRequest(method: "GET", isFormDataRequest: false, header: header, path: Constant.Api.getContact, isImageUpload: false, images: [], params: [:], boundary: boundary) { response, status in
            if status == 200 || status == 201 {
                let responseDataDic = response as! [String :Any]
                contactListModel = ContactListModel(fromDictionary: responseDataDic)
                var contactList = GlobalFunction.getContactList()
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
                        GlobalFunction.setContactList(contactListModel: contactList)
                        self.ringerInteractiveGetContactCheck()
                    } else {
                        self.ringerInteractiveGetContactCheck()
                    }
                } else {
                    self.ringerInteractiveGetContactCheck()
                }
            } else {
                let responseDataDic = response as! [String :Any]
                print("\(responseDataDic["error"] ?? "")")
            }
        }
    }
    
    func ringerInteractiveGetContactCheck() {
        var localContactList = GlobalFunction.getContactList()
        if (localContactList?.count ?? 0) > 0 {
            for i in 0..<contactListModel.objects.count {
                localContactList = GlobalFunction.getContactList()
                let localContactData = localContactList?.filter {$0.contactId == contactListModel.objects[i].contactId}
                if (localContactData?.count ?? 0) > 0 {
                    let localContactModify = localContactList?.filter {($0.contactId == contactListModel.objects[i].contactId) && ($0.modifiedAt < contactListModel.objects[i].modifiedAt)}
                    if (localContactModify?.count ?? 0) > 0 {
                        let index = localContactList?.firstIndex(where: {$0.contactId == contactListModel.objects[i].contactId})
                        if index != nil {
                            localContactList![Int(index!)] = contactListModel.objects[i]
                            GlobalFunction.setContactList(contactListModel: localContactList)
                        }
                        if contactListModel.objects[i].galleryId != nil && contactListModel.objects[i].galleryId != "" {
                            self.group.enter()
                            self.ringerInteractiveGetContactImage(contactId: contactListModel.objects[i].galleryId, firstName: contactListModel.objects[i].firstName, lastName: contactListModel.objects[i].lastName, contactNumber: contactListModel.objects[i].phone[0], index: i, statusContact: false)
                        } else {
                            self.count += 1
                            self.saveAndUpdateContact(index: i, statusContact: false)
//                            if self.count == contactListModel.objects.count {
//                                self.count = 0
//                                self.saveAndUpdateContact(index: 0)
//                            }
                        }
                    } else {
                        self.count += 1
//                        if self.count == contactListModel.objects.count - 1 {
//                            self.completeContactTask()
//                            self.completionFinishTask?()
//                        }
                    }
                } else {
                    self.addNewContact(newContact: contactListModel.objects[i])
                    if contactListModel.objects[i].galleryId != nil && contactListModel.objects[i].galleryId != "" {
                        self.group.enter()
                        self.ringerInteractiveGetContactImage(contactId: contactListModel.objects[i].galleryId, firstName: contactListModel.objects[i].firstName, lastName: contactListModel.objects[i].lastName, contactNumber: contactListModel.objects[i].phone[0], index: i, statusContact: false)
                    } else {
                        self.count += 1
                        self.saveAndUpdateContact(index: i, statusContact: false)
//                        if self.count == contactListModel.objects.count {
//                            self.count = 0
//                            self.saveAndUpdateContact(index: 0)
//                        }
                    }
                }
                if i == contactListModel.objects.count - 1 {
                    self.completeContactTask()
                    self.completionFinishTask?()
                }
            }
        } else {
            for i in 0..<contactListModel.objects.count {
                if contactListModel.objects[i].galleryId != nil && contactListModel.objects[i].galleryId != "" {
                    self.group.enter()
                    self.ringerInteractiveGetContactImage(contactId: contactListModel.objects[i].galleryId, firstName: contactListModel.objects[i].firstName, lastName: contactListModel.objects[i].lastName, contactNumber: contactListModel.objects[i].phone[0], index: i, statusContact: true)
                } else {
                    self.count += 1
                    if self.count == contactListModel.objects.count {
                        self.count = 0
                        self.saveAndUpdateContact(index: 0, statusContact: true)
                    }
                    
                }
            }
        }
    }
    func ringerInteractiveGetContactImage(contactId : String,firstName: String, lastName: String, contactNumber : String, index: Int, statusContact: Bool) {
        var header: [String : String] = [:]
        header["Authorization"] = GlobalFunction.getUserToken()
        
        let boundary = WebAPIManager().generateBoundary()
        
        let parameterString: String! = "\(contactId)/avatar?phone=\(contactNumber)&firstName=\(firstName)&lastName=\(lastName)&contactId=\(contactId)"
        let url: String = parameterString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
        
        WebAPIManager.makeAPIRequest(method: "GET", isFormDataRequest: false, header: header, path: Constant.Api.getGalleryImage + "\(url)", isImageUpload: false, images: [], params: [:], boundary: boundary) { response, status in
            self.group.leave()
            if status == 200 || status == 201 {
                self.count += 1
                if index < contactListModel.objects.count {
                    contactListModel.objects[index].imageUrl = "\(response["imgUrl"]!)"
                }
                if statusContact {
                    if self.count == contactListModel.objects.count {
                        self.count = 0
                        self.saveAndUpdateContact(index: 0, statusContact: statusContact)
                    }
                } else {
                    self.saveAndUpdateContact(index: index, statusContact: statusContact)
                }
            } else {
                self.count += 1
                contactListModel.objects[index].imageUrl = ""
                if statusContact {
                    if self.count == contactListModel.objects.count {
                        self.count = 0
                        self.saveAndUpdateContact(index: 0, statusContact: statusContact)
                    }
                } else {
                    self.saveAndUpdateContact(index: index, statusContact: statusContact)
                }
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
    
    public func saveAndUpdateContact(index:Int, statusContact:Bool) {
        if index < contactListModel.objects.count {
            for contacts in contactListModel.objects[index].phone {
                self.group.enter()
                ContactSave().downloadImageAndContactSave(name: contactListModel.objects[index].firstName + "^" + contactListModel.objects[index].lastName, number: contactListModel.objects[index].phone, editNumber: contacts, imageUrl: contactListModel.objects[index].imageUrl, statusContact: statusContact)
                self.addNewContact(newContact: contactListModel.objects[index])
            }
            if index == contactListModel.objects.count - 1 {
                self.completeContactTask()
//                self.ringerInteractiveDelegate?.completionFinishTask()
                self.completionFinishTask?()
            }
        }
    }
    
    func addNewContact(newContact : ContactListObject) {
        var contactList = GlobalFunction.getContactList()
        if (contactList?.count ?? 0) > 0 {
            let localContactData = contactList?.filter {$0.contactId == newContact.contactId}
            if (localContactData?.count ?? 0) == 0 {
                contactList?.append(newContact)
                GlobalFunction.setContactList(contactListModel: contactList)
            }
        } else {
            contactList?.append(newContact)
            GlobalFunction.setContactList(contactListModel: contactList)
        }
    }
    
}
