import UIKit

extension RingerInteractiveNotification {
    @available(iOS 10.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        _ = notification.request.content.userInfo
        completionHandler([.alert, .sound, .badge])
        ringerInteractiveDelegate?.userNotificationCenter(center, willPresent: notification)
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        _ = response.notification.request.content.userInfo
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notification"), object: nil, userInfo: [:])
        completionHandler()
        ringerInteractiveDelegate?.userNotificationCenter(center, didReceive: response)
    }
}
