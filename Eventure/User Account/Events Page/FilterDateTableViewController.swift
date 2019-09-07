//
//  FilterDateTableViewController.swift
//  Eventure
//
//  Created by Xiang Li on 9/2/19.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class FilterDateTableViewController: UITableViewController {
    
    private var parentVC: EventViewController!
    
    var contentCells = [UITableViewCell]()
    
    var startTimeExpanded = false
    var endTimeExpanded = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init(parentVC: EventViewController) {
        super.init(nibName: nil, bundle: nil)
        
        self.parentVC = parentVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Filter Settings"
        
        view.backgroundColor = EventDraft.backgroundColor
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.contentInset.top = 8
        tableView.tintColor = MAIN_TINT
        
        navigationItem.leftBarButtonItem = .init(title: "Reset", style: .plain, target: self, action: #selector(reset))
        navigationItem.rightBarButtonItem = .init(title: "Close", style: .done, target: self, action: #selector(close))
        
        let startTopCell = DatePickerTopCell(title: "Start time:")
        
        startTopCell.rightLabel.text = "Present"
        contentCells.append(startTopCell)
        
        
        let startBottomCell: DatePickerBottomCell = {
            let cell = DatePickerBottomCell()
            
            let seconds = ceil(Date().timeIntervalSinceReferenceDate / 3600) * 3600
            let rounded = Date(timeIntervalSinceReferenceDate: seconds)
            if let start = EventViewController.start {
                cell.datePicker.date = start
                startTopCell.displayedDate = cell.datePicker.date
            } else {
                cell.datePicker.date = rounded
            }
            
            cell.dateChangedHandler = { newDate in
                startTopCell.displayedDate = newDate
                EventViewController.start = newDate
            }
            
            return cell
        }()
        
        contentCells.append(startBottomCell)
        
        let endTopCell = DatePickerTopCell(title: "End time:")
        endTopCell.rightLabel.text = "Distant future"
        contentCells.append(endTopCell)
        
        let endBottomCell: DatePickerBottomCell = {
            let cell = DatePickerBottomCell()
            
            let seconds = ceil(Date().timeIntervalSinceReferenceDate / 3600) * 3600
            let rounded = Date(timeIntervalSinceReferenceDate: seconds)
            if let end = EventViewController.end {
                cell.datePicker.date = end
                endTopCell.displayedDate = cell.datePicker.date
            } else {
                cell.datePicker.date = rounded
            }
            
            cell.dateChangedHandler = { date in
                endTopCell.displayedDate = date
                EventViewController.end = date
            }
            
            return cell
        }()
        
        contentCells.append(endBottomCell)
        
        let tagPickerCell = ChooseTagCell(parentVC: self, sideInset: 10)
        tagPickerCell.maxPicks = nil
        tagPickerCell.reloadTagPrompt(tags: EventViewController.chosenTags)
        contentCells.append(tagPickerCell)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func close() {
        parentVC.fetchEventsIfNeeded()
        self.dismiss(animated: true)
    }
    
    @objc private func reset() {
        EventViewController.chosenTags.removeAll()
        EventViewController.start = nil
        EventViewController.end = nil
        self.dismiss(animated: true)
        parentVC.fetchEventsIfNeeded()
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
            let tagPicker = TagPickerView()
            tagPicker.customTitle = "Filter events by tags"
            tagPicker.customSubtitle = "Only events that match at least one of your selected tags will be shown."
            tagPicker.maxPicks = nil
            tagPicker.customButtonTitle = "Done"
            tagPicker.customContinueMethod = { tagPicker in
                (self.contentCells.last as! ChooseTagCell).status = .done
                self.navigationController?.popViewController(animated: true)
            }
            
            tagPicker.customDisappearHandler = { [ weak self ] tags in
                EventViewController.chosenTags = tagPicker.selectedTags
                if let tagCell = (self?.contentCells.last as? ChooseTagCell) {
                    tagCell.reloadTagPrompt(tags: tags)
                }
            }
            
            tagPicker.errorHandler = {
                self.navigationController?.popViewController(animated: true)
            }
            
            tagPicker.selectedTags = EventViewController.chosenTags
            
            navigationController?.pushViewController(tagPicker, animated: true)
        default:
            break
        }
    }
    
}
