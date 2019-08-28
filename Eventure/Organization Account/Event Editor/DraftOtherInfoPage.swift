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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
                
        tableView.backgroundColor = EventDraft.backgroundColor
        tableView.separatorStyle = .none
        tableView.contentInset.top = 10
        tableView.tableFooterView = UIView()
                
        let tagPickerCell = ChooseTagCell(parentVC: self, sideInset: 10)
        tagPickerCell.backgroundColor = EventDraft.backgroundColor
        contentCells.append(tagPickerCell)
        
        let imagePickerCell = EventImagePickerCell()
        imagePickerCell.backgroundColor = EventDraft.backgroundColor
        imagePickerCell.expand()
        contentCells.append(imagePickerCell)
        
        let imagePreviewCell = EventImagePreviewCell(parentVC: self)
        if let img = draftPage.draft.eventVisual {
            imagePreviewCell.previewImage.image = img
            imagePreviewCell.previewImage.backgroundColor = nil
            imagePreviewCell.chooseImageLabel.isHidden = true
        }
        imagePreviewCell.updateImageHandler = { image in
            self.draftPage.draft.eventVisual = image
        }
        contentCells.append(imagePreviewCell)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        draftPage.currentPage = 2
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentCells.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return contentCells[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = contentCells[indexPath.row]
        
        if let tagPickerCell = cell as? ChooseTagCell {
            let tagPicker = TagPickerView()
            tagPicker.customTitle = "Pick 1 ~ 3 tags that best describe your event!"
            tagPicker.customSubtitle = ""
            tagPicker.maxPicks = 3
            tagPicker.customButtonTitle = "Done"
            tagPicker.customContinueMethod = { tagPicker in
                tagPickerCell.status = .done
                self.navigationController?.popViewController(animated: true)
            }
            
            tagPicker.customDisappearHandler = { tags in
                self.draftPage.draft.tags = tagPicker.selectedTags
                if tags.count >= 1 && tags.count <= 3 {
                    tagPickerCell.status = .done
                    let tagword = tags.count == 1 ? "tag" : "tags"
                    tagPickerCell.rightLabel.text = "\(tags.count) \(tagword) selected"
                } else {
                    tagPickerCell.status = .fail
                    if tags.isEmpty {
                        tagPickerCell.rightLabel.text = "No tags chosen"
                    } else {
                        tagPickerCell.rightLabel.text = "Too many tags"
                    }
                }
            }
            
            tagPicker.selectedTags = draftPage.draft.tags
            navigationController?.pushViewController(tagPicker, animated: true)
        }
    }

}
