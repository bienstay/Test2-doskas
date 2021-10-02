//
//  OnboardingPageViewController.swift
//  Test2
//
//  Created by maciulek on 05/07/2021.
//

import UIKit

class OnboardingPageViewController: UIPageViewController {

    let nrOfPages = 3
    var pages = [OnboardingContentViewController]()

    // storyboard transition style is not working so override init
    override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]?) {

       // Here i changed the transition style: UIPageViewControllerTransitionStyle.Scroll
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: options)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self

        for i in 0...nrOfPages-1 {
            pages.append(createContentViewController(i))
        }

        if let firstPage = pages.first {
            setViewControllers([firstPage], direction: .forward, animated: true, completion: nil)
        }

    }

    func createContentViewController(_ index: Int) -> OnboardingContentViewController {
        let contentViewController = UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewController(withIdentifier: "ContentViewController") as! OnboardingContentViewController
        contentViewController.index = index
        contentViewController.pageVC = self
        return contentViewController
    }

    func forwardPage() {
        dismiss(animated: true)
/*
        if let currentVC = self.viewControllers?.first {
            guard let currentIndex = pages.firstIndex(of: currentVC as! OnboardingContentViewController) else { return }
            let nextIndex = currentIndex + 1
            guard nextIndex < pages.count else { return }
            setViewControllers([pages[nextIndex]], direction: .forward, animated: true, completion: nil)
        }
 */
    }
}

extension OnboardingPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController as! OnboardingContentViewController) else { return nil }
        let previousIndex = currentIndex - 1
        //guard previousIndex >= 0 else { return pages.last }
        guard previousIndex >= 0 else { return nil }
        guard previousIndex < pages.count else { return nil }
        return pages[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController as! OnboardingContentViewController) else { return nil }
        let nextIndex = currentIndex + 1
        //guard nextIndex < pages.count else { return pages.first }
        guard nextIndex < pages.count else { return nil }
        guard nextIndex < pages.count else { return nil }
        return pages[nextIndex]
    }
}

