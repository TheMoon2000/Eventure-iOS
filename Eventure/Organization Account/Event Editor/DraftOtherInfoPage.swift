//
//  DraftOtherInfoPage.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/23.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class DraftOtherInfoPage: UITableViewController {

    var draftPage: EventDraft!
    private var contentCells = [UITableViewCell]()
    
    private var previewImageVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
                
        tableView.backgroundColor = AppColors.canvas
        tableView.keyboardDismissMode = .interactive
        tableView.separatorStyle = .none
        tableView.contentInset.top = 8
        tableView.contentInset.bottom = 8
        tableView.tableFooterView = UIView()
                
        let tagPickerCell = ChooseTagCell(parentVC: self, sideInset: 10)
        tagPickerCell.backgroundColor = tableView.backgroundColor
        tagPickerCell.reloadTagPrompt(tags: draftPage.draft.tags)
        contentCells.append(tagPickerCell)
        
        let capacityCell = DraftCapacityCell(title: "Capacity (0 for unlimited):")
        capacityCell.changeHandler = { [weak self] textfield in
            self?.draftPage.draft.capacity = Int(textfield.text!) ?? 0
            self?.draftPage.edited = true
        }
        capacityCell.backgroundColor = tableView.backgroundColor
        contentCells.append(capacityCell)
        
        let privateCell = SettingsSwitchCell()
        privateCell.backgroundColor = tableView.backgroundColor
        privateCell.enabled = !draftPage.draft.isPublic
        privateCell.titleLabel.text = "Private event"
        privateCell.switchHandler = { [weak self] on in
            self?.draftPage.draft.isPublic = !on
            self?.draftPage.edited = true
        }
        contentCells.append(privateCell)
        
        let secureCell = SettingsSwitchCell()
        secureCell.backgroundColor = tableView.backgroundColor
        secureCell.enabled = draftPage.draft.secureCheckin
        secureCell.titleLabel.text = "Secure check-in"
        secureCell.switchHandler = { [weak self] on in
            self?.draftPage.draft.secureCheckin = on
            self?.draftPage.edited = true
        }
        contentCells.append(secureCell)
        
        let imagePickerCell = EventImagePickerCell()
        imagePickerCell.backgroundColor = tableView.backgroundColor
        contentCells.append(imagePickerCell)
        
        let imagePreviewCell = EventImagePreviewCell(parentVC: self)
        if let img = draftPage.draft.eventVisual {
            imagePreviewCell.previewImage.image = img
            imagePreviewCell.previewImage.backgroundColor = nil
            imagePreviewCell.chooseImageLabel.isHidden = true
        }
        imagePreviewCell.updateImageHandler = { [weak self] image in
            self?.draftPage.draft.eventVisual = image
            self?.draftPage.edited = true
            self?.draftPage.imageEdited = true
        }
        contentCells.append(imagePreviewCell)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        draftPage.currentPage = 3
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentCells.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return contentCells[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 5 && !previewImageVisible {
            return 0
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath {
        case [0, 0]:
            let tagPickerCell = contentCells[0] as! ChooseTagCell
            let tagPicker = TagPickerView()
            tagPicker.customTitle = "Pick 1 ~ 3 tags that best describe your event!"
            tagPicker.customSubtitle = ""
            tagPicker.maxPicks = 3
            tagPicker.customButtonTitle = "Done"
            tagPicker.customContinueMethod = { tagPicker in
                tagPickerCell.status = .done
                self.navigationController?.popViewController(animated: true)
            }
            
            tagPicker.customDisappearHandler = { [ weak self ] tags in
                self?.draftPage.draft.tags = tagPicker.selectedTags
                tagPickerCell.reloadTagPrompt(tags: tags)
                self?.draftPage.edited = true
            }
            
            tagPicker.errorHandler = {
                self.navigationController?.popViewController(animated: true)
            }
            
            tagPicker.selectedTags = draftPage.draft.tags
            navigationController?.pushViewController(tagPicker, animated: true)
        case [0, 2]:
            let alert = UIAlertController(title: "Private Event", message: "Private events are only visible to the current members of your organization.", preferredStyle: .actionSheet)
            alert.addAction(.init(title: "Dismiss", style: .cancel))
            
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = tableView
                let cellRect = tableView.rectForRow(at: indexPath)
                popoverController.sourceRect = CGRect(x: cellRect.midX, y: cellRect.midY, width: 0, height: 0)
            }
            
            present(alert, animated: true)
        case [0, 3]:
            let alert = UIAlertController(title: "What is secure check-in?", message: "Secure check-in is intended for events that place restrictions / requirements on who can check-in (e.g. ones that sell tickets or require reservation), so that you, the organizer, have the ability to decide who can attend the event. When secure check-in is on, users must obtain a one-time verification code that will be sent to you before they can check-in.", preferredStyle: .actionSheet)
            alert.addAction(.init(title: "Dismiss", style: .cancel))
            
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = tableView
                let cellRect = tableView.rectForRow(at: indexPath)
                popoverController.sourceRect = CGRect(x: cellRect.midX, y: cellRect.midY, width: 0, height: 0)
            }
            
            present(alert, animated: true)
        case [0, 4]:
            previewImageVisible.toggle()
            
            let topCell = contentCells[4] as! EventImagePickerCell
            previewImageVisible ? topCell.expand() : topCell.collapse()
            
            let bottomCell = self.contentCells[5] as! EventImagePreviewCell
            bottomCell.previewImage.isUserInteractionEnabled = self.previewImageVisible
            
            UIView.animate(withDuration: 0.2) {
                let newAlpha: CGFloat = self.previewImageVisible ? 1.0 : 0.0
                for view in [bottomCell.previewImage, bottomCell.chooseImageLabel, bottomCell.captionLabel] {
                    view?.alpha = newAlpha
                }
                bottomCell.previewImage.alpha = newAlpha
            }
            
            tableView.beginUpdates()
            tableView.endUpdates()
        default:
            break
        }
    }

}
