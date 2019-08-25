//
//  DraftTimeLocationPage.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/23.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class DraftTimeLocationPage: UITableViewController {

    var draftPage: EventDraft!
    var contentCells = [UITableViewCell]()
    
    var startTimeExpanded = false
    var endTimeExpanded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .init(white: 0.94, alpha: 1)
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.contentInset.top = 8
        tableView.tintColor = MAIN_TINT

        let startTopCell = DatePickerTopCell(title: "Start time:")
        contentCells.append(startTopCell)
        
        
        let startBottomCell: DatePickerBottomCell = {
            let cell = DatePickerBottomCell(timeLocationPage: self, topCell: startTopCell)
            
            let seconds = ceil(Date().timeIntervalSinceReferenceDate / 3600) * 3600
            let rounded = Date(timeIntervalSinceReferenceDate: seconds)
            cell.datePicker.setDate(rounded, animated: false)
            
            startTopCell.displayedDate = rounded
            
            return cell
        }()
        
        contentCells.append(startBottomCell)
        
        let endTopCell = DatePickerTopCell(title: "End time:")
        contentCells.append(endTopCell)
        
        let endBottomCell: DatePickerBottomCell = {
            let cell = DatePickerBottomCell(timeLocationPage: self, topCell: startTopCell)
            
            let endDate = startBottomCell.datePicker.date.addingTimeInterval(3600)
            cell.datePicker.setDate(endDate, animated: false)
            
            endTopCell.displayedDate = endDate
            
            return cell
        }()
        
        contentCells.append(endBottomCell)
        
        
        let locationCell = DraftLocationCell()
        locationCell.textChangeHandler = { [weak self] in
            UIView.performWithoutAnimation {
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            }
        }
        contentCells.append(locationCell)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        draftPage.currentPage = 1
    }

    // MARK: - Table view data source & delegate

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 {
            return startTimeExpanded ? 230 : 0
        } else if indexPath.row == 3 {
            return endTimeExpanded ? 230 : 0
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
        switch indexPath.row {
        case 0:
            startTimeExpanded.toggle()
            
            view.endEditing(true)
            
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
