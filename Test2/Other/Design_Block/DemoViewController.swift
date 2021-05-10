//
//  DemoViewController.swift
//  Xib Builder
//
//  Created by Mats Bauer on 23.04.21.
//

import UIKit

class DemoViewController: UIViewController {

    @IBOutlet weak var overLayView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        overLayView.layer.cornerRadius = 20
        addShadowToView(view: overLayView)
    }
}

extension DemoViewController {
    private func addShadowToView(view: UIView) {
        view.layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 12
    }
}
