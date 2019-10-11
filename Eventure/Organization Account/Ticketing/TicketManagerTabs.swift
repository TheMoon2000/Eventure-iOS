//
//  TicketManagerTabs.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/19.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class TicketManagerTabs: ButtonBarPagerTabStripViewController {

    var parentVC: TicketManagerMain!
    
    required init(parentVC: TicketManagerMain) {
        super.init(nibName: nil, bundle: nil)
        
        self.parentVC = parentVC
    }
    
    override func viewDidLoad() {
        settings.style.buttonBarBackgroundColor = AppColors.navbar
        settings.style.buttonBarItemBackgroundColor = AppColors.navbar
        settings.style.selectedBarBackgroundColor = AppColors.main
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 15)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarItemLeftRightMargin = 15
        settings.style.buttonBarItemTitleColor = AppColors.main
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = AppColors.label
            newCell?.label.textColor = AppColors.main
        }
        
        super.viewDidLoad()
        
        containerView.isScrollEnabled = false
    }
    

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        let buyers = TicketPurchases(parentVC: parentVC)
        let requests = TicketRequests(parentVC: parentVC)
        let issued = IssuedTickets(parentVC: parentVC)
        
        return [buyers, requests, issued]
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
