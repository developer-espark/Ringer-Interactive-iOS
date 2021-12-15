import UIKit
import Contacts
import ContactsUI


public class ContactSave {
    
    public init() {}
    var groups = DispatchGroup()
    
    public func requestAccess() {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            print("Authorized")
        case .denied:
            self.showSettingsAlert()
        case .restricted, .notDetermined:
            CNContactStore().requestAccess(for: .contacts) { granted, error in
                if granted {
                    print("Authorized")
                } else {
                    DispatchQueue.main.async {
                        self.showSettingsAlert()
                    }
                }
            }
        @unknown default:
            print("Default")
        }
    }
    
    func showSettingsAlert() {
        let alert = UIAlertController(title: nil, message: "This app requires access to Contacts to proceed. Go to Settings to grant access.", preferredStyle: .alert)
        if
            let settings = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(settings) {
            alert.addAction(UIAlertAction(title: "Settings", style: .default) { action in
                UIApplication.shared.open(settings)
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
        })
        let topWindow: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
        topWindow?.rootViewController = UIViewController()
        topWindow?.windowLevel = UIWindow.Level.alert + 1
        topWindow?.makeKeyAndVisible()
        topWindow?.rootViewController?.present(alert, animated: true)
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    public func downloadImageAndContactSave(name: String, number: String, editNumber: String = "", imageUrl: String = "") {
        if imageUrl != "" {
            self.getData(from: URL(string: imageUrl)!) { data, response, error in
                guard let data = data, error == nil else { return }
                self.updateContact(name: name, findContact: number, updatedContact: editNumber, imageData: data)
            }
        } else {
            self.updateContact(name: name, findContact: number, updatedContact: editNumber, imageData: Data())
        }
    }
    
    func saveNewContact(con: CNMutableContact) {
        let store = CNContactStore()
        let saveRequest = CNSaveRequest()
        saveRequest.add(con, toContainerWithIdentifier:nil)
        try! store.execute(saveRequest)
        totalCount += 1
        RingerInteractiveNotification().saveAndUpdateContact(index: totalCount)
    }
    
    //    func updateContact(name: String, findContact: String, updatedContact: String, imageData: Data) {
    //        let store = CNContactStore()
    //        OperationQueue().addOperation{[store] in
    //            let predicate = CNContact.predicateForContacts(matching: CNPhoneNumber(stringValue:"\(findContact)"))
    //            let toFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
    //                           CNContactEmailAddressesKey,
    //                           CNContactPhoneNumbersKey,
    //                           CNContactImageDataAvailableKey,
    //                           CNContactThumbnailImageDataKey,CNContactViewController.descriptorForRequiredKeys()] as [Any]
    //
    //            do{
    //                let contacts = try store.unifiedContacts(matching: predicate,
    //                                                         keysToFetch: toFetch as! [CNKeyDescriptor])
    //                if contacts.count > 0 {
    //                    for Contact in contacts{
    //                        let contactChange = Contact.mutableCopy() as! CNMutableContact
    //                        contactChange.givenName = "\(name)"
    //                        contactChange.phoneNumbers = [CNLabeledValue(
    //                            label:CNLabelPhoneNumberMobile,
    //                            value:CNPhoneNumber(stringValue:"\(updatedContact)"))]
    //                        if imageData != Data() {
    //                            contactChange.imageData = imageData
    //                        }
    //                        let req = CNSaveRequest()
    //                        req.update(contactChange)
    //                        try store.execute(req)
    //                    }
    //                } else {
    //                    let con = CNMutableContact()
    //                    con.givenName = "\(name)"
    //                    con.phoneNumbers = [CNLabeledValue(
    //                        label:CNLabelPhoneNumberMobile,
    //                        value:CNPhoneNumber(stringValue:"\(findContact)"))]
    //                    if imageData != Data() {
    //                        con.imageData = imageData
    //                    }
    //                    self.saveNewContact(con: con)
    //                }
    //            }
    //            catch let err{
    //                print(err)
    //            }
    //        }
    //    }
    
    func updateContact(name: String, findContact: String, updatedContact: String, imageData: Data) {
        var numberCheck = true
        var numberIsMobile = false
        let contactData = self.getContacts()
        
        for con in contactData {
            self.groups.enter()
            var numberIndex = -1
            var numberData = ""
            var updateNumberCheck = true
            var updateContact = false
            
            for phoneNumber in con.phoneNumbers {
                var numbers = ""
                if let number = phoneNumber.value as? CNPhoneNumber,
                   let _ = phoneNumber.label {
                    numbers = number.stringValue.replacingOccurrences(of: "[(\\) \\-\\\\]", with: "", options: .regularExpression, range: nil)
                }
                if phoneNumber.label == "_$!<Mobile>!$_" && numbers == findContact {
                    updateContact = true
                }
            }
            
            for phoneNumber in con.phoneNumbers {
                if let number = phoneNumber.value as? CNPhoneNumber,
                   let _ = phoneNumber.label {
                    numberData = number.stringValue.replacingOccurrences(of: "[(\\) \\-\\\\]", with: "", options: .regularExpression, range: nil)
                    numberIndex += 1
                }
                
                if phoneNumber.label != "_$!<Mobile>!$_" {
                    numberIndex += 1
                    updateNumberCheck = false
                }
                
                if numberData == findContact {
                    numberIsMobile = true
                    break
                } else {
                    numberIsMobile = false
                }
            }
            
            if numberIsMobile {
                self.groups.enter()
                let store = CNContactStore()
                numberCheck = false
                totalCount += 1
                
                OperationQueue().addOperation{[self, store] in
                    
                    let contactChange = con.mutableCopy() as! CNMutableContact
                    if contactChange.organizationName != ((UserDefaults.standard.value(forKey: Constant.localStorage.companyName) as? String) ?? "") {
                        let phoneNumberValue = CNPhoneNumber(stringValue: updatedContact)
                        contactChange.givenName = "\(name)"
                        contactChange.phoneNumbers.firstIndex(of: CNLabeledValue(
                            label:CNLabelPhoneNumberMobile,
                            value:CNPhoneNumber(stringValue:"\(updatedContact)")))
                        
                        if updateNumberCheck || updateContact {
                            contactChange.phoneNumbers.remove(at: numberIndex)
                        }
                        contactChange.phoneNumbers.insert(CNLabeledValue(
                            label:CNLabelPhoneNumberMobile,
                            value:CNPhoneNumber(stringValue:"\(updatedContact)")), at: numberIndex)
                    }
                    if !imageData.isEmpty {
                        self.groups.enter()
                        contactChange.imageData = imageData
                        self.groups.leave()
                    }
                    self.groups.leave()
                    self.groups.enter()
                    let saveRequest = CNSaveRequest()
                    saveRequest.update(contactChange)
                    
                    do  {
                        try store.execute(saveRequest)
                    } catch {
                        print("error")
                    }
                    self.groups.leave()
                    RingerInteractiveNotification().saveAndUpdateContact(index: totalCount)
                }
            }
        }
        
        if numberCheck {
            let con = CNMutableContact()
            con.givenName = "\(name)"
            con.phoneNumbers = [CNLabeledValue(
                label:CNLabelPhoneNumberMobile,
                value:CNPhoneNumber(stringValue:"\(findContact)"))]
            con.organizationName = ((UserDefaults.standard.value(forKey: Constant.localStorage.companyName) as? String) ?? "")
            if imageData != Data() {
                con.imageData = imageData
            }
            self.saveNewContact(con: con)
        }
    }
    
    func getContacts() -> [CNContact] {
        
        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey,
            CNContactImageDataAvailableKey,
            CNContactThumbnailImageDataKey,
            CNContactViewController.descriptorForRequiredKeys()] as [Any]
        
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        
        var results: [CNContact] = []
        
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                results.append(contentsOf: containerResults)
            } catch {
                print("Error fetching containers")
            }
        }
        return results
    }
}
