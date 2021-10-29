import UIKit
import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseMessaging


public protocol ringerInteractiveProtocol {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse)
    func tokenGenerate(token: String)
}

public class Notification: UIResponder, MessagingDelegate, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    public var ringerInteractiveDelegate : ringerInteractiveProtocol?
}

//MARK: Application Delegate
extension Notification {
    
    init() {}
    
    public func notificationRegister() {
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        registerForRemoteNotifications()
    }
    
    func registerForRemoteNotifications() {
        print("in registerForRemoteNotifications ")
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
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("in didReceiveRegistrationToken")
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
                self.ringerInteractiveDelegate?.tokenGenerate(token: token)
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("in didRegisterForRemoteNotificationsWithDeviceToken")
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("DeviceToken:-", token)
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Error in register : \(error)")
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable: Any], completionHandler: @escaping () -> Void) {
        print("Handle")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Receive notification")
        print(userInfo)
    }
}
