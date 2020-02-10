//
//  OrgProfilePage.swift
//  Eventure
//
//  Created by Prince Wang on 2019/9/1.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class OrgProfilePage: UITableViewController, EditableInfoProvider {
    
    var parentVC: OrgAccountPageController?
    
    private var contentCells = [[UITableViewCell]]()
    private var saveBarButton: UIBarButtonItem!
    private var spinner: UIActivityIndicatorView!
    
    private var appStartExpanded = false
    private var appEndExpanded = false
    
    var cellsEditable: Bool { return true }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Organization Profile"
        
        navigationItem.backBarButtonItem = .init(title: "Back", style: .plain, target: nil, action: nil)
        
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = AppColors.tableBG
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInset.top = 5
        tableView.contentInset.bottom = 10
        tableView.keyboardDismissMode = .interactive
        tableView.tableFooterView = UIView()
        
        let section0: [UITableViewCell] = {
            var section = [UITableViewCell]()
            
            let websiteCell = TextFieldCell(parentVC: self)
            websiteCell.textfield.placeholder = "Link to website"
            websiteCell.icon.image = #imageLiteral(resourceName: "browser")
            websiteCell.linkDetectionEnabled = true
            websiteCell.textfield.keyboardType = .URL
            websiteCell.textfield.autocapitalizationType = .none
            websiteCell.textfield.enablesReturnKeyAutomatically = true
            websiteCell.textfield.text = Organization.current?.website
            websiteCell.textChanged()
            
            websiteCell.changeHandler = { textfield in
                Organization.current?.saveEnabled = false
                Organization.current?.website = textfield.text!
                Organization.current?.saveEnabled = true
            }
            
            websiteCell.endEditingHandler = { textfield in
                Organization.current?.website = textfield.text!
            }
            
            websiteCell.returnHandler = { textfield in
                (self.contentCells[1][0] as! TextFieldCell).textfield.becomeFirstResponder()
            }
            //FIXME:闪退
            
            section.append(websiteCell)
            
            if let website = Organization.current?.website {
                websiteCell.textfield.text = website
            }
            
            return section
            
            }()
        
        contentCells.append(section0)
        
        let section1: [UITableViewCell] = {
            var section = [UITableViewCell]()
            
            let emailCell = TextFieldCell(parentVC: self)
            emailCell.textfield.placeholder = "Contact Email"
            emailCell.icon.image = UIImage(named: "email")
            emailCell.textfield.keyboardType = .emailAddress
            emailCell.textfield.autocapitalizationType = .none
            emailCell.textfield.enablesReturnKeyAutomatically = true
            emailCell.textfield.text = Organization.current?.contactEmail
            emailCell.textChanged()
            
            emailCell.changeHandler = { textfield in
                Organization.current?.saveEnabled = false
                Organization.current?.contactEmail = textfield.text!
                Organization.current?.saveEnabled = true
            }
            
            emailCell.endEditingHandler = { textfield in
                Organization.current?.contactEmail = textfield.text!
            }
            
            emailCell.returnHandler = { textfield in
                (self.contentCells[2][0] as! TextFieldCell).textfield.becomeFirstResponder()
            }
            
            section.append(emailCell)
            
            if let email = Organization.current?.contactEmail {
                emailCell.textfield.text = email
            }
            
            return section
            
        }()
        
        contentCells.append(section1)
        
        //Tag Area
        let section2: [UITableViewCell] = {
            var section = [UITableViewCell]()
            let tagCell = SettingsItemCell()
            tagCell.icon.image = #imageLiteral(resourceName: "tag").withRenderingMode(.alwaysTemplate)
            tagCell.icon.tintColor = AppColors.link
            tagCell.titleLabel.text = "Manage Tags"
            
            section.append(tagCell)
            
            return section
        }()
        
        contentCells.append(section2)
        
        let section3: [UITableViewCell] = {
            var section = [UITableViewCell]()
            let descriptionCell = SettingsItemCell()
            descriptionCell.icon.image = #imageLiteral(resourceName: "edit").withRenderingMode(.alwaysTemplate)
            descriptionCell.titleLabel.text = "Organization Description"
            
            section.append(descriptionCell)
            
            return section
        }()
        
        contentCells.append(section3)
        
        let section4: [UITableViewCell] = {
            var section = [UITableViewCell]()
            
            let startDateHeader = SettingsItemCell(withAccessory: false)
            startDateHeader.icon.image = #imageLiteral(resourceName: "start_time").withRenderingMode(.alwaysTemplate)
            startDateHeader.icon.tintColor = AppColors.startTime
            startDateHeader.titleLabel.text = "Start Date"
            
            section.append(startDateHeader)
            
            let startDateChooser = ApplicationDateCell()
            startDateChooser.dateChangedHandler = { date in
                Organization.current?.appStart = date
                Organization.current?.pushSettings(.appStartEnd)
                startDateHeader.valueLabel.text = date.fullString
            }
            
            if let startDate = Organization.current?.appStart {
                startDateHeader.valueLabel.textColor = AppColors.link
                startDateHeader.valueLabel.text = startDate.fullString
                startDateChooser.picker.date = startDate
            }
            
            section.append(startDateChooser)
            
            let endDateHeader = SettingsItemCell(withAccessory: false)
            endDateHeader.icon.image = #imageLiteral(resourceName: "deadline").withRenderingMode(.alwaysTemplate)
            endDateHeader.titleLabel.text = "End Date"
            
            section.append(endDateHeader)
            
            let endDateChooser = ApplicationDateCell()
            endDateChooser.dateChangedHandler = { date in
                Organization.current?.appDeadline = date
                Organization.current?.pushSettings(.appStartEnd)
                endDateHeader.valueLabel.text = date.fullString
            }
            
            if let endDate = Organization.current?.appDeadline {
                endDateHeader.valueLabel.textColor = AppColors.link
                endDateHeader.valueLabel.text = endDate.fullString
                endDateChooser.picker.date = endDate
            }
            
            section.append(endDateChooser)
            
            return section
        }()
        
        contentCells.append(section4)
        
        spinner = UIActivityIndicatorView(style: .gray)
        spinner.startAnimating()
        
        saveBarButton = .init(title: "Save", style: .done, target: self, action: #selector(save))
        navigationItem.rightBarButtonItem = saveBarButton
            
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return [
            "Organization Website",
            "Contact Email",
            "Organization Tags",
            "Organization Description",
            "Application Window"
            ][section]
    }
    
    @objc private func save(disappearing: Bool = false) {
        
        guard Organization.current != nil else {
            return
        }
        
        guard Organization.needsUpload else {
            return
        }
        
        navigationItem.rightBarButtonItem = .init(customView: spinner)
        
        // Calling the API to save data
        
        Organization.current!.pushSettings([.tags, .email, .orgDescription, .website]) {
            successful in
            
            self.navigationItem.rightBarButtonItem = self.saveBarButton
            
            if successful {
                Organization.needsUpload = false
            } else if !disappearing {
                DispatchQueue.main.async {
                    internetUnavailableError(vc: self)
                }
            } else {
                let alert = UIAlertController(title: "Changes could not uploaded", message: "It seems that some of your changes to your organization's settings could not be automatically uploaded due to lack of internet connection. These changes have been saved locally, but will be lost if you quit and reopen this app while being online, as they will be overwritten.", preferredStyle: .alert)
                alert.addAction(.init(title: "I Understand", style: .cancel))
                DispatchQueue.main.async {
                    self.parentVC?.present(alert, animated: true, completion: nil)
                }
            }
            
        }
            
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if Organization.needsUpload {
            save(disappearing: true)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return contentCells.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentCells[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return contentCells[indexPath.section][indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == [4, 1] {
            return appStartExpanded ? 220 : 0
        } else if indexPath == [4, 3] {
            return appEndExpanded ? 220 : 0
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath {
        case [3, 0]:
            let editPage = DescriptionEditPage()
            editPage.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(editPage, animated: true)
            
        case [2, 0]:
            //This is the case when you hit Tags cell: org changing their tags
            let tagPicker = TagPickerView()
            tagPicker.customTitle = "Choose 1 - 3 tags that best describe your organization."
            tagPicker.customSubtitle = ""
            tagPicker.maxPicks = 3
            tagPicker.selectedTags = Organization.current!.tags
            tagPicker.customButtonTitle = "Done"
            
            tagPicker.customContinueMethod = { tagPicker in
                tagPicker.loadingBG.isHidden = false
                
                Organization.current?.pushSettings(.tags) { success in
                    tagPicker.loadingBG.isHidden = true
                    if success {
                        Organization.current!.tags = tagPicker.selectedTags
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        internetUnavailableError(vc: self)
                    }
                }
            }
            
            tagPicker.customDisappearHandler = { tags in
                Organization.current?.tags = tags
                Organization.current?.pushSettings(.tags, nil)
            }
            
            //push the TagPicker Page
            tagPicker.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(tagPicker, animated: true)
        
        case [4, 0]:
            appStartExpanded.toggle()
            if let startDateCell = tableView.cellForRow(at: [4, 1]) as? ApplicationDateCell {
                startDateCell.picker.isUserInteractionEnabled = appStartExpanded
                UIView.animate(withDuration: 0.2) {
                    startDateCell.picker.alpha = self.appStartExpanded ? 1.0 : 0.0
                }
            }
            
            tableView.beginUpdates()
            tableView.endUpdates()
            tableView.scrollToRow(at: [4, 1], at: .none, animated: true)
        
        case [4, 2]:
            appEndExpanded.toggle()
            if let endDateCell = tableView.cellForRow(at: [4, 3]) as? ApplicationDateCell {
                endDateCell.picker.isUserInteractionEnabled = appEndExpanded
                UIView.animate(withDuration: 0.2) {
                    endDateCell.picker.alpha = self.appEndExpanded ? 1.0 : 0.0
                }
            }
            
            tableView.beginUpdates()
            tableView.endUpdates()
            tableView.scrollToRow(at: [4, 3], at: .none, animated: true)
    
        default:
            break
        }
    }
    
    
    
}

