//
//  OrgFilterSettings.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/5/17.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import UIKit

class OrgFilterSettings: UIViewController {
    
    private var contentCells = [UITableViewCell]()
    private var settingsTable: UITableView!
    private var selectedCategories = Set<Organization.Category>()
    
    static var yearGroupExpanded = false
    static var categoriesExpanded = false

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Filter Settings"
        view.backgroundColor = AppColors.canvas
        
        navigationItem.rightBarButtonItem = .init(title: "Done", style: .done, target: self, action: #selector(close))
        
        setup()
    }
    
    @objc private func close() {
        self.dismiss(animated: true)
    }
    
    private func setup() {
        settingsTable = {
            let tv = UITableView()
            tv.backgroundColor = .clear
            tv.separatorStyle = .none
            tv.contentInset.top = 10
            tv.contentInset.bottom = 10
            tv.tableFooterView = UIView()
            tv.dataSource = self
            tv.delegate = self
            tv.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(tv)
            
            tv.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            tv.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            tv.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            tv.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            return tv
        }()
        
        let yearLevelCell = GenericRoundCell(title: "Year Level")
        yearLevelCell.rightLabel.text = LocalStorage.otherSettings.yearGroup.stringValue
        contentCells.append(yearLevelCell)
        
        let undergradCell = SortSettingsCell(style: .top)
        undergradCell.checked = LocalStorage.otherSettings.yearGroup.contains(.undergraduate)
        undergradCell.sortTitle.text = "Undergraduate"
        contentCells.append(undergradCell)
        
        let gradCell = SortSettingsCell(style: .bottom)
        gradCell.checked = LocalStorage.otherSettings.yearGroup.contains(.graduate)
        gradCell.sortTitle.text = "Graduate"
        contentCells.append(gradCell)
        
        let categoriesCell = GenericRoundCell(title: "Categories")
        categoriesCell.rightLabel.text = selectedCategories.isEmpty ? "All" : "\(selectedCategories.count) selected"
        contentCells.append(categoriesCell)
        
        if let categories = LocalStorage.categories {
            let cells = categories.map { category -> SortSettingsCell in
                let cell = SortSettingsCell(style: .middle)
                cell.sortTitle.text = category.name
                return cell
            }
            
            cells.first?.style = .top
            cells.last?.style = .bottom
            
            contentCells.append(contentsOf: cells)
        }
        
        
    }
    

}


extension OrgFilterSettings: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4 + (LocalStorage.categories?.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return contentCells[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !OrgFilterSettings.yearGroupExpanded && (indexPath.row == 1 || indexPath.row == 2) {
            return 0
        } else if !OrgFilterSettings.categoriesExpanded && indexPath.row > 3 {
            return 0
        }
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let top = contentCells[0] as! GenericRoundCell
            OrgFilterSettings.yearGroupExpanded.toggle()
            OrgFilterSettings.yearGroupExpanded ? top.expand() : top.collapse()
            
            UIView.animate(withDuration: 0.2) {
                for cell in self.contentCells[1...2] {
                    if let s = cell as? SortSettingsCell {
                        s.sortTitle.alpha = OrgFilterSettings.yearGroupExpanded ? 1.0 : 0.0
                        s.img.alpha = s.sortTitle.alpha
                    }
                }
            }
            
            tableView.beginUpdates()
            tableView.endUpdates()
        case 1:
            if LocalStorage.otherSettings.yearGroup != .undergraduate {
                UISelectionFeedbackGenerator().selectionChanged()
                if let cell = contentCells[1] as? SortSettingsCell {
                    cell.checked.toggle()
                        LocalStorage.otherSettings.yearGroup.formSymmetricDifference(.undergraduate)
                    }
                (contentCells[0] as! GenericRoundCell).rightLabel.text = LocalStorage.otherSettings.yearGroup.stringValue
            }
            
        case 2:
            if LocalStorage.otherSettings.yearGroup != .graduate {
                UISelectionFeedbackGenerator().selectionChanged()
                if let cell = contentCells[2] as? SortSettingsCell {
                    cell.checked.toggle()
                        LocalStorage.otherSettings.yearGroup.formSymmetricDifference(.graduate)
                    }
                (contentCells[0] as! GenericRoundCell).rightLabel.text = LocalStorage.otherSettings.yearGroup.stringValue
            }
        case 3:
            let top = contentCells[3] as! GenericRoundCell
            OrgFilterSettings.categoriesExpanded.toggle()
            OrgFilterSettings.categoriesExpanded ? top.expand() : top.collapse()
            
            UIView.animate(withDuration: 0.2) {
                for cell in self.contentCells[4...] {
                    if let s = cell as? SortSettingsCell {
                        s.sortTitle.alpha = OrgFilterSettings.categoriesExpanded ? 1.0 : 0.0
                        s.img.alpha = s.sortTitle.alpha
                    }
                }
            }
            
            tableView.beginUpdates()
            tableView.endUpdates()
        default:
            UISelectionFeedbackGenerator().selectionChanged()
            if let cell = contentCells[indexPath.row] as? SortSettingsCell {
            cell.checked.toggle()
                self.selectedCategories.formSymmetricDifference([LocalStorage.categories![indexPath.row - 4]])
            }
            (contentCells[3] as! GenericRoundCell).rightLabel.text = selectedCategories.isEmpty ? "All" : "\(selectedCategories.count) selected"
        }
    }
    
}
