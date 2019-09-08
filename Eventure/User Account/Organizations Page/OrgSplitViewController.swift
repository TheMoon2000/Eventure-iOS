//
//  OrgSplitViewController.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/7.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class OrgSplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    
    private var orgList: OrganizationsViewController!
    private var orgDetail: OrgDetailPage!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Organizations"

        orgList = OrganizationsViewController()
        let listNV = UINavigationController(rootViewController: orgList)
        listNV.navigationBar.barTintColor = NAVBAR_TINT
        
        orgDetail = OrgDetailPage(organization: .empty)
        let detail = UINavigationController(rootViewController: orgDetail)
        detail.navigationBar.barTintColor = NAVBAR_TINT
        viewControllers = [listNV, detail]
        
        delegate = self
        preferredPrimaryColumnWidthFraction = 0.35
        preferredDisplayMode = .allVisible
        minimumPrimaryColumnWidth = 300
        maximumPrimaryColumnWidth = 400
        
        orgList.customPushHandler = { org in
            self.orgDetail = OrgDetailPage(organization: org)
            let detail = UINavigationController(rootViewController: self.orgDetail)
            detail.navigationBar.barTintColor = NAVBAR_TINT
            DispatchQueue.main.async {
                self.orgDetail.loadViewIfNeeded()
                if self.orgDetail.tabStrip.buttonBarView != nil {
                    self.orgDetail.tabStrip.reloadPagerTabStripView()
                }
                self.viewControllers[1] = detail
            }
        }
    }
    
    override var displayMode: UISplitViewController.DisplayMode {
        return UIScreen.main.bounds.width >= 800 ? .allVisible : .primaryOverlay
    }
    
    func primaryViewController(forCollapsing splitViewController: UISplitViewController) -> UIViewController? {
        return viewControllers[0]
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }

}
