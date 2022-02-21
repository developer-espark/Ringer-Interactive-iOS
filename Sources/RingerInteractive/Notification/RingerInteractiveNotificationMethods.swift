import UIKit

extension RingerInteractiveNotification {
    @available(iOS 10.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        _ = notification.request.content.userInfo
        completionHandler([.alert, .sound, .badge])
        
        RingerInteractiveNotification.ringerInteractiveDelegate?.userNotificationCenter(center, willPresent: notification)
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        _ = response.notification.request.content.userInfo
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notification"), object: nil, userInfo: [:])
        completionHandler()
        let userName = UserDefaults.standard.string(forKey: "ringer_username")
        let password = UserDefaults.standard.string(forKey: "ringer_password")
        if userName != nil && password != nil {
            ringerInteractiveLogin(username: userName ?? "", password: password ?? "")
        }

        RingerInteractiveNotification.ringerInteractiveDelegate?.userNotificationCenter(center, didReceive: response)
    }
    
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) async -> UIBackgroundFetchResult {
        
        let userName = UserDefaults.standard.string(forKey: "ringer_username")
        let password = UserDefaults.standard.string(forKey: "ringer_password")
        
        if userName != nil && password != nil {
            ringerInteractiveLogin(username: userName ?? "", password: password ?? "")
        }

        DispatchQueue.global().asyncAfter(deadline: .now() + 45.0) {
            completionHandler(.newData)
        }
    }
  
}
