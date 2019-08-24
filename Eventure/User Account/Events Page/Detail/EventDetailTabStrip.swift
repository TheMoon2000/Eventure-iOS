//
//  EventDetailTabStrip.swift
//  Eventure
//
//  Created by appa on 8/23/19.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import Foundation
import XLPagerTabStrip

class EventDetailTabStrip : ButtonBarPagerTabStripViewController {
    
    var event: Event!
    
    required init(event: Event) {
        super.init(nibName: nil, bundle: nil)
        
        self.event = event
    }
    
    
    override func viewDidLoad() {
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .init(white: 0.98, alpha: 1)
        settings.style.selectedBarBackgroundColor = MAIN_TINT
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 15)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = MAIN_TINT
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .init(white: 0.1, alpha: 1)
            newCell?.label.textColor = MAIN_TINT
        }
        
        super.viewDidLoad()
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        let about = AboutViewController(text: event.eventDescription)
        let other = OtherViewController(text: "To be filled")
        
        return [about, other]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
