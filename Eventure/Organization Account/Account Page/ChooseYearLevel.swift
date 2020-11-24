//
//  ChooseYearLevel.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/7/6.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import UIKit

/// Displays a screen where an organization admin can configure their targeted year level.
class ChooseYearLevel: UITableViewController {
    
    private var previousSettings: Set<Organization.Category>!
    private var spinner: UIActivityIndicatorView!
    private var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Year Level"
        tableView = UITableView(frame: .zero, style: .grouped)
        view.backgroundColor = AppColors.tableBG
        
        previousSettings = Organization.current!.categories
        
        spinner = UIActivityIndicatorView()
        saveButton = .init(title: "Update", style: .done, target: self, action: #selector(sync))
    }
    
    @objc private func sync() {
        navigationItem.rightBarButtonItem = .init(customView: spinner)
        spinner.startAnimating()
        Organization.current?.pushSettings(.yearLevel) { success in
            if !success {
                self.navigationItem.rightBarButtonItem = self.saveButton
                internetUnavailableError(vc: self)
            } else {
                self.navigationItem.rightBarButtonItem = nil
            }
        }
    }

    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.tintColor = AppColors.main
        cell.textLabel?.text = ["Undergraduate", "Graduate"][indexPath.row]
        cell.textLabel?.font = .appFontRegular(17)
        
        if Organization.current?.yearLevel.contains(.undergradudate) ?? false {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath)!
        
        if indexPath.row == 0 {
            Organization.current?.yearLevel.formSymmetricDifference(.undergradudate)
        } else { // indexPath.row == 1
            Organization.current?.yearLevel.formSymmetricDifference(.graduate)
        }
        
        if cell.accessoryType == .checkmark {
            cell.accessoryType = .none
        } else {
            cell.accessoryType = .checkmark
        }
    }
    

}
