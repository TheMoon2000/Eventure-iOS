//
//  FilterDateTableViewController.swift
//  Eventure
//
//  Created by Xiang Li on 9/2/19.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class FilterDateTableViewController: UITableViewController {
    
    private var parentVC: EventProvider!
    
    var contentCells = [UITableViewCell]()
    
    var startTimeExpanded = false
    var endTimeExpanded = false
    
    private var newStart: Date?
    private var newEnd: Date?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init(parentVC: EventProvider) {
        super.init(nibName: nil, bundle: nil)
        
        self.parentVC = parentVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Filter Settings"
        
        view.backgroundColor = AppColors.canvas
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.contentInset.top = 8
        tableView.tintColor = AppColors.main
        
        navigationItem.rightBarButtonItem = .init(title: "Apply", style: .plain, target: self, action: #selector(apply))
        navigationItem.leftBarButtonItem = .init(title: "Close", style: .done, target: self, action: #selector(close))
        
        let startTopCell = DatePickerTopCell(title: "Start time:")
        
        startTopCell.rightLabel.text = "Present"
        startTopCell.backgroundColor = tableView.backgroundColor
        contentCells.append(startTopCell)
        
        
        let startBottomCell: DatePickerBottomCell = {
            let cell = DatePickerBottomCell()
            
            let seconds = ceil(Date().timeIntervalSinceReferenceDate / 3600) * 3600
            let rounded = Date(timeIntervalSinceReferenceDate: seconds)
            if let start = parentVC.start {
                cell.datePicker.date = start
                startTopCell.displayedDate = cell.datePicker.date
            } else {
                cell.datePicker.date = rounded
            }
            
            return cell
        }()
        
        contentCells.append(startBottomCell)
        
        let endTopCell = DatePickerTopCell(title: "End time:")
        endTopCell.backgroundColor = tableView.backgroundColor
        endTopCell.rightLabel.text = "Distant future"
        contentCells.append(endTopCell)
        
        let endBottomCell: DatePickerBottomCell = {
            let cell = DatePickerBottomCell()
            
            let seconds = ceil(Date.timeIntervalSinceReferenceDate / 3600) * 3600
            let rounded = Date(timeIntervalSinceReferenceDate: seconds)
            if let end = parentVC.end {
                cell.datePicker.date = end
                endTopCell.displayedDate = cell.datePicker.date
            } else {
                cell.datePicker.date = rounded
            }
            
            
            return cell
        }()
        
        startBottomCell.dateChangedHandler = { newDate in
            startTopCell.displayedDate = newDate
            self.newStart = newDate
            let minimumUpperbound = newDate.addingTimeInterval(3600)
            let currentUpperbound = self.parentVC.end ?? .distantFuture
            if currentUpperbound < newDate {
                endBottomCell.datePicker.setDate(minimumUpperbound, animated: true)
                endBottomCell.dateChangedHandler?(minimumUpperbound)
            }
        }
        
        endBottomCell.dateChangedHandler = { date in
            endTopCell.displayedDate = date
            self.newEnd = date
            let maximumLowerbound = date.addingTimeInterval(-3600)
            let currentLowerbound = self.parentVC.start ?? Date()
            if currentLowerbound > date {
                startBottomCell.datePicker.setDate(maximumLowerbound, animated: true)
                startBottomCell.dateChangedHandler?(maximumLowerbound)
            }
        }
        
        contentCells.append(endBottomCell)
        
        let resetButton = GenericTableButton()
        resetButton.buttonTitle.text = "Reset"
        contentCells.append(resetButton)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func close() {
        self.dismiss(animated: true)
    }
    
    @objc private func apply() {
        if parentVC.start != newStart || parentVC.end != newEnd {
            parentVC.start = newStart
            parentVC.end = newEnd
            parentVC.fetchEventsIfNeeded()
        }
        self.dismiss(animated: true)
    }
    
    private func reset() {
        newStart = nil
        newEnd = nil
        
        if let cell = contentCells[0] as? DatePickerTopCell {
            cell.rightLabel.text = "Present"
        }
        
        if let cell = contentCells[2] as? DatePickerTopCell {
            cell.rightLabel.text = "Distant future"
        }
        
        if let cell1 = contentCells[1] as? DatePickerBottomCell, let cell2 = contentCells[3] as? DatePickerBottomCell {
            let seconds = ceil(Date.timeIntervalSinceReferenceDate / 3600) * 3600
            let rounded = Date(timeIntervalSinceReferenceDate: seconds)
            cell1.datePicker.date = rounded
            cell2.datePicker.date = rounded
        }
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
        case 4:
            reset()
        default:
            break
        }
    }
    
}
