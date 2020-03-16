//
//  AutoHideNavBarController.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/3/12.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import UIKit

protocol FlowProgressReporting {
    var flowProgress: CGFloat { get }
}

class AutoHideNavBarController: UINavigationController, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        delegate = self
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        let actions = {
            self.navigationBar.alpha = (viewController as? FlowProgressReporting)?.flowProgress ?? 1.0
            if self.navigationBar.alpha == 1.0 {
                self.navigationBar.setBackgroundImage(nil, for: .default)
                self.navigationBar.shadowImage = nil
            } else {
                self.navigationBar.setBackgroundImage(UIImage(), for: .default)
                self.navigationBar.shadowImage = UIImage()
            }
        }
                
        transitionCoordinator?.animate(alongsideTransition: {_ in actions() }, completion: { context in
            guard context.isCancelled else { return }
            UIView.animate(withDuration: context.transitionDuration) {
                self.navigationBar.alpha = (self.topViewController as? FlowProgressReporting)?.flowProgress ?? 1.0
            }
        })
    }
    

}
