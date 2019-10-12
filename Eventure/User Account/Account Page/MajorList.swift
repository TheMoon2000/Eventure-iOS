//
//  MajorList.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/27.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class MajorList: UIViewController {
    
    private var loadingBG: UIView!
    private var majorTable: UITableView!
    private(set) var majorList = [String: [Major]]() {
        didSet {
            sectionTitles = majorList.keys.sorted()
        }
    }
    
    private var searchController: UISearchController!
    private var sectionTitles = [String]()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationItem.hidesSearchBarWhenScrolling = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Areas of Study"
        view.backgroundColor = AppColors.canvas
        
        let searchResults = MajorSearchResults(parentVC: self)
        
        searchController = {
            let sc = UISearchController(searchResultsController: searchResults)
            sc.searchResultsUpdater = searchResults
            sc.searchBar.placeholder = "Search major / minor"
            sc.searchBar.tintColor = AppColors.main
            navigationItem.hidesSearchBarWhenScrolling = false
            sc.obscuresBackgroundDuringPresentation = true
            
            navigationItem.searchController = sc
            return sc
        }()
        
        definesPresentationContext = true
        
        navigationItem.rightBarButtonItem = .init(title: "Done", style: .done, target: self, action: #selector(done))
        
        majorTable = {
            let tb = UITableView()
            tb.backgroundColor = .clear
            tb.tintColor = AppColors.main
            tb.tableFooterView = UIView()
            tb.delegate = self
            tb.dataSource = self
            tb.contentInsetAdjustmentBehavior = .always
            tb.register(MajorCell.classForCoder(), forCellReuseIdentifier: "major")
            tb.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(tb)
            
            tb.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            tb.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            tb.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            tb.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            return tb
        }()
        
        loadingBG = view.addLoader()
        loadingBG.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        loadingBG.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        loadMajors()
    }
    
    
    private func loadMajors() {
        
        loadingBG.isHidden = false
        
        let url = URL(string: API_BASE_URL + "Majors")!
        let task = CUSTOM_SESSION.dataTask(with: url) {
            data, response, error in
            
            DispatchQueue.main.async {
                self.loadingBG.isHidden = true
            }
            
            guard error == nil else {
                DispatchQueue.main.async {
                    internetUnavailableError(vc: self)
                }
                return
            }
            
            if let json = try? JSON(data: data!), let array = json.array {
                var tmp = [String: [Major]]()
                var allMajors = [Int: Major]()
                for m in array {
                    let major = Major(json: m)
                    allMajors[major.id] = major
                    let prefix = major.fullName.prefix(1).uppercased()
                    if tmp[prefix] == nil {
                        tmp[prefix] = [major]
                    } else {
                        tmp[prefix]?.append(major)
                    }
                }
                Major.currentMajors = allMajors
                Major.save()
                self.majorList = tmp
                DispatchQueue.main.async {
                    self.majorTable.reloadData()
                }
            } else {
                DispatchQueue.main.async {
                    serverMaintenanceError(vc: self)
                }
            }
        }
        
        task.resume()
    }

    
    @objc private func done() {
        navigationController?.popViewController(animated: true)
    }

}

extension MajorList: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return majorList[sectionTitles[section]]?.count ?? 0
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionTitles
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let container = UIView()
        container.backgroundColor = AppColors.canvas
        
        let label = UILabel()
        label.layoutMargins.left = 10
        label.textColor = .gray
        label.text = sectionTitles[section]
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        
        label.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 6).isActive = true
        label.topAnchor.constraint(equalTo: container.topAnchor, constant: 2).isActive = true
        label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -2).isActive = true
        
        return container
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "major") as! MajorCell
        
        let section = sectionTitles[indexPath.section]
        let major = majorList[section]![indexPath.row]
        
        cell.titleLabel.text = major.fullName
        cell.isChecked = User.current!.majors.contains(major.id)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = sectionTitles[indexPath.section]
        let major = majorList[section]![indexPath.row]
        let cell = tableView.cellForRow(at: indexPath) as! MajorCell
        
        if User.current!.majors.contains(major.id) {
            User.current?.majors.remove(major.id)
            cell.isChecked = false
        } else if User.current!.majors.count < 3 {
            User.current?.majors.insert(major.id)
            cell.isChecked = true
        } else {
            let alert = UIAlertController(title: "Too many areas", message: "Please select no more than 3 areas of study.", preferredStyle: .alert)
            alert.addAction(.init(title: "OK", style: .cancel))
            present(alert, animated: true)
        }
    }
}
