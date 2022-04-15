//
//  AppDelegate.swift
//  Bibzzy
//
//  Created by maciulek on 25/04/2021.
//

import UIKit
import CoreData
//import Firebase
import FirebaseMessaging

var dbProxy: DBProxy!
var authProxy: AuthProxy!
var storageProxy: StorageProxy!

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        Firebase.shared.initialize(useEmulator: true)
        dbProxy = FirebaseDatabase.shared
        authProxy = FirebaseAuthentication.shared
        storageProxy = FirebaseStorage.shared
        Messaging.messaging().delegate = self   // todo

        Log.log("STARTING... launchOptions: \(launchOptions ?? [:])")

        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted { Log.log(level: .INFO, "User notifications allowed") }
            else { Log.log("User notifications not allowed, error: " + error.debugDescription) }
        }
        // always register for notifications, user can change permission outside the app, in system settings
        UIApplication.shared.registerForRemoteNotifications()


        //var email = "appuser@appviator.com"
        //if let hId = hotel.id { email = "appuser@\(hId).appviator.com" }
        //Auth.auth().signIn(withEmail: email, password: "Appviator2022!") { (authResult, error) in
/*
        Auth.auth().signInAnonymously() { (authResult, error) in
            if let error = error { Log.log(level: .ERROR, "\(error)") }
            else {
                Log.log(level: .INFO, "Signed in with user: " + authResult!.user.uid)
                NotificationCenter.default.post(name: .dbProxyReady, object: nil)
            }
        }
*/

        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Verdana", size: 14)!], for: .normal)

        // Check if launched from notification
        if let notificationOption = launchOptions?[.remoteNotification] {
            if let notification = notificationOption as? [String: AnyObject], let aps = notification["aps"] as? [String: AnyObject] {
                Log.log(level: .INFO, "App launched from a notification: \(aps)")
                //(window?.rootViewController as? UITabBarController)?.selectedIndex = 1
            }
        }

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("in open url")
        Log.log(level: .INFO, "url: \(url.absoluteURL)")
        Log.log(level: .INFO, "scheme: \(String(describing: url.scheme))")
        Log.log(level: .INFO, "host: \(String(describing: url.host))")
        Log.log(level: .INFO, "path: \(url.path)")
        Log.log(level: .INFO, "components: \(url.pathComponents)")
        
        //let message = url.host?.removingPercentEncoding
        //pushMenuScreen(restaurantName: message!)
        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        Log.log(level: .INFO, "In userNotificationCenter willPresent")
        //Log.log(level: .INFO, notification.request.content.description)
        //Log.log(level: .INFO, notification.request.content.debugDescription)
        Log.log(level: .INFO, notification.request.content.userInfo.debugDescription)
        completionHandler([.alert, .sound, .badge])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        Log.log(level: .INFO, "In userNotificationCenter didReceive")
        //Log.log(level: .INFO, response.notification.request.content.description)
        //Log.log(level: .INFO, response.debugDescription)
        Log.log(level: .INFO, response.notification.request.content.userInfo.debugDescription)

        completionHandler()
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        Log.log(level: .INFO, "in didReceiveRemoteNotification")
        guard let aps = userInfo["aps"] as? [String: AnyObject] else {
            completionHandler(.failed)
            return
        }
        Log.log(level: .INFO, "Received remote notification: \(aps)")
        completionHandler(.newData)
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        Log.log(level: .INFO, "Device APN Token: \(token)")
        // setup firebase messaging
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Log.log(level: .ERROR, "Failed to register: \(error)")
    }
}


extension AppDelegate: MessagingDelegate {
    var genericTopic: String { hotel.id ?? "" }
    var roomTopic: String { (hotel.id ?? "") + "_" + String(guest.roomNumber) }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        Log.log(level: .INFO, "FCM Registration Token: " + (fcmToken ?? "empty token"))
    }

    func subscribeForMessages() {
        Messaging.messaging().subscribe(toTopic: genericTopic) { error in
            if let e = error { Log.log(level: .ERROR, e.localizedDescription) }
            else { Log.log(level: .INFO, "Subscribed to topic \(self.genericTopic)") }
        }
        Messaging.messaging().subscribe(toTopic: roomTopic) { error in
            if let e = error { Log.log(level: .ERROR, e.localizedDescription) }
            else { Log.log(level: .INFO, "Subscribed to topic \(self.roomTopic) ") }
        }
    }
}


extension AppDelegate {
    func initFromBarcode() {

        guard let barcodeString = UserDefaults.standard.string(forKey: "barcodeData") else {
            Log.log(level: .INFO, "Barcode data missing")
            return
        }
        guard let b: BarcodeData = parseJSON(barcodeString) else {
            Log.log(level: .ERROR, "Invalid barcode: \(barcodeString)")
            return
        }

        hotel.id = b.hotelId
        Log.log(level: .INFO, "Barcode from UserDefaults: \(b)")
        
        if b.roomNumber == 0 {
            guest.roomNumber = 0
            guest.id = "user"
            guest.Name = b.userName!
            guest.password = b.password
        } else {
            guest.id = Guest.formatGuestId(roomNumber: b.roomNumber, startDate: b.startDate ?? Date())
            guest.roomNumber = b.roomNumber
            guest.password = "Appviator2022!"
        }
    }

    func transitionToHome() {
        authProxy.login(username: guest.email, password: guest.password ?? "invalid") { (authData, error) in
            if authData != nil {
                NotificationCenter.default.post(name: .dbProxyReady, object: nil)

                hotel.initialize()
                hotel.startObserving()
                guest.startObserving()
                DispatchQueue.main.async {
                    if let window = UIApplication.shared.keyWindow {
                        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainScreen")
                        viewController.view.frame = window.bounds
                        UIView.transition(with: window, duration: 1.0, options: .transitionFlipFromLeft, animations: {
                            window.rootViewController = viewController
                        }, completion: nil)
                    }
                }
            }
        }

/*
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainScreen") as! UITabBarController
        UIApplication.shared.windows.first?.rootViewController = viewController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
 */
    }

    func transitionToScanner() {
        DispatchQueue.main.async {
            if let window = UIApplication.shared.keyWindow {
                let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Scanner")
                viewController.view.frame = window.bounds
                UIView.transition(with: window, duration: 1.0, options:                     .transitionCrossDissolve, animations: {
                    window.rootViewController = viewController
                }, completion: nil)
            }
        }
    }
}
