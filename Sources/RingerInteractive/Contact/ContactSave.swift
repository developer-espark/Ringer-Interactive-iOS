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
    
    func updateContact(name: String, findContact: [String], imageData: Data, statusContact: Bool) {
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
                for contacts in findContact {
                    var numbers = ""
                    if let number = phoneNumber.value as? CNPhoneNumber,
                       let _ = phoneNumber.label {
                        numbers = number.stringValue.replacingOccurrences(of: "[(\\) \\-\\\\]", with: "", options: .regularExpression, range: nil)
                    }
                    if phoneNumber.label == "_$!<Mobile>!$_" && numbers == contacts {
                        updateContact = true
                    }
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
                for contacts in findContact {
                    if numberData == contacts {
                        numberIsMobile = true
                        break
                    } else {
                        numberIsMobile = false
                    }
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
                    for contacts in findContact {
                        let nameArray = name.components(separatedBy: "^")
                        if nameArray.count > 1 {
                            contactChange.givenName = "\(nameArray[0])"
                            contactChange.familyName = "\(nameArray[1])"
                        } else {
                            contactChange.givenName = "\(nameArray[0])"
                        }
//                        contactChange.phoneNumbers.firstIndex(of: CNLabeledValue(
//                            label:CNLabelPhoneNumberMobile,
//                            value:CNPhoneNumber(stringValue:"\(contacts)")))
                        
                        if updateNumberCheck || updateContact {
                                contactChange.phoneNumbers.remove(at: numberIndex)
                        }
                        
                        contactChange.phoneNumbers.insert(CNLabeledValue(
                            label:CNLabelPhoneNumberMobile,
                            value:CNPhoneNumber(stringValue:"\(contacts)")), at: numberIndex)
                        
                    }
                    
                    if !imageData.isEmpty {
                        self.groups.enter()
//                        contactChange.imageData = imageData
                        let uiImage = UIImage(data: imageData) ?? UIImage()
                        let bigImage = uiImage.scalePreservingAspectRatio(targetSize: CGSize(width: 2208, height: 2208))
                        if let imgData:Data = bigImage.pngData() as Data? { contactChange.imageData = imgData }
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
//            con.givenName = "\(name)"
            
            let nameArray = name.components(separatedBy: "^")
            if nameArray.count > 1 {
                con.givenName = "\(nameArray[0])"
                con.familyName = "\(nameArray[1])"
            } else {
                con.givenName = "\(nameArray[0])"
            }
            
            for contacts in findContact {
                con.phoneNumbers.append(CNLabeledValue(
                    label:CNLabelPhoneNumberMobile,
                    value:CNPhoneNumber(stringValue:"\(contacts)")))
            }
//            con.phoneNumbers = [CNLabeledValue(
//                label:CNLabelPhoneNumberMobile,
//                value:CNPhoneNumber(stringValue:"\(findContact)"))]
            con.organizationName = ((UserDefaults.standard.value(forKey: Constant.localStorage.companyName) as? String) ?? "")
            if imageData != Data() {
                let uiImage = UIImage(data: imageData) ?? UIImage()
                
                let bigImage = uiImage.scalePreservingAspectRatio(targetSize: CGSize(width: 2208, height: 2208))
                
                if let imgData:Data = bigImage.pngData() as Data? { con.imageData = imgData }
                
//                con.imageData = imageData
            }
            self.saveNewContact(con: con, statusContact: statusContact)
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
//extension UIImage {
//    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
//        // Determine the scale factor that preserves aspect ratio
//        let widthRatio = targetSize.width / size.width
//        let heightRatio = targetSize.height / size.height
//
//        let scaleFactor = min(widthRatio, heightRatio)
//
//        // Compute the new image size that preserves aspect ratio
//        let scaledImageSize = CGSize(
//          width: size.width * scaleFactor,
//          height: size.height * scaleFactor
//        )
//
//        // Draw and return the resized UIImage
//        let renderer = UIGraphicsImageRenderer(
//          size: scaledImageSize
//        )
//
//        let scaledImage = renderer.image { _ in
//            self.draw(in: CGRect(
//              origin: .zero,
//              size: scaledImageSize
//            ))
//        }
//
//        return scaledImage
//    }
//}

extension UIImage {

    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        let size = self.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}
