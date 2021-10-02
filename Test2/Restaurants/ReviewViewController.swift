//
//  ReviewViewController.swift
//  FoodPin
//
//  Created by maciulek on 03/04/2021.
//

import UIKit

class ReviewViewController: UIViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet var rateButtons: [UIButton]!
    var restaurant: Restaurant?

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()

        //backgroundImageView.image = UIImage(data: restaurant!.image)  // TODO

        // Applying the blur effect
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        backgroundImageView.addSubview(blurEffectView)

        let moveRightTransform = CGAffineTransform.init(translationX: 600, y: 0)
        let scaleUpTransform = CGAffineTransform.init(scaleX: 5.0, y: 5.0)
        let moveScaleTransform = scaleUpTransform.concatenating(moveRightTransform)

        // Make the button invisible
        for rateButton in rateButtons {
            rateButton.transform = moveScaleTransform
            rateButton.alpha = 0
        }

//        let moveUpTransform = CGAffineTransform.init(translationX: 0, y: -600)
        //closeButton.transform = moveUpTransform
    }

    override func viewWillAppear(_ animated: Bool) {
        for index: Int in 0...4 {
            let delay: Double = Double(0.1) + Double(index) * Double(0.05)
            UIView.animate(withDuration: 0.4, delay: delay, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.3, options: [], animations: {
                self.rateButtons[index].alpha = 1.0
                self.rateButtons[index].transform = .identity
            }, completion: nil)
        }
    }

}
