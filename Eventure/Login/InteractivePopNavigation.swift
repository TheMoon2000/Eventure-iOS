/* Source: https://www.pixeldock.com/blog/enable-the-swipe-back-gesture-aka-interactive-pop-gesture-when-using-a-uinavigationcontroller-with-custom-back-button/
 This subclass of UINavigationController enables the swipe back gesture.
 */

import UIKit

class InteractivePopNavigationController: UINavigationController {
    
    // 1
    var isPushingViewController = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 3
        delegate = self
        // 5
        interactivePopGestureRecognizer?.delegate = self
    }
    
    // 2
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        isPushingViewController = true
        super.pushViewController(viewController, animated: animated)
    }
}

// 6
extension InteractivePopNavigationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer is UIScreenEdgePanGestureRecognizer else {
            return true
        }
        return viewControllers.count > 1 && !isPushingViewController
    }
}

// 4
extension InteractivePopNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        isPushingViewController = false
    }
}
