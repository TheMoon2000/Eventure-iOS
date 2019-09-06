//
//  OrganizationsViewController.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/5/26.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class OrganizationsViewController: UIViewController {

    
    private var topTabBg: UIVisualEffectView!
    private var topTab: UISegmentedControl!
    private var spinner: UIActivityIndicatorView!
    private var spinnerLabel: UILabel!
    private var orgTable: UITableView!
    private var emptyLabel: UILabel!
    
    private var organizations = Set<Organization>() {
        didSet {
            self.updateFiltered()
        }
    }
    
    private var filteredOrgs = [Organization]()
    
    private var isFiltering: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    
    // The search bar
    private let searchController = UISearchController(searchResultsController: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        title = "Organizations"
        
        // Search bar setup
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = MAIN_TINT
        searchController.searchBar.placeholder = "Search Organizations"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(loadOrganizations))
        
        
        topTabBg = {
            let ev = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
            ev.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(ev)
            
            ev.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            ev.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            ev.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            ev.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            return ev
        }()
        
        topTab = {
            let tab = UISegmentedControl(items: ["All", "Recommended",  "Subscribed"])
            if User.current == nil {
                tab.setEnabled(false, forSegmentAt: 1)
                tab.setEnabled(false, forSegmentAt: 2)
            }
            tab.tintColor = MAIN_TINT
            tab.selectedSegmentIndex = 0
            tab.translatesAutoresizingMaskIntoConstraints = false
            topTabBg.contentView.addSubview(tab)
            
            tab.leftAnchor.constraint(equalTo: topTabBg.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            tab.rightAnchor.constraint(equalTo: topTabBg.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
            tab.centerYAnchor.constraint(equalTo: topTabBg.centerYAnchor).isActive = true
            
            tab.addTarget(self, action: #selector(selectionChanged), for: .valueChanged)
            
            return tab
        }()
        
        orgTable = {
            let orgTable = UITableView()
            orgTable.dataSource = self
            orgTable.delegate = self
            orgTable.tableFooterView = UIView()
            orgTable.separatorColor = .lightGray
            orgTable.backgroundColor = UIColor.init(white: 0.95, alpha: 1)
            orgTable.contentInsetAdjustmentBehavior = .always
            orgTable.contentInset.top = 60
            orgTable.scrollIndicatorInsets.top = 60
            orgTable.register(OrganizationCell.classForCoder(), forCellReuseIdentifier: "org")
            orgTable.translatesAutoresizingMaskIntoConstraints = false
            view.insertSubview(orgTable, belowSubview: topTabBg)
            
            orgTable.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            orgTable.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            orgTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            orgTable.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
            return orgTable
        }()
        
        spinner = {
            let spinner = UIActivityIndicatorView(style: .whiteLarge)
            spinner.color = .lightGray
            spinner.hidesWhenStopped = true
            spinner.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(spinner)
            
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            spinner.centerYAnchor.constraint(equalTo: orgTable.centerYAnchor, constant: -5).isActive = true
            
            return spinner
        }()
        
        spinnerLabel = {
            let label = UILabel()
            label.text = "Loading organizations..."
            label.isHidden = true
            label.font = .systemFont(ofSize: 17, weight: .medium)
            label.textColor = .darkGray
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: spinner.centerXAnchor).isActive = true
            label.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 10).isActive = true
            
            return label
        }()
        
        emptyLabel = {
            let label = UILabel()
            label.textColor = .darkGray
            label.font = .systemFont(ofSize: 17)
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: orgTable.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: orgTable.centerYAnchor).isActive = true
            
            return label
        }()
        
        loadOrganizations()
    }
    
    @objc private func selectionChanged() {
        updateFiltered()
    }
    
    
    @objc private func loadOrganizations() {
        
        spinner.startAnimating()
        spinnerLabel.isHidden = false
        emptyLabel.text = ""
        organizations.removeAll()
        self.orgTable.reloadData()
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        var parameters = [String : String]()
        if User.current != nil {
            parameters["userId"] = String(User.current!.uuid)
        }
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "account/ListOrgs",
                           parameters: parameters)!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.spinnerLabel.isHidden = true
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
            
            guard error == nil else {
                DispatchQueue.main.async {
                    self.emptyLabel.text = CONNECTION_ERROR
                    internetUnavailableError(vc: self, handler: nil)
                }
                return
            }
            
            if let orgs = try? JSON(data: data!).arrayValue {
                var tmp = Set<Organization>()
                for org in orgs {
                    let orgObj = Organization(orgInfo: org)
                    
                    // Only show active organizations
                    if orgObj.active {
                        tmp.insert(orgObj)
                    }
                }
                DispatchQueue.main.async {
                    self.organizations = tmp
                    self.emptyLabel.text = tmp.isEmpty ? "No Organizations" : ""
                    self.orgTable.reloadSections(IndexSet(arrayLiteral: 0), with: .none)
                }
            } else {
                DispatchQueue.main.async {
                    self.emptyLabel.text = SERVER_ERROR
                    serverMaintenanceError(vc: self)
                }
            }
        }
        
        task.resume()
    }
    
}


extension OrganizationsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredOrgs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "org") as! OrganizationCell
        cell.setup(with: filteredOrgs[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let orgDetail = OrgDetailPage(organization: filteredOrgs[indexPath.row])
        orgDetail.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(orgDetail, animated: true)
    }
}

extension OrganizationsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.updateFiltered()
    }
    
    private func updateFiltered() {
        let searchText = searchController.searchBar.text!.lowercased()
        let tabName = topTab.titleForSegment(at: topTab.selectedSegmentIndex)!
        DispatchQueue.global(qos: .default).async {
            self.filteredOrgs = self.organizations.filter { (org: Organization) -> Bool in
                
                var contains = false
                
                for target in [org.title, org.orgDescription] {
                    if target.lowercased().contains(searchText) {
                        contains = true
                    }
                }
                
                if !contains && !searchText.isEmpty { return false }
                
                if tabName == "Recommended" {
                    return !org.tags.intersection(User.current!.tags).isEmpty
                } else if tabName == "Subscribed" {
                    return User.current?.subscriptions.contains(org.id) ?? false
                }
                
                return true
            }
            
            self.filteredOrgs.sort(by: { $0.title.lowercased() < $1.title.lowercased() })
            
            DispatchQueue.main.async {
                self.orgTable.reloadSections([0], with: .none)
            }
        }
        
    }
}
