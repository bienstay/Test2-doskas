//
//  AppDelegate.swift
//  Bibzzy
//
//  Created by maciulek on 25/04/2021.
//

import UIKit
import CoreData

var dbProxy: DBProxy!
var authProxy: AuthProxy!
var storageProxy: StorageProxy!
var messagingProxy: MessagingProxy!

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var useEmulator: Bool = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // clean all defaults
        if UserDefaults.standard.bool(forKey: "resetDefaults"), let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
            UserDefaults.standard.synchronize()
        }

        useEmulator = UserDefaults.standard.bool(forKey: "useEmulator")
        if !UIDevice.current.isSimulator { useEmulator = false }
        // store just in case this was overriden by a parameter
        UserDefaults.standard.set(useEmulator, forKey: "useEmulator")

        Firebase.shared.initialize(useEmulator: useEmulator)
        dbProxy = FirebaseDatabase.shared
        authProxy = FirebaseAuthentication.shared
        storageProxy = FirebaseStorage.shared
        messagingProxy = FirebaseMessaging.shared

        Log.log("Server is in \(useEmulator ? "EMULATOR" : "CLOUD")")

        FirebaseDatabase.shared.observeInfo()   // TODO move it somewhere

        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted { Log.log(level: .INFO, "User notifications allowed") }
            else { Log.log("User notifications NOT allowed, error: " + error.debugDescription) }
        }
        // always register for notifications, user can change permission outside the app, in system settings
        UIApplication.shared.registerForRemoteNotifications()

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

        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        Log.log(level: .INFO, "In userNotificationCenter willPresent")
        Log.log(level: .INFO, notification.request.content.userInfo.debugDescription)
        completionHandler([.alert, .sound, .badge])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        Log.log(level: .INFO, "In userNotificationCenter didReceive")
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
        messagingProxy.initialize(deviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Log.log(level: .ERROR, "Failed to register: \(error)")
    }
}



extension AppDelegate {
    func initFromBarcode() {

        guard let barcodeString = UserDefaults.standard.string(forKey: "barcodeData") else {
            Log.log(level: .INFO, "Barcode data missing")
            return
        }
        guard let barcodeData: BarcodeData = parseJSON(barcodeString) else {
            Log.log(level: .ERROR, "Invalid barcode json: \(barcodeString)")
            return
        }
        guard barcodeData.isValid() else {
            Log.log(level: .ERROR, "Invalid barcode: \(barcodeString)")
            return
        }

        hotel.id = barcodeData.hotelId
        Log.log(level: .INFO, "Barcode from UserDefaults: \(barcodeData)")

        if let username = barcodeData.userName, let password = barcodeData.password {
            phoneUser.user = User(name: username, password: password)
        } else if let roomNumber = barcodeData.roomNumber, let startDate = barcodeData.startDate {
            phoneUser.guest = Guest(roomNumber: roomNumber, startDate: startDate, guestName: barcodeData.guestName)
        }
    }

    func transitionToHome() {
        authProxy.login(username: phoneUser.email, password: phoneUser.password) { (authData, error) in
            if let authData = authData {
                Log.log("Logged in with \(authData)")
                if let user = phoneUser.user {
                    user.displayName = authData.displayName
                    user.role = authData.role
                }
                NotificationCenter.default.post(name: .dbProxyReady, object: nil)

                hotel.initialize()
                hotel.startObserving()
                phoneUser.startObserving()
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

extension UIDevice {
    var isSimulator: Bool {
#if targetEnvironment(simulator)
        Log.log("Running in SIMULATOR")
        return true
#else
        Log.log("Running on REAL DEVICE")
        return false
#endif
    }
}
