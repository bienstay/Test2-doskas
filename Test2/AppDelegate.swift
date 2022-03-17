//
//  AppDelegate.swift
//  Bibzzy
//
//  Created by maciulek on 25/04/2021.
//

import UIKit
import CoreData
import Firebase

var dbProxy: DBProxy!

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //hotel.name = "Sheraton Full Moon"
        //hotel.id = "SheratonFullMoon"
        //guest.id = "MacsMaciulek"
        hotel.id = "RitzKohSamui"
        guest.id = "AnitaMaciek"
        hotel.initialize()

        initDestinationDining()
        initInfoItems() // TODO remove

        registerForPushNotifications()
        // Check if launched from notification
        let notificationOption = launchOptions?[.remoteNotification]
        if let notification = notificationOption as? [String: AnyObject], let aps = notification["aps"] as? [String: AnyObject] {
            Log.log(level: .INFO, "App launched from a notification: \(aps)")
            //(window?.rootViewController as? UITabBarController)?.selectedIndex = 1
        }

        FirebaseApp.configure()
        //FirebaseConfiguration.shared.setLoggerLevel(.max)
        FirebaseConfiguration.shared.setLoggerLevel(.error)
        FireB.shared.initialize()
        dbProxy = FireB.shared

        Auth.auth().signInAnonymously() { (authResult, error) in
            if let error = error { Log.log(level: .ERROR, "\(error)") }
            else {
                Log.log(level: .INFO, "Signed in with user: " + authResult!.user.uid)
                guest.updateGuestDataInDB()
                guest.startObserving()
                hotel.startObserving()
            }
        }

        UITabBarItem.appearance().setTitleTextAttributes(
            [NSAttributedString.Key.font: UIFont(name: "Verdana", size: 12)!],
            for: .normal)

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        Log.log(level: .INFO, "url: \(url.absoluteURL)")
        Log.log(level: .INFO, "scheme: \(String(describing: url.scheme))")
        Log.log(level: .INFO, "host: \(String(describing: url.host))")
        Log.log(level: .INFO, "path: \(url.path)")
        Log.log(level: .INFO, "components: \(url.pathComponents)")
        
        let message = url.host?.removingPercentEncoding
        pushMenuScreen(restaurantName: message!)
        return true
    }
    
    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

/*
    //lazy var persistentContainer: NSPersistentCloudKitContainer = {
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        //let container = NSPersistentCloudKitContainer(name: "Bibzzy")
        let container = NSPersistentContainer(name: "Test2")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
*/
}

extension AppDelegate {

    func getTopmostViewController() -> UIViewController? {
        if #available(iOS 13, *) { return getTopVC13() }
        else { return getTopVCOld() }
    }

    func getTopVC13() -> UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            // topController should now be your topmost view controller
            return topController
        }
        return nil
    }

    func getTopVCOld() -> UIViewController? {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            // topController should now be your topmost view controller
            return topController
        }
        return nil
    }


    func pushMenuScreen(restaurantName: String) {
        guard let restaurant = hotel.restaurants.first(where: {$0.name == restaurantName} ) else {
            Log.log("Restaurant " + restaurantName + " not found")
            return
        }
        let storyboard = UIStoryboard(name: "Menu", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MenuMainViewController") as! MenuMainViewController
        vc.restaurant = restaurant
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let topVC = appDelegate.getTopmostViewController()
        topVC!.present(vc, animated: true, completion: nil)
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {

    // TODO note: add Push notifications and Background Modes, remote notification, in Signing & Capabilities
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        Log.log(level: .DEBUG, notification.request.content.debugDescription)
        //let userInfo = notification.request.content.userInfo
        completionHandler([.alert, .sound, .badge])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        Log.log(level: .DEBUG, response.debugDescription)
        
        UIApplication.shared.applicationIconBadgeNumber = 0 // TODO this should be cleared by addressing the specific notification
        // TODO - instead of showing a dialog box, show a badge on a tabbar for Orders
/*
        let userInfo = response.notification.request.content.userInfo
        // Extract custom parameter value from notification message
        if let orderNumber = userInfo["orderNumber"] as? Int, response.notification.request.identifier == "Test2.orderChanged" {
            Log.log(level: .INFO, "Message sent with room \(orderNumber)")
            if let topVC = getTopmostViewController() {
                showInfoDialogBox(vc: topVC, title: "Order update", message: String("Order \(orderNumber) has been updated. Please check the order details"))
                // TODO this should be moved to willPresent if notification happens with app in foreground, so that we do not show the notification but the dialog instead
            }
        }
 */
        completionHandler()
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        Log.log(level: .INFO, "!!!!!!!!!!! in didReceiveRemoteNotification, this should only be called for silent notifications")
        guard let aps = userInfo["aps"] as? [String: AnyObject] else {
            completionHandler(.failed)
            return
        }
        Log.log(level: .INFO, "Received remote notification: \(aps)")
    }

    func registerForPushNotifications() {

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted {
                Log.log(level: .INFO, "User notifications are allowed.")
            } else {
                Log.log("User notifications are not allowed.")
            }

            UNUserNotificationCenter.current().delegate = self
        }

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            Log.log(level: .INFO, "Notification ermission granted: \(granted)")
            if let error = error { Log.log(level: .ERROR, "\(error)") }
            guard granted else { return }
            self?.getNotificationSettings()
          }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            Log.log(level: .INFO, "Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        Log.log(level: .INFO, "Device Token: \(token)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Log.log("Failed to register: \(error)")
    }
}

