//
//  SplashViewController.swift
//  Test2
//
//  Created by maciulek on 19/05/2021.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(dismissSplash), userInfo: nil, repeats: false)
        //dismissSplash()

    }
    
    @objc func dismissSplash() {

        //loadRestaurantsImagesFromBundle()
        //initMenusFromBundleFiles()

        hotel.roomService.name = "In room dining"

        DispatchQueue.main.async {
            let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
            let mainViewController = mainStoryBoard.instantiateViewController(withIdentifier: "MainScreen")
            //UIApplication.shared.keyWindow!.rootViewController = mainViewController
            let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            keyWindow?.rootViewController = mainViewController

            //self.performSegue(withIdentifier: "SplashToMain", sender:nil);
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
