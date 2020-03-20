//
//  EventSearchNavController.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/3/19.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import UIKit

class EventSearchNavController: UINavigationController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        transitioningDelegate = self
    }

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
        transitioningDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


}


// MARK - Animations.
// Details: https://developer.apple.com/library/archive/featuredarticles/ViewControllerPGforiPhoneOS/CustomizingtheTransitionAnimations.html
    
extension EventSearchNavController {
    
    class PresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
        
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return 0.35
        }
        
        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            let container = transitionContext.containerView
            let toView = transitionContext.view(forKey: .to)!
            
            let finalFrame = transitionContext.finalFrame(for: transitionContext.viewController(forKey: .to)!)
            
            toView.clipsToBounds = true
            toView.layer.cornerRadius = 30
            toView.transform = CGAffineTransform(scaleX: 1.0, y: 0.82)
            toView.frame.origin = .zero
            toView.frame.size.height = finalFrame.height * 0.8
            toView.layer.opacity = 0.2
            
            container.addSubview(toView)
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                toView.layer.cornerRadius = 0
                toView.transform = .identity
                toView.frame.origin = .zero
                toView.frame.size.height = finalFrame.height
                toView.layer.opacity = 1.0
            }, completion: { _ in
                transitionContext.completeTransition(true)
            })
        }
    }
    
    class DismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
        
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return 0.35
        }
        
        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            let container = transitionContext.containerView
            let fromView = transitionContext.view(forKey: .from)!
                        
            fromView.layer.cornerRadius = 0
            fromView.layer.opacity = 1.0
            fromView.endEditing(true)
//            (transitionContext.viewController(forKey: .from) as? EventSearchView)?.emptyLabel.isHidden = true
            
            container.addSubview(fromView)
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                fromView.layer.cornerRadius = 30
                fromView.transform = CGAffineTransform(scaleX: 1.0, y: 0.85)
                fromView.frame.origin = .zero
                fromView.layer.opacity = 0.0
            }, completion: { _ in
                transitionContext.completeTransition(true)
            })
        }
    }
    
}

extension EventSearchNavController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentAnimator()
        
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
}
