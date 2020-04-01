//
//  DiningMenuVC.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/3/25.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import UIKit
import BonMot
import XLPagerTabStrip

class DiningMenuVC: UIViewController, IndicatorInfoProvider {
    
    private var name: String!
    
    private var currentMeal: Int = 0
    private var currentDay: Int = 0
    
    var diningMenu: DiningMenu? {
        return diningMenu7Days[currentDay * 3 + currentMeal]
    }
    
    /// Contains menu for 7 days (21 items), at least one of which is non-nil.
    var diningMenu7Days: [DiningMenu?] = .init(repeating: nil, count: 21)
    
    var emptyLabel: UILabel!
    var menuTable: UITableView!
   
    init(name: String, menu: [DiningMenu?]) {
        super.init(nibName: nil, bundle: nil)
        
        self.diningMenu7Days = menu
        self.name = name
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = AppColors.background
                
        menuTable = {
            let tv = UITableView()
            tv.backgroundColor = .clear
            tv.separatorStyle = .none
            tv.allowsSelection = false
            tv.tableFooterView = UIView()
            tv.contentInset.bottom = 55
            tv.scrollIndicatorInsets.bottom = 50
            tv.dataSource = self
            tv.delegate = self
            tv.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(tv)
            
            tv.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            tv.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            tv.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            tv.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            return tv
        }()
        
        emptyLabel = {
            let label = UILabel()
            label.textColor = .gray
            if diningMenu7Days[currentDay] == nil {
                emptyLabel?.text = "Menu not available"
            }
            label.font = .appFontRegular(17)
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
            
            return label
        }()
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return .init(title: name)
    }

    func updateMeal(day: Int, mealTime: Int) {
        currentDay = day
        currentMeal = mealTime
        if diningMenu7Days[currentDay * 3 + currentMeal] == nil {
            emptyLabel?.text = "Menu not available"
        } else {
            emptyLabel?.text = ""
        }
        menuTable?.reloadData()
    }
    
}


extension DiningMenuVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        guard let menu = diningMenu else { return 0 }
        
        return menu.diningItems.count + (menu.message != nil ? 1 : 0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let offset = diningMenu?.message != nil ? 1 : 0
        if section == 0 && offset == 1 {
            return 1 // There is only one item in the message section
        } else {
            return diningMenu!.diningItems[section - offset].items.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let offset = diningMenu?.message != nil ? 1 : 0
        
        if section == 0 && offset == 1 {
            return UIView()
        }
        
        let container = UIVisualEffectView()
        if #available(iOS 12.0, *), traitCollection.userInterfaceStyle == .dark {
            container.effect = .none
            container.backgroundColor = AppColors.background
        } else {
            container.effect = UIBlurEffect(style: .light)
            container.backgroundColor = AppColors.background.withAlphaComponent(0.5)
        }
        
        let label: UILabel = {
            let label = UILabel()
            label.text = diningMenu?.diningItems[section - offset].name
            label.font = .appFontSemibold(17)
            label.numberOfLines = 3
            label.translatesAutoresizingMaskIntoConstraints = false
            container.contentView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: container.safeAreaLayoutGuide.leftAnchor, constant: 15).isActive = true
            label.rightAnchor.constraint(equalTo: container.safeAreaLayoutGuide.rightAnchor, constant: -15).isActive = true
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 5).isActive = true
            
            return label
        }()
        
        let _: UIView = {
            let line = UIView()
            line.backgroundColor = AppColors.lightControl
            line.translatesAutoresizingMaskIntoConstraints = false
            container.contentView.addSubview(line)
            
            line.leftAnchor.constraint(equalTo: label.leftAnchor).isActive = true
            line.rightAnchor.constraint(equalTo: label.rightAnchor).isActive = true
            line.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 3).isActive = true
            line.heightAnchor.constraint(equalToConstant: 1).isActive = true
            
            line.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -1).isActive = true
            
            return line
        }()
        
        return container
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if diningMenu?.message != nil && section == 0 {
            return 0
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let offset = diningMenu?.message != nil ? 1 : 0
        
        if indexPath.section == 0 {
            let cell = DiningHallMessageCell()
            cell.message.text = diningMenu?.message ?? "There is no message"
            
            return cell
        }
        
        let items = diningMenu!.diningItems[indexPath.section - offset].items
        let cell = DiningMenuItemCell(items[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        menuTable.reloadData()
    }
}
