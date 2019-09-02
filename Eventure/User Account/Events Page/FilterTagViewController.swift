//
//  FilterViewController.swift
//  Eventure
//
//  Created by Xiang Li on 8/30/19.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class FilterTagViewController: UITableViewController{
    var filterPage: FilterPageViewController!
    private(set) var tags = Set<String>() {
        didSet {
            self.updateEventVC()
        }
    }
    private var contentCells = [UITableViewCell]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        tableView.backgroundColor = FilterPageViewController.backgroundColor
        tableView.separatorStyle = .none
        tableView.contentInset.top = 10
        tableView.tableFooterView = UIView()
        
        let tagPickerCell = ChooseTagCell(parentVC: self, sideInset: 10)
        tagPickerCell.backgroundColor = FilterPageViewController.backgroundColor
        tagPickerCell.reloadTagPrompt(tags: self.tags)
        contentCells.append(tagPickerCell)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        filterPage.currentPage = 1
    }
    
    private func updateEventVC() {
        EventViewController.chosenTags = tags
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
            tagPicker.customTitle = "Pick 1 ~ 3 tags to find your favorite events!"
            tagPicker.customSubtitle = ""
            tagPicker.maxPicks = 3
            tagPicker.customButtonTitle = "Done"
            tagPicker.customContinueMethod = { tagPicker in
                tagPickerCell.status = .done
                self.navigationController?.popViewController(animated: true)
            }
            
            tagPicker.customDisappearHandler = { [ weak self ] tags in
                self?.tags = tagPicker.selectedTags
                tagPickerCell.reloadTagPrompt(tags: tags)
                self?.filterPage.edited = true
            }
            
            tagPicker.errorHandler = {
                self.navigationController?.popViewController(animated: true)
            }
            
            tagPicker.selectedTags = self.tags
            
            navigationController?.pushViewController(tagPicker, animated: true)
        }
    }
}
