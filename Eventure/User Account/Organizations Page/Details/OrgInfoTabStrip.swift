//
//  OrgInfoTabStrip.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/17.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class OrgInfoTabStrip: ButtonBarPagerTabStripViewController {

    var organization: Organization!
    
    required init(organization: Organization) {
        super.init(nibName: nil, bundle: nil)
        
        self.organization = organization
    }
    
    override func viewDidLoad() {
        
        // Do any additional setup after loading the view.
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
            oldCell?.label.textColor = AppColors.label
            newCell?.label.textColor = MAIN_TINT
        }
        
        super.viewDidLoad()
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        let about = OrgDescriptionText(text: organization.orgDescription)
        
        let contactInfo = OrgContactInfo(organization: organization)
        
        return [about, contactInfo]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    

}
