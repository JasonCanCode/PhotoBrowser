//
//  PagedContentViewController.swift
//  PhotoBrowserExample
//
//  Created by Jason Welch on 11/3/20.
//

import UIKit

protocol PageContainerDelegate: class {
    func switchedPage(to index: Int, isLastPage: Bool)
}

class PagedContentViewController: UIPageViewController {
    weak var containerDelegeate: PageContainerDelegate?
    var orderedViewControllers: [UIViewController] = [] {
        didSet {
            if let firstViewController = orderedViewControllers.first {
                setViewControllers(
                    [firstViewController],
                    direction: .forward,
                    animated: false,
                    completion: nil
                )
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        self.delegate = self
    }
}

// MARK: - Data source functions
extension PagedContentViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }

        let previousIndex = viewControllerIndex - 1

        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
            return nil
        }

        guard orderedViewControllers.count > previousIndex else {
            return nil
        }

        return orderedViewControllers[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }

        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count

        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }

        guard orderedViewControllersCount > nextIndex else {
            return nil
        }

        return orderedViewControllers[nextIndex]
    }

}
// MARK: - Delegate functions
extension PagedContentViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let pageContentViewController = pageViewController.viewControllers?.first,
              let pageIndex = orderedViewControllers.firstIndex(of: pageContentViewController) else {
            return
        }
        containerDelegeate?.switchedPage(to: pageIndex, isLastPage: pageIndex == orderedViewControllers.count - 1)
    }
}
