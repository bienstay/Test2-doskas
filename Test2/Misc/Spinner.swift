//
//  Spinner.swift
//  Test2
//
//  Created by maciulek on 18/04/2022.
//

import UIKit

class SpinnerViewController: UIViewController {
    var spinner = UIActivityIndicatorView(style: .whiteLarge)

    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.2)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func start(vc: UIViewController) {
        self.view.frame = UIScreen.main.bounds
        spinner.startAnimating()
        vc.present(self, animated: true)
        //self.modalPresentationStyle = .fullScreen
/*
        vc.addChild(self)
        self.view.frame = vc.view.frame
        //self.view.frame = UIScreen.main.bounds
        vc.view.addSubview(self.view)
        self.didMove(toParent: vc)
        vc.navigationController?.setNavigationBarHidden(true, animated: true)
*/
    }
    
    func stop(vc: UIViewController) {
        spinner.stopAnimating()
        self.dismiss(animated: true)
/*
        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
        vc.navigationController?.setNavigationBarHidden(false, animated: true)
*/
    }
}
