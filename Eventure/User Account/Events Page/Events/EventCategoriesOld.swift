//
//  EventCategories.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/2/10.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON
import XLPagerTabStrip

class EventCategories: UIViewController {
    
    var eventCategories = [Tag]()
    var categoryTable: UITableView!
    var loadingBG: UIVisualEffectView!
    var emptyLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = AppColors.tableBG
        navigationItem.title = "Categories"
        
        setup()
        loadTags()
    }
    
    private func setup() {
        categoryTable = {
            let tv = UITableView()
            tv.dataSource = self
            tv.delegate = self
            tv.backgroundColor = AppColors.tableBG
            tv.tableFooterView = UIView()
            tv.backgroundColor = .clear
            tv.contentInset.bottom = MainTabBarController.current.tabBar.bounds.height
//            tv.refreshControl = UIRefreshControl()
//            tv.refreshControl?.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
            tv.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(tv)
            
            tv.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            tv.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            tv.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            tv.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            return tv
        }()
        
        loadingBG = view.addLoader()
        
        loadingBG.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        loadingBG.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        emptyLabel = {
            let label = UILabel()
            label.textColor = .gray
            label.font = .appFontRegular(16)
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: loadingBG.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: loadingBG.centerYAnchor).isActive = true
            
            return label
        }()
    }
    
    @objc private func pullToRefresh() {
        loadTags(true)
    }
    
    private func loadTags(_ pulled: Bool = false) {
        
        if !pulled {
            loadingBG.isHidden = false
        }
        
        LocalStorage.updateTags { status in
            self.loadingBG.isHidden = true
            self.categoryTable.refreshControl?.endRefreshing()

            if status == 0 {
                self.emptyLabel.text = ""
                self.eventCategories = LocalStorage.tags.values.sorted { $0.name < $1.name }
                self.categoryTable.reloadData()
            } else if status == -1 {
                self.emptyLabel.text = CONNECTION_ERROR
                internetUnavailableError(vc: self)
            } else if status == -2 {
                self.emptyLabel.text = SERVER_ERROR
                serverMaintenanceError(vc: self)
            }
        }

    }
    

}

// Setup table view to display the event categories.

extension EventCategories: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = CategoryCell()
        cell.category = eventCategories[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        categoryTable.deselectRow(at: indexPath, animated: true)
        
        let vc = EventsInCategory(category: eventCategories[indexPath.row])
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension EventCategories: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Categories")
    }
}
