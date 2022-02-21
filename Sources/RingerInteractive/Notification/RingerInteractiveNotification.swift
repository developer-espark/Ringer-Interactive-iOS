import UIKit
import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseMessaging

var totalCount = 0
var contactListModel = ContactListModel(fromDictionary: [:])
var firebaseToken = ""

public protocol ringerInteractiveDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse)
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    func tokenGenerate(token: String)
    func completionFinishTask()
}

public class RingerInteractiveNotification: UIResponder, MessagingDelegate, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    static public var ringerInteractiveDelegate : ringerInteractiveDelegate?
    public var completionFinishTask : (()->())?
    public override init() {}
    
    let group = DispatchGroup()
    var count = 0
    
    
    
}

//MARK: Application Delegate
extension RingerInteractiveNotification {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) {
        print("SDK willPresent")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) {
        print("SDK didReceive")
    }
    
    public func notificationRegister() {
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        registerForRemoteNotifications()
        let contact = ContactSave()
        contact.requestAccess()
    }
    
    func registerForRemoteNotifications() {
        Messaging.messaging().delegate = self
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        Messaging.messaging().token { token, error in
            if let error = error {
                print(error)
            } else if let token = token {
                firebaseToken = token
                RingerInteractiveNotification.ringerInteractiveDelegate?.tokenGenerate(token: token)
            }
        }
    }
    
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        _ = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        Messaging.messaging().apnsToken = deviceToken
    }
    
    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    }
    
    public func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable: Any], completionHandler: @escaping () -> Void) {
    }
    
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    }
    
    public func completeContactTask() {
        RingerInteractiveNotification.ringerInteractiveDelegate?.completionFinishTask()
        
    }
    
}


