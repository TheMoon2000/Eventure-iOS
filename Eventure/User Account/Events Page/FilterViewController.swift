//
//  FilterViewController.swift
//  Eventure
//
//  Created by Xiang Li on 8/30/19.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class FilterViewController: UITableViewController, UIGestureRecognizerDelegate {
    var back : UISwipeGestureRecognizer!
    private(set) var tags = Set<String>() {
        didSet {
            self.updateEventVC()
        }
    }
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
        tagPickerCell.reloadTagPrompt(tags: self.tags)
        contentCells.append(tagPickerCell)
        
        back = UISwipeGestureRecognizer(target: self, action: #selector(goBackToEvents))
        tableView.addGestureRecognizer(back)
        back.direction = .right
        back.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func updateEventVC() {
        EventViewController.chosenTags = tags
        self.modalTransitionStyle = .crossDissolve
        NotificationCenter.default.post(name: NSNotification.Name("user_chose_tags"), object: nil)
        dismiss(animated: false, completion: nil)
    }
    
    @objc private func goBackToEvents() {
        print(tags)
        self.modalTransitionStyle = .flipHorizontal
        dismiss(animated: true, completion: nil)
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
            }
            
            tagPicker.selectedTags = self.tags
            
            navigationController?.pushViewController(tagPicker, animated: true)
        }
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
}
