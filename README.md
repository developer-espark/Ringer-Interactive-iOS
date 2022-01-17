<h1 align="center">Ringer</h1>

<p align="center">
Ringer is a swift package to save and update contact along with notification and provide Information of device like os version of device, device name, and timezone in device.
</p>

### Here is the instruction how to use the sdk 

## Step 1
Go to the [Releases](https://github.com/developer-espark/Ringer-Interactive-iOS) to get latest package
Add the package using swift package manager in to your project.

## Step 2
Firebase is required so if there is already an existing firebase pod in the project than uninstall it.

## Step 3
Add delegate (`ringerInteractiveDelegate`) into file for access notification.

## Step 4
Configure firebase using FirebaseApp.configure()
Add GoogleService-Info.plist file downloaded from firebase configuration.

## Step 5
Create object of RingerInteractiveNotification.
```
	let ringerObject = RingerInteractiveNotification()
```
Register notification by using RingerInteractiveNotification object name.
```
	ringerObject.notificationRegister()
```
Add delegate to self.
```
	ringerObject.ringerInteractiveDelegate = self
```
## Step 6
Add contact usage description in Info.plist using give lines as below  :-
```	
	<key>NSContactsUsageDescription</key>
	<string>Our application needs to your contacts</string>
```

## Step 7
Login into sdk by using RingerInteractiveNotification object like given as below  :-
```
	ringerObject.ringerInteractiveLogin(username: “”, password: “”, CompanyName: “”)
```
> Note :- CompanyName is optional.**
## Step 8
Add these methods into AppDelegate to save and update contact through the notification.
```
	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) {
		ringerObject.ringerInteractiveLogin(username: "", password: "")
	}
    
	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) {
		ringerObject.ringerInteractiveLogin(username: "", password: "")
	}
    
	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any],fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		ringerObject.ringerInteractiveLogin(username: "", password: "")
		completionHandler(.newData)
	}
```

> Note :- iOS version above 13 is required to use this sdk.**