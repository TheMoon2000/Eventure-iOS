//
//  TicketTabView.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/16.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class TicketTabView: ButtonBarPagerTabStripViewController {
    
    override func viewDidLoad() {
        settings.style.buttonBarBackgroundColor = AppColors.navbar
        settings.style.buttonBarItemBackgroundColor = AppColors.navbar
        settings.style.selectedBarBackgroundColor = AppColors.main
        settings.style.buttonBarItemFont = .appFontSemibold(15)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarItemLeftRightMargin = 18
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
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        let all = TicketsList()
        all.title = "All Tickets"
        all.emptyText = "No tickets"
        
        let new = TicketsList()
        new.title = "Available"
        new.emptyText = "No available tickets"
        new.filter = { $0.activationDate == nil && ($0.eventDate ?? .distantFuture).timeIntervalSinceNow >= -7200 }
        
        let used = TicketsList()
        used.title = " Used / Expired "
        used.emptyText = "No used / expired tickets"
        used.filter = { $0.activationDate != nil || ($0.eventDate ?? .distantFuture).timeIntervalSinceNow < -7200 }
        
        return [all, new, used]
    }
}
