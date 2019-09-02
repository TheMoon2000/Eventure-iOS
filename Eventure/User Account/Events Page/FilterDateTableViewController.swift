//
//  FilterDateTableViewController.swift
//  Eventure
//
//  Created by Xiang Li on 9/2/19.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class FilterDateTableViewController: UITableViewController {
    var filterPage: FilterPageViewController!
    var contentCells = [UITableViewCell]()
    
    private(set) var start = Date() {
        didSet {
            self.updateStart()
        }
    }
    
    private(set) var end = Date() {
        didSet {
            self.updateEnd()
        }
    }
    
    var startTimeExpanded = false
    var endTimeExpanded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = FilterPageViewController.backgroundColor
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.contentInset.top = 8
        tableView.tintColor = MAIN_TINT
        
        let startTopCell = DatePickerTopCell(title: "Start time:")
        contentCells.append(startTopCell)
        
        
        let startBottomCell: DatePickerBottomCell = {
            let cell = DatePickerBottomCell()
            
            let seconds = ceil(Date().timeIntervalSinceReferenceDate / 3600) * 3600
            let rounded = Date(timeIntervalSinceReferenceDate: seconds)
            cell.datePicker.date = rounded
            
            return cell
        }()
        
        contentCells.append(startBottomCell)
        
        let endTopCell = DatePickerTopCell(title: "End time:")
        contentCells.append(endTopCell)
        
        let endBottomCell: DatePickerBottomCell = {
            let cell = DatePickerBottomCell()
            
            let seconds = ceil(Date().timeIntervalSinceReferenceDate / 3600) * 3600
            let rounded = Date(timeIntervalSinceReferenceDate: seconds)
            cell.datePicker.date = rounded
            
            cell.dateChangedHandler = { [weak self] date in
                endTopCell.displayedDate = date
                self?.end = date
                self?.filterPage.edited = true
                
            }
            
            return cell
        }()
        
        contentCells.append(endBottomCell)
        
        
        startBottomCell.dateChangedHandler = { [weak self] date in
            startTopCell.displayedDate = date
            self?.start = date
            /*let minimumEndTime = date.addingTimeInterval(300)
            endBottomCell.datePicker.minimumDate = minimumEndTime
            if endTopCell.displayedDate.timeIntervalSince(date) < 300 {
                endBottomCell.datePicker.setDate(date.addingTimeInterval(7200), animated: false)
                endBottomCell.dateChangedHandler!(date.addingTimeInterval(7200))
            }*/
            self?.filterPage.edited = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        filterPage.currentPage = 0
    }
    
    private func updateStart() {
        EventViewController.start = start
    }
    
    private func updateEnd() {
        EventViewController.end = end
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Table view data source & delegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 {
            return startTimeExpanded ? 220 : 0
        } else if indexPath.row == 3 {
            return endTimeExpanded ? 220 : 0
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentCells.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return contentCells[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        view.endEditing(true)
        
        switch indexPath.row {
        case 0:
            startTimeExpanded.toggle()
            
            let topCell = contentCells[0] as! DatePickerTopCell
            startTimeExpanded ? topCell.expand() : topCell.collapse()
            
            let bottomCell = self.contentCells[1] as! DatePickerBottomCell
            bottomCell.datePicker.isUserInteractionEnabled = self.startTimeExpanded
            
            UIView.animate(withDuration: 0.2) {
                bottomCell.datePicker.alpha = self.startTimeExpanded ? 1.0 : 0.0
            }
            
            tableView.beginUpdates()
            tableView.endUpdates()
        case 2:
            endTimeExpanded.toggle()
            
            view.endEditing(true)
            
            let topCell = contentCells[2] as! DatePickerTopCell
            endTimeExpanded ? topCell.expand() : topCell.collapse()
            
            let bottomCell = self.contentCells[3] as! DatePickerBottomCell
            bottomCell.datePicker.isUserInteractionEnabled = self.endTimeExpanded
            
            UIView.animate(withDuration: 0.2) {
                bottomCell.datePicker.alpha = self.endTimeExpanded ? 1.0 : 0.0
            }
            
            tableView.beginUpdates()
            tableView.endUpdates()
        default:
            break
        }
    }
    
}
