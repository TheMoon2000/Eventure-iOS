//
//  CheckinSortSettings.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/11.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

typealias SortTitleCell = DatePickerTopCell

class CheckinSortSettings: UITableViewController {
    
    var checkinTableVC: CheckinResults!
    var optionsExpanded = false
    var contentCells = [UITableViewCell]()
    var edited = false
    
    required init(parentVC: CheckinResults) {
        super.init(nibName: nil, bundle: nil)
        
        title = "Sort Settings"
        self.checkinTableVC = parentVC
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = .none
        tableView.contentInset.top = 10
        tableView.backgroundColor = EventDraft.backgroundColor
        tableView.tableFooterView = UIView()
        
        navigationItem.rightBarButtonItem = .init(title: "Done", style: .done, target: self, action: #selector(done))
        
        let sortingTitle = SortTitleCell(title: "Sort by: ")
        sortingTitle.rightLabel.text = checkinTableVC.sortMethod == .date ? "Check-in time" : "Registrant name"
        contentCells.append(sortingTitle)
        
        let sortByDate = SortSettingsCell(style: .top)
        sortByDate.sortTitle.text = "Check-in time"
        sortByDate.bgView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        sortByDate.checked = checkinTableVC.sortMethod == .date
        contentCells.append(sortByDate)
        
        let sortByName = SortSettingsCell(style: .bottom)
        sortByName.sortTitle.text = "Registrant name"
        sortByName.bgView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        sortByName.checked = checkinTableVC.sortMethod == .name
        contentCells.append(sortByName)
        
        let ascendingSwitch = SettingsSwitchCell()
        ascendingSwitch.enabled = checkinTableVC.sortAscending
        ascendingSwitch.switchHandler = { ascending in
            self.checkinTableVC.sortAscending = ascending
            self.edited = true
        }
        contentCells.append(ascendingSwitch)
        
        if checkinTableVC.event.secureCheckin {
            let pendingSwitch = SettingsSwitchCell()
            pendingSwitch.titleLabel.text = "Show pending registrants"
            pendingSwitch.enabled = checkinTableVC.showPending
            pendingSwitch.switchHandler = { showPending in
                self.checkinTableVC.showPending = showPending
                self.edited = true
            }
            contentCells.append(pendingSwitch)
        }
        
    }
    
    @objc private func done() {
        if edited {
            checkinTableVC.resortRegistrants()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentCells.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !optionsExpanded && (indexPath.row == 1 || indexPath.row == 2) {
            return 0
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return contentCells[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath {
        case [0, 0]:
            let top = contentCells[0] as! SortTitleCell
            optionsExpanded.toggle()
            optionsExpanded ? top.expand() : top.collapse()
            
            UIView.animate(withDuration: 0.2) {
                for cell in self.contentCells[1...2] {
                    if let s = cell as? SortSettingsCell {
                        s.sortTitle.alpha = self.optionsExpanded ? 1.0 : 0.0
                        s.img.alpha = self.optionsExpanded ? 1.0 : 0.0
                    }
                }
            }
            
            tableView.beginUpdates()
            tableView.endUpdates()
        case [0, 1]:
            checkinTableVC.sortMethod = .date
            (contentCells[1] as! SortSettingsCell).checked = true
            (contentCells[2] as! SortSettingsCell).checked = false
            (contentCells[0] as! SortTitleCell).rightLabel.text = "Check-in time"
            edited = true
        case [0, 2]:
            checkinTableVC.sortMethod = .name
            (contentCells[1] as! SortSettingsCell).checked = false
            (contentCells[2] as! SortSettingsCell).checked = true
            (contentCells[0] as! SortTitleCell).rightLabel.text = "Registrant name"
            edited = true
        default:
            print(indexPath)
        }
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


}
