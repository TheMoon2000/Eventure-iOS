//
//  PastEvents.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/16.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class PastEvents: OrgEventViewController, IndicatorInfoProvider {
    
    private var detailPage: OrgDetailPage!
    
    override var showTopTab: Bool { return false }
    
    /// By providing the current organization's ID, the API only returns events that the current organization hosts.
    override var orgID: String? {
        return detailPage.orgOverview.id
    }
    
    required init(detailPage: OrgDetailPage) {
        super.init(nibName: nil, bundle: nil)
        
        self.detailPage = detailPage
        upperBound = Date() // Set the present as the upper bound
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .init(white: 0.95, alpha: 1)
        
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Past Events")
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { context in
            self.eventCatalog.collectionViewLayout.invalidateLayout()
        }, completion: nil)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
