//
//  OverviewStats.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/10/30.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Charts
import BonMot

class OverviewStats: UIViewController, IndicatorInfoProvider {
    
    private var statCollection: UICollectionView!
    private var refreshControl = UIRefreshControl()
    
    private var emptyLabel: UILabel!
    private var majorDistribution: PieChartView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = AppColors.tableBG
        
        refreshControl.tintColor = AppColors.lightControl
        
        statCollection = {
            let col = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
            col.delegate = self
            col.dataSource = self
            col.addSubview(self.refreshControl)
            col.contentInset.top = 8
            col.backgroundColor = AppColors.canvas
            col.register(MajorDistributionCell.classForCoder(), forCellWithReuseIdentifier: "majors")
            col.contentInsetAdjustmentBehavior = .always
            col.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(col)
            
            col.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            col.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            col.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            col.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            return col
        }()
        
        
                
        // majorDistribution.animate(xAxisDuration: 0.6, yAxisDuration: 0.6)
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Overview")
    }
    
    
}


extension OverviewStats: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "majors", for: indexPath) as! MajorDistributionCell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print(indexPath)
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8,
                            left: 8,
                            bottom: 8,
                            right: 8)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { context in
            self.statCollection.collectionViewLayout.invalidateLayout()
        }, completion: nil)
    }
}
