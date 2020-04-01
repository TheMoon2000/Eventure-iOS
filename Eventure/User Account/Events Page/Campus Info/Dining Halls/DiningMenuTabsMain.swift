//
//  DiningMenuTabsMain.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/3/25.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON
import XLPagerTabStrip

class DiningMenuTabsMain: ButtonBarPagerTabStripViewController {
    
    var diningMenus = [[String: DiningMenu]]() // menu over 7 days (21 items)
    private var mealTime = 0
    
    required init(menus: [[String: DiningMenu]], mealTime: Int) {
        super.init(nibName: nil, bundle: nil)
        
        diningMenus = menus
        self.mealTime = mealTime
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        settings.style.buttonBarBackgroundColor = AppColors.tab
        settings.style.buttonBarItemBackgroundColor = AppColors.tab
        settings.style.selectedBarBackgroundColor = AppColors.main
        settings.style.buttonBarItemFont = .appFontSemibold(15)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarItemLeftRightMargin = 15
        settings.style.buttonBarItemTitleColor = AppColors.main
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        settings.style.buttonBarHeight = 38
        
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = AppColors.label
            newCell?.label.textColor = AppColors.main
        }
        
        super.viewDidLoad()
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        if diningMenus.isEmpty {
            return [DiningMenuVC(name: "error", menu: [DiningMenu?].init(repeating: nil, count: 21))]
        }
        
        var groupedByLocation = [String: [DiningMenu?]]()
        
        for i in 0..<diningMenus.count {
            for (location, menu) in diningMenus[i] {
                if !groupedByLocation.keys.contains(location) {
                    groupedByLocation[location] = [DiningMenu?].init(repeating: nil, count: 21)
                }
                
                groupedByLocation[location]?[i] = menu
            }
        }
                
        return groupedByLocation.sorted { $0.key < $1.key } . map { (location, menuList) in
            return DiningMenuVC(name: location, menu: menuList)
        }
        
    }
}
