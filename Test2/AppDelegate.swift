//
//  AppDelegate.swift
//  Bibzzy
//
//  Created by maciulek on 25/04/2021.
//

import UIKit
import CoreData
import Firebase
import FirebaseMessaging

var dbProxy: DBProxy!

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //hotel.id = "RitzKohSamui"
        //guest.id = "AnitaMaciek"
        //hotel.initialize()

        print(UserDefaults.standard.dictionaryRepresentation())
        
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.error)
        FireB.shared.initialize()
        dbProxy = FireB.shared

        UNUserNotificationCenter.current().delegate = self
        // ask user for permission to receive notification
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted { Log.log(level: .INFO, "User notifications allowed") }
            else { Log.log("User notifications not allowed, error: " + error.debugDescription) }
        }
        // always register for notifications, user can change permission outside the app, in system settings
        UIApplication.shared.registerForRemoteNotifications()

        // setup firebase messaging delegate
        Messaging.messaging().delegate = self

        Auth.auth().signInAnonymously() { (authResult, error) in
            if let error = error { Log.log(level: .ERROR, "\(error)") }
            else {
                Log.log(level: .INFO, "Signed in with user: " + authResult!.user.uid)
                NotificationCenter.default.post(name: .dbProxyReady, object: nil)
//                guest.updateGuestDataInDB()
//                guest.startObserving()
//                hotel.startObserving()
            }
        }

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
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        Log.log(level: .INFO, "FCM Registration Token: " + (fcmToken ?? "empty token"))
        Messaging.messaging().subscribe(toTopic: "tescikTopic") { error in
            if let e = error { print(e.localizedDescription) }
            else { print("Subscribed to weather topic") }
        }
    }
}


extension AppDelegate {
    
    func initHotel() {
        hotel.initialize()

        let barcodeDataFromDefaults = UserDefaults.standard.string(forKey: "barcodeData")
        guard   let barcodeData = barcodeDataFromDefaults,
                let params = convertJSONStringToDictionary(text: barcodeData),
                let hotelId = params["hotelId"] as? String,
                let roomNumber = params["roomNumber"] as? Int,
                let guestId = params["guestId"] as? String
        else {
            Log.log(level: .ERROR, "Invalid barcode data: \(barcodeDataFromDefaults ?? "barcodeData missing")")
            return
        }

        hotel.id = hotelId
        guest.id = guestId
        guest.updateGuestDataInDB()
        guest.startObserving()
        hotel.startObserving()
    }

    func transitionToHome() {
        
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

    func transitionToScanner() {
        DispatchQueue.main.async {
            if let window = UIApplication.shared.keyWindow {
                let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Scanner")
                viewController.view.frame = window.bounds
                UIView.transition(with: window, duration: 1.0, options:                     .transitionCurlUp, animations: {
                    window.rootViewController = viewController
                }, completion: nil)
            }
        }
    }
}
