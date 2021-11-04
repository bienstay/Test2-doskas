//
//  WalkthroughViewController.swift
//  FoodPin
//
//  Created by maciulek on 09/04/2021.
//

import UIKit

class MenuMainViewController: UIViewController {

    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var closeButton: UIButton!
    @IBAction func pageControlPressed(_ sender: UIPageControl) {
        //menuPageViewController?.currentMenuIndex = sender.currentPage
        menuPageViewController?.forwardPage()   // TODO - fix this
        updateUI()
    }
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    var menuPageViewController: MenuPageViewController?
    var restaurant = Restaurant()

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        if let pageCount = menuPageViewController?.nrOfPages {
            pageControl.numberOfPages = pageCount
        }

        closeButton.backgroundColor = .clear
        if navigationController != nil { closeButton.isHidden = true }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = restaurant.name

        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.hidesBarsOnSwipe = true
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = .black
}

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if let pageViewController = destination as? MenuPageViewController {
            menuPageViewController = pageViewController
            menuPageViewController?.restaurant = restaurant
        }
    }

    func updateUI() {

        if let index = self.menuPageViewController?.currentMenuIndex {
            self.pageControl.currentPage = index
        }
    }
}
