import UIKit
import Contacts
import ContactsUI


public class ContactSave {
    
    public init() {}
    
    public func requestAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            completionHandler(true)
        case .denied:
            self.showSettingsAlert(completionHandler)
        case .restricted, .notDetermined:
            CNContactStore().requestAccess(for: .contacts) { granted, error in
                if granted {
                    completionHandler(true)
                } else {
                    DispatchQueue.main.async {
                        self.showSettingsAlert(completionHandler)
                    }
                }
            }
        @unknown default:
            print("Default")
        }
    }
    
    func showSettingsAlert(_ completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: "This app requires access to Contacts to proceed. Go to Settings to grant access.", preferredStyle: .alert)
        if
            let settings = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(settings) {
                alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { action in
                    completionHandler(false)
                    UIApplication.shared.open(settings)
                })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
            completionHandler(false)
        })
        UIApplication.shared.windows.first?.rootViewController?.navigationController?.present(alert, animated: true)
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
    }
    
    func updateContact(name: String, findContact: String, updatedContact: String, imageData: Data) {
        let store = CNContactStore()
        OperationQueue().addOperation{[store] in
            let predicate = CNContact.predicateForContacts(matching: CNPhoneNumber(stringValue:"\(findContact)"))
            let toFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                           CNContactEmailAddressesKey,
                           CNContactPhoneNumbersKey,
                           CNContactImageDataAvailableKey,
                           CNContactThumbnailImageDataKey,CNContactViewController.descriptorForRequiredKeys()] as [Any]
            
            do{
                let contacts = try store.unifiedContacts(matching: predicate,
                                                         keysToFetch: toFetch as! [CNKeyDescriptor])
                if contacts.count > 0 {
                    for Contact in contacts{
                        let contactChange = Contact.mutableCopy() as! CNMutableContact
                        contactChange.givenName = "\(name)"
                        contactChange.phoneNumbers = [CNLabeledValue(
                            label:CNLabelPhoneNumberMobile,
                            value:CNPhoneNumber(stringValue:"\(updatedContact)"))]
                        if imageData != Data() {
                            contactChange.imageData = imageData
                        }
                        let req = CNSaveRequest()
                        req.update(contactChange)
                        try store.execute(req)
                    }
                } else {
                    let con = CNMutableContact()
                    con.givenName = "\(name)"
                    con.phoneNumbers = [CNLabeledValue(
                        label:CNLabelPhoneNumberMobile,
                        value:CNPhoneNumber(stringValue:"\(findContact)"))]
                    if imageData != Data() {
                        con.imageData = imageData
                    }
                    self.saveNewContact(con: con)
                }
            }
            catch let err{
                print(err)
            }
        }
    }
    
}
