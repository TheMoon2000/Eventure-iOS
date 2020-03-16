//
//  Highlights.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/3/12.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class Discover: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "Highlights"
        view.backgroundColor = AppColors.background
    }
    

}


extension Discover: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return .init(title: "Discover")
    }
}
