//
//  HomeScreen.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/3/11.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class HomeScreen: ButtonBarPagerTabStripViewController {
    
    private var container: HomeScreenContainer!
    private var didSetup = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init(container: HomeScreenContainer) {
        super.init(nibName: nil, bundle: nil)
        self.container = container
    }
        
    override func viewDidLoad() {
        
        settings.style.buttonBarBackgroundColor = AppColors.darkerNavBar
        settings.style.buttonBarItemBackgroundColor = AppColors.darkerNavBar
        settings.style.selectedBarBackgroundColor = AppColors.main
        settings.style.buttonBarItemFont = .appFontSemibold(15)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarItemLeftRightMargin = 8
        settings.style.buttonBarItemTitleColor = AppColors.main
        settings.style.buttonBarItemsShouldFillAvailableWidth = false
//        settings.style.buttonBarLeftContentInset = 20
//        settings.style.buttonBarRightContentInset = 20
        settings.style.buttonBarHeight = 38
        
        
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in

            if !changeCurrentIndex { return }
            
            if animated {
                UIView.animate(withDuration: 0.15) {
                    oldCell?.label.textColor = AppColors.label
                    newCell?.label.textColor = AppColors.main
                    
                    if newCell?.imageView.image != nil {
                        newCell?.imageView.image = #imageLiteral(resourceName: "tab_search").withRenderingMode(.alwaysTemplate)
                    } else if oldCell?.imageView.image != nil {
                        oldCell?.imageView.image = #imageLiteral(resourceName: "tab_search")
                    }
                }
            } else {
                oldCell?.label.textColor = AppColors.label
                newCell?.label.textColor = AppColors.main
                if newCell?.imageView.image != nil {
                    newCell?.imageView.image = #imageLiteral(resourceName: "tab_search").withRenderingMode(.alwaysTemplate)
                } else if oldCell?.imageView.image != nil {
                    newCell?.imageView.image = #imageLiteral(resourceName: "tab_search")
                }
            }
            
        }
                
        super.viewDidLoad()
        
        buttonBarView.removeFromSuperview()
        buttonBarView.applyMildShadow()
        container.navigationItem.titleView = buttonBarView
        
        
        // Extend the view controllers
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant:  MainTabBarController.current.tabBar.bounds.height).isActive = true
                
        DispatchQueue.main.async {
            self.moveToViewController(at: 1, animated: false)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !didSetup {
            let newInset = (self.view.frame.width - 110 - self.buttonBarView.contentSize.width) / 2
            self.settings.style.buttonBarLeftContentInset = newInset
            self.settings.style.buttonBarRightContentInset = newInset
            super.viewDidLoad()
            didSetup = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        navigationController?.navigationBar.isHidden = true
    }
    
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return [
            EventCategories(),
            Discover(),
            CampusInfoOverview()
        ]
    }
    
    /* Spacing customization for search image cell
     
    override func configureCell(_ cell: ButtonBarViewCell, indicatorInfo: IndicatorInfo) {
        if cell.imageView.image != nil {
            cell.frame.size.width = 40
            cell.imageView.contentMode = .scaleAspectFit
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        let d = super.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAtIndexPath: indexPath)
        
        if indexPath.row == 3 { return CGSize(width: 40, height: d.height) }
        
        return d
    }*/

}
