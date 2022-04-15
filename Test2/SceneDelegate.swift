//
//  SceneDelegate.swift
//  Bibzzy
//
//  Created by maciulek on 25/04/2021.
//

import UIKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        Log.log("in willConnectTo")
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        Log.log("in didConnect")
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        Log.log("in didBecomeActive")
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        Log.log("in willResignActive")
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        Log.log("in willEnterForeground")
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        Log.log("in didEnterBackground")
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        //(UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        Log.log("in openURLContexts")
        for context in URLContexts {
            Log.log(level: .INFO, "url: \(context.url.absoluteURL)")
            Log.log(level: .INFO, "scheme: \(String(describing: context.url.scheme))")
            Log.log(level: .INFO, "host: \(String(describing: context.url.host))")
            Log.log(level: .INFO, "path: \(context.url.path)")
            Log.log(level: .INFO, "components: \(context.url.pathComponents)")
        }
/*
        if let host = URLContexts.first?.url.host {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.pushMenuScreen(restaurantName: host)
        }
        else {
            Log.log("Invalid scheme")
        }
*/
    }
/*
    func pushMenuScreen(restaurantName: String) {
        let storyboard = UIStoryboard(name: "Menu", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MenuMainViewController") as! MenuMainViewController
        guard let restaurant = hotel.facilities[.Restaurant]![restaurantName] as? Restaurant else {
            Log.log("Restaurant " + restaurantName + " not found")
            return
        }
        vc.restaurant = restaurant
        //let topVC = getTopmostViewController()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let topVC = appDelegate.getTopmostViewController()
        topVC!.present(vc, animated: true, completion: nil)
    }

    func getTopmostViewController() -> UIViewController? {
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
*/
}

