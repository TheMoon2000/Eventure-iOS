//
//  OrgEventsTabStrip.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/16.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class OrgEventsTabStrip: ButtonBarPagerTabStripViewController {

    var detailPage: OrgDetailPage!
    
    override func viewDidLoad() {
        
        // Do any additional setup after loading the view.
        settings.style.buttonBarBackgroundColor = AppColors.tab
        settings.style.buttonBarItemBackgroundColor = AppColors.tab
        settings.style.selectedBarBackgroundColor = AppColors.main
        settings.style.buttonBarItemFont = .appFontSemibold(15)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = AppColors.main
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = AppColors.label
            newCell?.label.textColor = AppColors.main
        }
        
        super.viewDidLoad()

    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
    
        let pastEvents = PastEvents(detailPage: detailPage)
        let upcomingEvents = UpcomingEvents(detailPage: detailPage)
        
        return [upcomingEvents, pastEvents]
    }

}
