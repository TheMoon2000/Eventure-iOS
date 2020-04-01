//
//  DiningHallIconNavController.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/4/1.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import UIKit

class DiningHallIconNavController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        transitioningDelegate = self
        navigationBar.customize()
        navigationBar.tintColor = AppColors.control
    }
    

}

// MARK - Animations.
// Details: https://developer.apple.com/library/archive/featuredarticles/ViewControllerPGforiPhoneOS/CustomizingtheTransitionAnimations.html
    
extension DiningHallIconNavController {
    
    class PresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
        
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return 0.25
        }
        
        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            let container = transitionContext.containerView
            let toView = transitionContext.view(forKey: .to)!
            
            let finalFrame = transitionContext.finalFrame(for: transitionContext.viewController(forKey: .to)!)
            
            
            let mask = CAShapeLayer()
            mask.frame = finalFrame
            mask.path = UIBezierPath(arcCenter: CGPoint(x: finalFrame.maxX - 40, y: 20), radius: 0, startAngle: 0, endAngle: 2 * .pi, clockwise: true).cgPath
            
            toView.layer.mask = mask
            toView.layer.masksToBounds = true
            toView.layer.opacity = 0.9
            
            container.addSubview(toView)
            
            
            let animation = CABasicAnimation(keyPath: "path")
            animation.fromValue = mask.path
            animation.duration = 0.25
            let newPath = UIBezierPath(arcCenter: CGPoint(x: finalFrame.maxX - 40, y: 20),
                                       radius: sqrt(pow(finalFrame.width, 2) + pow(finalFrame.height, 2)),
                                       startAngle: 0,
                                       endAngle: 2 * .pi,
                                       clockwise: true).cgPath
            animation.toValue = newPath
            
            animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            mask.add(animation, forKey: nil)
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            mask.path = UIBezierPath(rect: finalFrame).cgPath
            CATransaction.commit()
            
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear, animations: {
                toView.layer.opacity = 1.0
            }, completion: { _ in
                toView.layer.mask = nil
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
                        
            fromView.layer.opacity = 1.0
            fromView.endEditing(true)
            
            let mask = CAShapeLayer()
            mask.frame = fromView.frame
            mask.path = UIBezierPath(
                arcCenter: CGPoint(x: container.frame.maxX - 40, y: 20),
                radius: sqrt(pow(container.frame.width, 2) + pow(container.frame.height, 2)),
                startAngle: 0,
                endAngle: 2 * .pi,
                clockwise: true
            ).cgPath
            
            fromView.layer.mask = mask
            fromView.layer.masksToBounds = true
                        
            let animation = CABasicAnimation(keyPath: "path")
            animation.fromValue = mask.path
            animation.duration = 0.25
            let newPath = UIBezierPath(arcCenter: CGPoint(x: container.frame.maxX - 40, y: 20), radius: 0, startAngle: 0, endAngle: 2 * .pi, clockwise: true).cgPath
            animation.toValue = newPath
            
            animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            mask.add(animation, forKey: nil)
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            mask.path = newPath
            CATransaction.commit()
            
            container.addSubview(fromView)
            
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
                fromView.layer.opacity = 0.5
            }, completion: { _ in
                transitionContext.completeTransition(true)
            })
        }
    }
    
}

extension DiningHallIconNavController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentAnimator()
        
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
}
