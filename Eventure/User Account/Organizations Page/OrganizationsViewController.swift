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

    private let searchController = UISearchController(searchResultsController: nil)
    
    private var topTabBg: UIVisualEffectView!
    private var topTab: UISegmentedControl!
    private var spinner: UIActivityIndicatorView!
    private var spinnerLabel: UILabel!
    private var orgTable: UITableView!
    
    private var organizations = [OrgOverview]() {
        didSet {
            DispatchQueue.main.async {
                self.updateFiltered()
            }
        }
    }
    private var filteredOrgs = [OrgOverview]()
    
    private var isFiltering: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    
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
        definesPresentationContext = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(loadOrganizations))
        
        
        topTabBg = {
            let ev = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
            ev.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(ev)
            
            ev.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            ev.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            ev.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            ev.heightAnchor.constraint(equalToConstant: 60).isActive = true
            
            return ev
        }()
        
        topTab = {
            let tab = UISegmentedControl(items: ["All", "Recommended",  "Membership"])
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
        
        loadOrganizations()
    }
    
    
    @objc private func loadOrganizations() {
        
        spinner.startAnimating()
        spinnerLabel.isHidden = false
        organizations.removeAll()
        DispatchQueue.main.async {
            self.orgTable.reloadData()
        }
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "account/ListOrgs", parameters: [:])!
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
                    internetUnavailableError(vc: self, handler: nil)
                }
                return
            }
            
            if let orgs = try? JSON(data: data!).arrayValue {
                self.organizations.removeAll()
                var tmp = [OrgOverview]()
                for org in orgs {
                    let orgObj = OrgOverview(json: org)
                    self.getLogoImage(for: orgObj)
                    tmp.append(orgObj)
                }
                self.organizations = tmp
                DispatchQueue.main.async {
                    self.orgTable.reloadSections(IndexSet(arrayLiteral: 0), with: .none)
                }
            } else {
                DispatchQueue.main.async {
                    serverMaintenanceError(vc: self)
                }
            }
        }
        
        task.resume()
    }
    
    /// Load the logo image for an organization.
    private func getLogoImage(for org: OrgOverview) {
        if !org.hasLogo { return }
        
        print("Getting logo image for \(org.title)...")
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/GetLogo",
                           parameters: ["id": org.id])!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                return // Don't display any alert here
            }
            
            org.logoImage = UIImage(data: data!)
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
        
        filteredOrgs[indexPath.row].logoUpdater = { [weak cell] image in
            DispatchQueue.main.async {
                if image != nil {
                    cell?.logoImage.image = image
                    cell?.logoImage.backgroundColor = nil
                } else {
                    cell?.logoImage.backgroundColor = LINE_TINT
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let orgDetail = OrgDetailPage()
        orgDetail.hidesBottomBarWhenPushed = true
        orgDetail.orgOverview = filteredOrgs[indexPath.row]
        navigationController?.pushViewController(orgDetail, animated: true)
    }
}


extension OrganizationsViewController {
    class OrgOverview {
        let id: String
        let title: String
        let tags: Set<String>
        let hasLogo: Bool
        let members: [Int: Organization.MemberRole]
        var logoImage: UIImage? {
            didSet {
                logoUpdater?(logoImage)
            }
        }
        
        /// An optional function to be called when the logo image is loaded.
        var logoUpdater: ((UIImage?) -> Void)?
        
        init(json: JSON) {
            let dictionary = json.dictionary!
            self.id = dictionary["ID"]?.string ?? ""
            self.title = dictionary["Title"]?.string ?? "Untitled"
            self.hasLogo = (dictionary["Has logo"]?.int ?? 0) == 1
            
            if let tags_raw = dictionary["Tags"]?.string {
                tags = Set(JSON(parseJSON: tags_raw).arrayObject as! [String])
            } else {
                tags = []
            }
            
            if let members_raw = dictionary["Members"]?.string {
                var tmp = [Int: Organization.MemberRole]()
                for pair in JSON(parseJSON: members_raw).dictionaryValue {
                    tmp[Int(pair.key)!] = Organization.MemberRole(rawValue: pair.value.stringValue)
                }
                members = tmp
            } else {
                members = [:]
            }
        }
    }
}

extension OrganizationsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        DispatchQueue.main.async {
            self.updateFiltered()
            self.orgTable.reloadData()
        }
    }
    
    private func updateFiltered() {
        let searchText = searchController.searchBar.text!.lowercased()
        filteredOrgs = organizations.filter { (org: OrgOverview) -> Bool in
            let tabName = topTab.titleForSegment(at: topTab.selectedSegmentIndex)!
            var condition = true
            if tabName == "Recommended" {
                condition = !org.tags.intersection(User.current!.tags).isEmpty
            } else if tabName == "Membership" {
                condition = org.members.keys.contains(User.current!.uuid)
            }
            
            return condition && (searchText.isEmpty || org.title.lowercased().contains(searchText))
        }
        
        filteredOrgs.sort(by: { $0.title < $1.title })
    }
}
