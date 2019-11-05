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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Organizations"

        let orgList = OrganizationsViewController()
        let listNV = GenericNavigationController(rootViewController: orgList)
        
        let blank = BlankScreen()
        let blankNav = GenericNavigationController(rootViewController: blank)
        viewControllers = [listNV, blankNav]
        
        delegate = self
        preferredPrimaryColumnWidthFraction = 0.35
        preferredDisplayMode = .allVisible
        minimumPrimaryColumnWidth = 320
        maximumPrimaryColumnWidth = 400
        
        orgList.customPushHandler = { org in
            let detailVC = OrgDetailPage(organization: org)
            detailVC.isSplit = true
            let detailNav = GenericNavigationController(rootViewController: detailVC)
            DispatchQueue.main.async {
                detailVC.loadViewIfNeeded()
                if detailVC.tabStrip.buttonBarView != nil {
                    detailVC.tabStrip.reloadPagerTabStripView()
                }
                self.viewControllers[1] = detailNav
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
