//
//  ViewController.swift
//  Xib Builder
//
//  Created by Mats Bauer on 13.04.21.
//  © 2021 Mats Bauer Software some rights reserved.
//
//  It is not allowed to redistribute or sell this file or its contents
//  You can make modifications to this file
//  Attribution is not required, with a valid purchase receipt
//

import UIKit

/*
 * This is an example controller to show how the Design Block is integrated
 * and used. Please integrate the Design Block into your application
 */

/*
class ViewController: UIViewController {
    
    //keep the reference of the view controller, to control later
    private var blockViewController: DemoViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        blockViewController = DemoViewController(nibName: "DemoViewController", bundle: nil)
        
        //make sure to put this over full screen, to allow the transparency
        blockViewController?.modalPresentationStyle = .overFullScreen
        blockViewController?.modalTransitionStyle = .crossDissolve
        
        self.present(blockViewController!, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}
*/
