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
    
    //Download data from url
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    //Checking image data
    public func downloadImageAndContactSave(name: String, number: [String], editNumber: String = "", imageUrl: String = "", statusContact: Bool) {
        if imageUrl != "" {
            self.getData(from: URL(string: imageUrl)!) { data, response, error in
                guard let data = data, error == nil else { return }
                self.updateContact(name: name, findContact: number, imageData: data, statusContact: statusContact)
            }
        } else {
            self.updateContact(name: name, findContact: number, imageData: Data(), statusContact: statusContact)
        }
    }
    
    //add new contact io contacts
    func saveNewContact(con: CNMutableContact, statusContact:Bool) {
        let store = CNContactStore()
        let saveRequest = CNSaveRequest()
        saveRequest.add(con, toContainerWithIdentifier:nil)
        do  {
            try store.execute(saveRequest)
        } catch {
            
        }
        totalCount += 1
        if statusContact {
            RingerInteractiveNotification().saveAndUpdateContact(index: totalCount, statusContact: statusContact)
        } else {
            totalCount = 0
        }
    }
    
    //Update Contact in contact
    func updateContact(name: String, findContact: [String], imageData: Data, statusContact: Bool) {
        var numberCheck = true // number is available or not in contacts
        var numberIsMobile = false // number is available in contacts but checking it is mobile or not
        let contactData = self.getContacts() // mobile contacts
        
        for con in contactData {
            self.groups.enter()
            var numberIndex = -1 // checking position of number in contacts
            var numberData = "" // remove white space and other symbols from api contacts
            var updateNumberCheck = true // number is available but not in mobile field
            var updateContact = false // update number or not
            
            for phoneNumber in con.phoneNumbers {
                for contacts in findContact {
                    var numbers = ""
                    if let number = phoneNumber.value as? CNPhoneNumber,
//                       let _ = phoneNumber.label {
                        numbers = number.stringValue.replacingOccurrences(of: "[(\\) \\-\\\\]", with: "", options: .regularExpression, range: nil)
//                    }
                    if phoneNumber.label == "_$!<Main>!$_" && GlobalFunction.removeCountryCode(from: numbers) == GlobalFunction.removeCountryCode(from: contacts) {
                        updateContact = true
                        numberIndex += 1
                    }
                }
            }
            
            for phoneNumber in con.phoneNumbers {
                if let number = phoneNumber.value as? CNPhoneNumber,
                   let _ = phoneNumber.label {
                    numberData = number.stringValue.replacingOccurrences(of: "[(\\) \\-\\\\]", with: "", options: .regularExpression, range: nil)
                }
                
                if phoneNumber.label != "_$!<Main>!$_" {
                    numberIndex += 1
                    updateNumberCheck = false
                }
                for contacts in findContact {
                    if GlobalFunction.removeCountryCode(from: numberData) == GlobalFunction.removeCountryCode(from: contacts) {
                        numberIsMobile = true
                        break
                    } else {
                        numberIsMobile = false
                    }
                }
                if numberIsMobile {
                    break
                }
            }
            
            if numberIsMobile {
                self.groups.enter()
                let store = CNContactStore()
                numberCheck = false
                totalCount += 1
                
                OperationQueue().addOperation{[self, store] in
                    let contactChange = con.mutableCopy() as! CNMutableContact
                    contactChange.organizationName = ((UserDefaults.standard.value(forKey: Constant.localStorage.companyName) as? String) ?? "")
                    if contactChange.phoneNumbers.count > 1 || findContact.count > 1 {
                        contactChange.phoneNumbers.removeAll()
                    }
                    for i in 0..<findContact.count {
                        let nameArray = name.components(separatedBy: "^")
                        if nameArray.count > 1 {
                            contactChange.givenName = "\(nameArray[0])"
                            contactChange.familyName = "\(nameArray[1])"
                        } else {
                            contactChange.givenName = "\(nameArray[0])"
                        }
                        
                        if contactChange.phoneNumbers.count > 1 || findContact.count > 1 {
                            contactChange.phoneNumbers.insert(CNLabeledValue(
                                label:CNLabelPhoneNumberMain,
                                value:CNPhoneNumber(stringValue:"\(findContact[i])")), at: i)
                        } else {
                            if updateNumberCheck || updateContact {
                                if contactChange.phoneNumbers.count > numberIndex {
                                    contactChange.phoneNumbers.remove(at: numberIndex)
                                    contactChange.phoneNumbers.insert(CNLabeledValue(
                                        label:CNLabelPhoneNumberMain,
                                        value:CNPhoneNumber(stringValue:"\(findContact[i])")), at: numberIndex)
                                } else {
                                    contactChange.phoneNumbers.insert(CNLabeledValue(
                                        label:CNLabelPhoneNumberMain,
                                        value:CNPhoneNumber(stringValue:"\(findContact[i])")), at: i)
                                }
                            }
                        }
                    }
                    
                    if !imageData.isEmpty {
                        self.groups.enter()
                        contactChange.imageData = nil
                        let saveRequest = CNSaveRequest()
                        saveRequest.update(contactChange)
                        do  {
                            try store.execute(saveRequest)
                        } catch {
                            print("error")
                        }
                        let uiImage = UIImage(data: imageData) ?? UIImage()
                        let bigImage = uiImage.scalePreservingAspectRatio(targetSize: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
                        if let imgData:Data = bigImage.pngData() as Data? {
                            contactChange.imageData = imgData
                        }
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
                    if statusContact {
                        RingerInteractiveNotification().saveAndUpdateContact(index: totalCount, statusContact: statusContact)
                    } else {
                        totalCount = 0
                    }
                }
            }
        }
        
        if numberCheck {
            let con = CNMutableContact()
            let nameArray = name.components(separatedBy: "^")
            if nameArray.count > 1 {
                con.givenName = "\(nameArray[0])"
                con.familyName = "\(nameArray[1])"
            } else {
                con.givenName = "\(nameArray[0])"
            }
            for contacts in findContact {
                con.phoneNumbers.append(CNLabeledValue(
                    label:CNLabelPhoneNumberMain,
                    value:CNPhoneNumber(stringValue:"\(contacts)")))
            }
            con.organizationName = ((UserDefaults.standard.value(forKey: Constant.localStorage.companyName) as? String) ?? "")
            if imageData != Data() {
                let uiImage = UIImage(data: imageData) ?? UIImage()
                let bigImage = uiImage.scalePreservingAspectRatio(targetSize: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
                if let imgData:Data = bigImage.pngData() as Data? {
                    con.imageData = imgData
                }
            }
            self.saveNewContact(con: con, statusContact: statusContact)
        }
    }
    
    //MARK: Contacts get from device
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

//MARK: UIImage extension for proper size of image
extension UIImage {
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )
        
        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )
        
        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        
        return scaledImage
    }
}
