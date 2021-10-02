//
//  OnboardingContentViewController.swift
//  Test2
//
//  Created by maciulek on 05/07/2021.
//

import UIKit

class OnboardingContentViewController: UIViewController {

    @IBOutlet var contentImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var pageControl: UIPageControl!
    @IBAction func nextPressed(_ sender: Any) {
        pageVC?.forwardPage()
    }

    var pageVC:OnboardingPageViewController?
    var index: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        tap.numberOfTapsRequired = 3
        view.addGestureRecognizer(tap)
    }

    func setupView() {
        pageControl.currentPage = index
        titleLabel.textColor = .white
        textLabel.textColor = .white
        switch index {
        case 0:
            view.backgroundColor = .color1
            contentImageView.image = UIImage(named: "OnboardingInfo")
            titleLabel.text = "INFO"
            textLabel.text = "Get all the latest news and information about the hotel"
        case 1:
            view.backgroundColor = .color2
            contentImageView.image = UIImage(named: "OnboardingRestaurant")
            titleLabel.text = "RESTAURANT"
            textLabel.text = "Check the menus and order from the room service"
        case 2:
            view.backgroundColor = .color3
            contentImageView.image = UIImage(named: "OnboardingOrders")
            titleLabel.text = "ORDER"
            textLabel.text = "Contact the staff if you need anything"
        default:
            break
        }
    }

    @objc func didTap(sender: UITapGestureRecognizer) {
        print("handleTap")
        ConfigViewController.showPopup(parentVC: self)
    }
}

