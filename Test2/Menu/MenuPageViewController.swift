//
//  MenuPageViewController.swift
//  Test2
//
//  Created by maciulek on 16/05/2021.
//

import UIKit

class MenuPageViewController: UIPageViewController {

    var currentMenuIndex = 0
    var nrOfPages = 1
    var restaurant = Restaurant()

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()

        dataSource = self
        delegate = self

        if let startingViewController = contentViewController(at: 0) {
            setViewControllers([startingViewController], direction: .forward, animated: true, completion: nil)
            nrOfPages = restaurant.menus.count
            //startingViewController.restaurant = restaurant
        }
    }
}

extension MenuPageViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! MenuViewController).menuIndex
        index -= 1
        return contentViewController(at: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! MenuViewController).menuIndex
        index += 1
        return contentViewController(at: index)
    }

    func contentViewController(at index: Int) -> MenuViewController? {
        if index < 0 || index >= nrOfPages { return nil }
        // Create a new view controller and pass suitable data.
        let storyboard = UIStoryboard(name: "Menu", bundle: nil)
        if let pageContentViewController = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as? MenuViewController {
            pageContentViewController.menuIndex = index
            pageContentViewController.restaurant = restaurant
            return pageContentViewController
        }
        return nil
    }

    func forwardPage() {
        currentMenuIndex += 1
        if let nextViewController = contentViewController(at: currentMenuIndex) {
            setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
        }
    }
}


extension MenuPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let contentViewController = pageViewController.viewControllers?.first as? MenuViewController {
                currentMenuIndex = contentViewController.menuIndex
                (parent as! MenuMainViewController).updateUI()
            }
        }
    }
}

