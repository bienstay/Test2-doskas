//
//  SplashViewController.swift
//  Test2
//
//  Created by maciulek on 19/05/2021.
//

import UIKit

class SplashViewController: UIViewController {
    var dbProxyReady = false
    var notReadyCounter = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(dismissSplash), userInfo: nil, repeats: false)

        NotificationCenter.default.addObserver(self, selector: #selector(onDbProxyReady(_:)), name: .dbProxyReady, object: nil)

    }
    
    @objc func onDbProxyReady(_ notification: Notification) {
        dbProxyReady = true
    }

    @objc func dismissSplash() {

        if !dbProxyReady {
            notReadyCounter += 1
            Log.log(level: .ERROR, "No db connection (\(notReadyCounter))")
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(dismissSplash), userInfo: nil, repeats: false)
        }

        if UserDefaults.standard.bool(forKey: "resetBarcodeData") {
            UserDefaults.standard.removeObject(forKey: "barcodeData")
        }

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if !(UserDefaults.standard.string(forKey: "barcodeData")?.isEmpty ?? true) {
            appDelegate.initHotel()
            appDelegate.transitionToHome()
        } else {
            appDelegate.transitionToScanner()
        }
        
        return;

        DispatchQueue.main.async {
/*
            let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
            let mainViewController = mainStoryBoard.instantiateViewController(withIdentifier: "Scanner")
            //UIApplication.shared.keyWindow!.rootViewController = mainViewController
            
            let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            keyWindow?.rootViewController = mainViewController
*/
            if let window = UIApplication.shared.keyWindow {
                let roomNumber = UserDefaults.standard.integer(forKey: "roomNumber")
                print("roomNumber = \(roomNumber)")
                let nextScreen = (roomNumber > 0) ? "MainScreen" : "Scanner"
                let transition:UIView.AnimationOptions = (roomNumber > 0) ? .transitionFlipFromLeft : .transitionCrossDissolve
                let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: nextScreen)
                viewController.view.frame = window.bounds
                UIView.transition(with: window, duration: 1.0, options:                     transition, animations: {
                    window.rootViewController = viewController
                }, completion: nil)
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
