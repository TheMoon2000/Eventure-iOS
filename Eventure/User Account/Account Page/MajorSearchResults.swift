//
//  MajorSearchResults.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/27.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class MajorSearchResults: UITableViewController, UISearchResultsUpdating {
    
    private var parentVC: MajorList!
    private var filteredMajors = [Major]()
    
    private var emptyLabel: UILabel!
    
    required init(parentVC: MajorList) {
        super.init(nibName: nil, bundle: nil)
        
        self.parentVC = parentVC
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = AppColors.tab
        tableView.tableFooterView = UIView()
        tableView.register(MajorCell.classForCoder(), forCellReuseIdentifier: "major")
        
        emptyLabel = {
            let label = UILabel()
            label.textAlignment = .center
            label.textColor = .init(white: 0.5, alpha: 1)
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
            
            return label
        }()
        
        updateResults(searchText: "")
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMajors.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "major") as! MajorCell

        let major = filteredMajors[indexPath.row]
        cell.titleLabel.text = major.fullName
        cell.isChecked = User.current!.majors.contains(major.id)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    private func updateResults(searchText: String) {
        let key = searchText.lowercased()
        
        DispatchQueue.global(qos: .default).async {
            self.filteredMajors = LocalStorage.majors.values.filter { major -> Bool in
                if key.isEmpty { return true }
                
                return major.fullName.lowercased().contains(key) || (major.abbreviation?.lowercased().contains(key) ?? false)
            }
            
            self.filteredMajors.sort { $0.fullName < $1.fullName }
            
            DispatchQueue.main.async {
                self.emptyLabel.text = self.filteredMajors.isEmpty ? "No search results" : ""
                self.tableView.reloadData()
            }
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        updateResults(searchText: searchController.searchBar.text!)
    }
    

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
