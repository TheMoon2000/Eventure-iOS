//
//  CampusInfoOverview.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/3/12.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class CampusInfoOverview: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = AppColors.background
    }
}

extension CampusInfoOverview: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return .init(title: "Info")
    }
}


