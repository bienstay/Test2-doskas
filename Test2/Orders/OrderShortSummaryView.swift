//
//  OrderShortSummaryView.swift
//  Test2
//
//  Created by maciulek on 13/05/2021.
//

import UIKit
/*
class OrderShortSummaryView: UIView {
    let nibName = "OrderShortSummary"
    @IBOutlet var view : UIView!

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var itemsLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var proceedButton: UIButton!
    var proceedClosure: (() -> Void)?
    @IBAction func proceedButtonPressed(_ sender: UIButton) {
        if let pC = proceedClosure { pC() }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
        //view.backgroundColor = .pastelGray
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 5
        view.layer.borderColor = UIColor.lightGray.cgColor
        quantityLabel.textColor = .orange
        proceedButton.tintColor = .orange
    }

    func xibSetup() {
        view = loadViewFromNib()
        view.frame = self.bounds
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
         addSubview(view)
     }

     func loadViewFromNib() -> UIView {
         let bundle = Bundle(for: type(of: self))
         let nib = UINib(nibName: nibName, bundle: bundle)
         return nib.instantiate(withOwner: self, options: nil).first as! UIView
     }
}
*/
