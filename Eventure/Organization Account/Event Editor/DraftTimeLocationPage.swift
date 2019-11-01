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
    var checkinTimeExpanded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = AppColors.canvas
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.contentInset.top = 8
        tableView.keyboardDismissMode = .interactive
        tableView.tintColor = AppColors.main

        let startTopCell = DatePickerTopCell(title: "Start time:")
        if let startDate = draftPage.draft.startTime {
            startTopCell.displayedDate = startDate
        }
        contentCells.append(startTopCell)
        
        
        let startBottomCell: DatePickerBottomCell = {
            let cell = DatePickerBottomCell()
            cell.backgroundColor = AppColors.canvas
            let seconds = ceil(Date().timeIntervalSinceReferenceDate / 3600) * 3600
            let rounded = Date(timeIntervalSinceReferenceDate: seconds)
            cell.datePicker.date = draftPage.draft.startTime ?? rounded
            
            return cell
        }()
        
        contentCells.append(startBottomCell)
        
        let endTopCell = DatePickerTopCell(title: "End time:")
        endTopCell.backgroundColor = AppColors.canvas
        if let endDate = draftPage.draft.endTime {
            endTopCell.displayedDate = endDate
        }
        contentCells.append(endTopCell)
        
        let endBottomCell: DatePickerBottomCell = {
            let cell = DatePickerBottomCell()
            cell.backgroundColor = AppColors.canvas
            let seconds = ceil(Date().timeIntervalSinceReferenceDate / 3600) * 3600
            let rounded = Date(timeIntervalSinceReferenceDate: seconds)
            cell.datePicker.date = draftPage.draft.endTime ?? rounded
            
            cell.dateChangedHandler = { [weak self] date in
                endTopCell.displayedDate = date
                self?.draftPage.draft.endTime = date
                self?.draftPage.edited = true
            }
            
            return cell
        }()
        
        contentCells.append(endBottomCell)
        
        
        startBottomCell.dateChangedHandler = { [weak self] date in
            startTopCell.displayedDate = date
            self?.draftPage.draft.startTime = date
            let minimumEndTime = date.addingTimeInterval(300)
            endBottomCell.datePicker.minimumDate = minimumEndTime
            if endTopCell.displayedDate.timeIntervalSince(date) < 300 {
                endBottomCell.datePicker.setDate(date.addingTimeInterval(3600), animated: false)
                endBottomCell.dateChangedHandler!(date.addingTimeInterval(3600))
            }
            self?.draftPage.edited = true
        }
        
        let checkinTopCell = DatePickerTopCell(title: "Check-in begins: ")
        checkinTopCell.backgroundColor = AppColors.canvas
        
        let checkinSliderCell = CheckinTimeCell()
        checkinSliderCell.backgroundColor = AppColors.canvas
        
        var tiers = [Int : (label: String, index: Int)]()
        for i in 0..<checkinSliderCell.options.count {
            let option = checkinSliderCell.options[i]
            tiers[option.timeInterval] = (option.label, i)
        }
                
        let eventTier = tiers[draftPage.draft.checkinTime] ?? tiers[3600]!
                
        checkinTopCell.rightLabel.text = eventTier.label
        checkinSliderCell.caption.text = eventTier.label
        checkinSliderCell.slider.value = 20.0 * Float(eventTier.index)
        checkinSliderCell.changeHandler = { [weak self] newInterval, newLabel in
            checkinTopCell.rightLabel.text = newLabel
            self?.draftPage.draft.checkinTime = newInterval
            self?.tableView.beginUpdates()
            self?.tableView.endUpdates()
            self?.draftPage.edited = true
        }
        
        contentCells.append(checkinTopCell)
        contentCells.append(checkinSliderCell)
        
        
        let locationCell = DraftLocationCell()
        locationCell.valueText.insertText(draftPage.draft.location)
        locationCell.textChangeHandler = { [weak self] textView in
            UIView.performWithoutAnimation {
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            }
            self?.draftPage.draft.location = textView.text
            self?.draftPage.edited = true
            if textView.selectedRange.location == textView.text.count {
                self?.tableView.scrollToRow(at: [0, 4], at: .bottom, animated: false)
            }
        }
        contentCells.append(locationCell)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        draftPage.currentPage = 1
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
        } else if indexPath.row == 5 && !checkinTimeExpanded {
            return 0
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
            checkinTimeExpanded.toggle()
            
            view.endEditing(true)
            
            let topCell = contentCells[4] as! DatePickerTopCell
            checkinTimeExpanded ? topCell.expand() : topCell.collapse()
            
            let bottomCell = contentCells[5] as! CheckinTimeCell
            bottomCell.slider.isUserInteractionEnabled = checkinTimeExpanded
            
            UIView.animate(withDuration: 0.2) {
                bottomCell.slider.alpha = self.checkinTimeExpanded ? 1.0 : 0.0
                bottomCell.sliderTicks.alpha = self.checkinTimeExpanded ? 1.0 : 0.0
            }
            
            tableView.beginUpdates()
            tableView.endUpdates()
        default:
            break
        }
    }

}
