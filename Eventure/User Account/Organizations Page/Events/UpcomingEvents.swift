//
//  UpcomingEvents.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/16.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class UpcomingEvents: OrgEventViewController, IndicatorInfoProvider {

    private var detailPage: OrgDetailPage!
    
    override var showTopTab: Bool { return false }
    
    override var useRefreshControl: Bool {
        return true
    }
    
    override var EMPTY_STRING: String {
        return "No upcoming events."
    }
    
    /// By providing the current organization's ID, the API only returns events that the current organization hosts.
    override var orgID: String? {
        return detailPage.organization.id
    }
    
    required init(detailPage: OrgDetailPage) {
        super.init(nibName: nil, bundle: nil)
        
        self.detailPage = detailPage
        start = Date()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .init(white: 0.95, alpha: 1)
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Upcoming Events")
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
