//
//  CampusInfoOverview.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/3/12.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SafariServices

class CampusInfoOverview: UIViewController {
    
    private var miniApps: UICollectionView!
    private var emptyLabel: UILabel!
    
    let titles = ["Dining Hall Menus", "Reserve Study Room"]
    let widgetIcons = [#imageLiteral(resourceName: "dining"), #imageLiteral(resourceName: "library")]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = AppColors.darkerNavBar
        
        emptyLabel = {
            let label = UILabel()
            label.textColor = .gray
            label.font = .appFontRegular(17)
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
            
            return label
        }()
        
        miniApps = {
            let cv = UICollectionView(frame: .zero, collectionViewLayout: TopAlignedCollectionViewFlowLayout())
            cv.delegate = self
            cv.dataSource = self
            cv.contentInset.top = 5
            cv.contentInset.bottom = MainTabBarController.current.tabBar.bounds.height
            cv.backgroundColor = AppColors.background
            
            cv.scrollIndicatorInsets.top = 2
            cv.layer.masksToBounds = true
            cv.layer.cornerRadius = 15
            cv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cv.layer.shadowOpacity = 0.04
            cv.layer.shadowOffset.height = -0.5
            
            cv.register(CampusInfoWidget.classForCoder(), forCellWithReuseIdentifier: "widget")
            cv.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(cv)
            
            cv.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            cv.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            cv.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            cv.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            return cv
        }()
    }
    
    @objc private func openDiningMenus() {
        let vc = AllDiningHalls()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension CampusInfoOverview: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return .init(title: "Info")
    }
}

extension CampusInfoOverview: UICollectionViewDelegateFlowLayout {
    
    /// Shortcut for getting the width of the collection view.
    var usableWidth: CGFloat {
        return miniApps.safeAreaLayoutGuide.layoutFrame.width
    }
    
    var minSpacing: CGFloat { 12.0 }
    
    var widgetFit: (widgetWidth: CGFloat, numFit: CGFloat) {
        
        let widgetMinWidth: CGFloat = 85.0
        let widgetMaxWidth: CGFloat = 120.0
        
        let numFit = floor((usableWidth - minSpacing) / (widgetMinWidth + minSpacing))
        return (min(widgetMaxWidth, ((usableWidth - minSpacing) / numFit) - minSpacing), numFit)
    }
    
    var equalSpacing: CGFloat {
        let fit = widgetFit
        return (usableWidth - fit.numFit * fit.widgetWidth - 1) / (fit.numFit + 1)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cell = CampusInfoWidget()
        cell.name.text = titles[indexPath.row]
        
        print(widgetFit.widgetWidth)
        return CGSize(width: widgetFit.widgetWidth, height: cell.preferredHeight(width: widgetFit.widgetWidth))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return equalSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return equalSpacing
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: equalSpacing,
                            left: equalSpacing,
                            bottom: equalSpacing,
                            right: equalSpacing)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { context in
            self.miniApps.collectionViewLayout.invalidateLayout()
        }, completion: nil)
    }
    
}

extension CampusInfoOverview: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "widget", for: indexPath) as! CampusInfoWidget
        
        cell.name.text = titles[indexPath.row]
        cell.icon.image = widgetIcons[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            let vc = AllDiningHalls()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = SFSafariViewController(url: URL(string: "https://berkeley.libcal.com")!)
            vc.preferredControlTintColor = AppColors.main
            self.present(vc, animated: true)
        default:
            break
        }
    }
    
}
