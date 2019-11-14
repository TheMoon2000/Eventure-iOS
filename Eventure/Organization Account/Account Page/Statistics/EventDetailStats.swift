//
//  EventDetailStats.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/11/11.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SwiftyJSON

class EventDetailStats: UIViewController {

    private var event: Event!
    
    private var statCollection: UICollectionView!
    private var refreshControl = UIRefreshControl()
    
    /// A `StatManager` instance with information about the statistics for the current event.
    private var currentStats: StatsManager?
    
    private var loadingBG: UIView!
    private var emptyLabel: UILabel!
    
    required init(event: Event) {
        super.init(nibName: nil, bundle: nil)
        
        title = "Event Stats"
        self.event = event
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = AppColors.tableBG
        
        refreshControl.tintColor = AppColors.lightControl
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        
        let topLine: UIView = {
            let line = UIView()
            line.backgroundColor = AppColors.line.withAlphaComponent(0.5)
            line.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(line)
            
            line.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            line.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            line.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            line.heightAnchor.constraint(equalToConstant: 1).isActive = true
            
            return line
        }()
        
        statCollection = {
            let col = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
            col.delegate = self
            col.dataSource = self
            col.addSubview(self.refreshControl)
            col.contentInset.top = 8
            col.contentInset.bottom = 5
            col.backgroundColor = AppColors.canvas
            col.register(MajorDistributionCell.classForCoder(), forCellWithReuseIdentifier: "majors")
            col.register(PopularityRankingCell.classForCoder(), forCellWithReuseIdentifier: "top events")
            col.register(EventAttendanceCell.classForCoder(), forCellWithReuseIdentifier: "attendance")
            col.contentInsetAdjustmentBehavior = .always
            col.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(col)
            
            col.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            col.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            col.topAnchor.constraint(equalTo: topLine.bottomAnchor).isActive = true
            col.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            return col
        }()
        
        loadingBG = view.addLoader()
        loadingBG.centerXAnchor.constraint(equalTo: statCollection.centerXAnchor).isActive = true
        loadingBG.centerYAnchor.constraint(equalTo: statCollection.centerYAnchor).isActive = true
        
        fetchStats()
    }
    
    @objc private func pullToRefresh() {
        fetchStats(pulled: true)
    }
    
    private func fetchStats(pulled: Bool = false) {
        
        if !pulled {
            loadingBG.isHidden = false
        }
        
        let parameters = [
            "orgId": Organization.current!.id,
            "eventId": event.uuid
        ]
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/GetPastAttendees",
                           parameters: parameters)!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            DispatchQueue.main.async {
                self.loadingBG.isHidden = true
                self.refreshControl.endRefreshing()
            }
            
            guard error == nil else {
                DispatchQueue.main.async {
                    internetUnavailableError(vc: self)
                }
                return
            }
            
            do {
                let json = try JSON(data: data!)
                let stats = try StatsManager(source: json)
                self.currentStats = stats
                DispatchQueue.main.async {
                    self.statCollection.reloadSections([0])
                }
            } catch {
                DispatchQueue.main.async {
                    serverMaintenanceError(vc: self)
                }
            }
        }
        
        task.resume()
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Overview")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}


extension EventDetailStats: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    /// A shortcut to access the current content size.
    var usableSize: CGSize {
        return statCollection.safeAreaLayoutGuide.layoutFrame.size
    }
    
    var statItemSize: CGSize {
        if usableSize.width < 500 {
            let width = usableSize.width - 16
            return CGSize(width: width, height: 1.45 * width)
        } else if usableSize.width > usableSize.height && usableSize.width >= 520 {
            let numFit = floor(usableSize.width / 480)
            let width = ((usableSize.width - 8) / numFit) - 8
            return CGSize(width: width, height: 0.7 * width)
        } else {
            let numFit = floor(usableSize.width / 320)
            let width = ((usableSize.width - 8) / numFit) - 8
            return CGSize(width: width, height: width * 1.45)
        }
    }
    
    var equalSpacing: CGFloat {
        let size = statItemSize
        let rowCount = floor(usableSize.width / size.width)
        let extraSpace = usableSize.width - rowCount * size.width
        return extraSpace / (rowCount + 1) - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentStats == nil ? 0 : 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "majors", for: indexPath) as! MajorDistributionCell
            cell.setup(currentStats!)
        
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "attendance", for: indexPath) as! EventAttendanceCell
            cell.setup(statsManager: currentStats!)
            
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return statItemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return equalSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return equalSpacing
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
