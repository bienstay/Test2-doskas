//
//  Test2ViewController.swift
//  Test2
//
//  Created by maciulek on 05/07/2022.
//

import UIKit

class Test2ViewController: UIViewController {
    @IBOutlet weak var sView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sView.backgroundColor = .gray
        // To round the corners
        sView.layer.cornerRadius = 10
        sView.clipsToBounds = true
        // To provide the shadow
        sView.layer.shadowRadius = 10
        sView.layer.shadowOpacity = 1.0
        sView.layer.shadowOffset = CGSize(width: 3, height: 3)
        sView.layer.shadowColor = UIColor.black.cgColor
        sView.layer.masksToBounds = false
    }
}
