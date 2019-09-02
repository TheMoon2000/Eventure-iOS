//
//  CheckinPageController.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/31.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class CheckinPageController: UIPageViewController, UIPageViewControllerDataSource {
    
    private var event: Event!
    
    required init(event: Event!) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        
        self.event = event
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Checkin Overview"
        view.tintColor = MAIN_TINT
        
        navigationItem.rightBarButtonItem = .init(title: "Close", style: .done, target: self, action: #selector(closeCheckin))
        
        let overviewPage = CheckinOverview(event: event)
        setViewControllers([overviewPage], direction: .forward, animated: false, completion: nil)
    }
    
    @objc private func closeCheckin() {
        self.dismiss(animated: true)
    }
    
    
    // MARK: = Page controller data source
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return nil
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
}
