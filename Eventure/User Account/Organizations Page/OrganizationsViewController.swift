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

    // Pull to refresh
    private var refreshControl = UIRefreshControl()
    
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
    
    var customPushHandler: ((Organization) -> ())?
    
    /// The list of organizations that are actually displayed.
    private var filteredOrgs = [Organization]()
    
    /// A subset of organizations that are recommended for the user, ordered by the size of the intersection between the user's tags and the org's tags.
    private var recommendedOrgs = [Organization]()
    
    private var isFiltering: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    
    // The search bar
    private let searchController = UISearchController(searchResultsController: nil)
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .dark {
                topTabBg.effect = UIBlurEffect(style: .regular)
            } else {
                topTabBg.effect = UIBlurEffect(style: .extraLight)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = AppColors.canvas
        title = "Organizations"
        
        // Search bar setup
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = AppColors.main
        searchController.searchBar.placeholder = "Search Organizations"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        
        if #available(iOS 13.0, *) {
            searchController.searchBar.searchTextField.font = .appFontRegular(17)
        }
        
        refreshControl.tintColor = AppColors.lightControl
        refreshControl.addTarget(self, action: #selector(loadOrganizations), for: .valueChanged)
                
        topTabBg = {
            let ev = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
            
            if #available(iOS 12.0, *) {
                if traitCollection.userInterfaceStyle == .dark {
                    ev.effect = UIBlurEffect(style: .regular)
                }
            }
            
            ev.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(ev)
            
            ev.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            ev.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            ev.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            ev.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            return ev
        }()
        
        topTab = {
            let tab = UISegmentedControl(items: ["All", "Subscribed",  "My Clubs"])
            if User.current == nil {
                tab.setEnabled(false, forSegmentAt: 1)
                tab.setEnabled(false, forSegmentAt: 2)
            }
            tab.setTitleTextAttributes([.font: UIFont.appFontMedium(15.5)], for: .normal)
            tab.tintColor = AppColors.main
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
            orgTable.contentInsetAdjustmentBehavior = .always
            orgTable.contentInset.top = 50
            orgTable.scrollIndicatorInsets.top = 50
            orgTable.backgroundColor = .clear
            orgTable.addSubview(refreshControl)
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
            spinner.color = AppColors.lightControl
            spinner.hidesWhenStopped = true
            spinner.startAnimating()
            spinner.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(spinner)
            
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            spinner.centerYAnchor.constraint(equalTo: orgTable.centerYAnchor, constant: -5).isActive = true
            
            return spinner
        }()
        
        spinnerLabel = {
            let label = UILabel()
            label.text = "Loading organizations..."
            label.font = .appFontRegular(17)
            label.textColor = .darkGray
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: spinner.centerXAnchor).isActive = true
            label.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 10).isActive = true
            
            return label
        }()
        
        emptyLabel = {
            let label = UILabel()
            label.textColor = .gray
            label.font = .appFontRegular(17)
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: orgTable.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: orgTable.centerYAnchor).isActive = true
            
            return label
        }()
        
        loadOrganizations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.shadowImage = nil
    }
    
    @objc private func selectionChanged() {
        updateFiltered()
    }
    
    @objc private func loadOrganizations() {
        
        emptyLabel.text = ""
        
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
                self.refreshControl.endRefreshing()
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
        if User.current != nil && topTab.selectedSegmentIndex == 0 {
            return 2
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredOrgs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = OrganizationCell()
        cell.setup(with: filteredOrgs[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if customPushHandler != nil {
            customPushHandler?(filteredOrgs[indexPath.row])
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
            let orgDetail = OrgDetailPage(organization: filteredOrgs[indexPath.row])
            orgDetail.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(orgDetail, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView.numberOfSections == 1 || organizations.isEmpty { return 0 }
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if tableView.numberOfSections == 1 || organizations.isEmpty { return nil }
        
        let container = UIView()
        container.backgroundColor = AppColors.canvas.withAlphaComponent(0.92)
        
        let label = UILabel()
        label.layoutMargins.left = 10
        label.textColor = .gray
        if tableView.numberOfSections == 2 {
            label.text = ["Recommended", "All Organizations"][section]
        } else {
            label.text = "All Organizations"
        }
        label.font = .appFontRegular(14)
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        
        label.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 6).isActive = true
        label.topAnchor.constraint(equalTo: container.topAnchor, constant: 3).isActive = true
        label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -2).isActive = true
        
        return container
    }
}

extension OrganizationsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.updateFiltered(animated: false)
    }
    
    private func updateFiltered(animated: Bool = true) {
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
                
                if tabName == "Subscribed" {
                    return org.subscribers.contains(User.current!.userID)
                } else if tabName == "My Clubs" {
                    return User.current?.memberships.contains { $0.orgID == org.id } ?? false
                }
                
                return true
            }
            
            self.filteredOrgs.sort(by: { $0.title.lowercased() < $1.title.lowercased() })
                        
            if let current = User.current {
                let rec = self.organizations.filter { org in
                    return !org.tags.intersection(current.tags).isEmpty
                }
                self.recommendedOrgs = rec.sorted { org1, org2 in
                    let in1 = org1.tags.intersection(current.tags).count
                    let in2 = org2.tags.intersection(current.tags).count
                    if in1 != in2 { return in1 > in2 }
                    return org1.title.lowercased() <= org2.title.lowercased()
                }
            }
            
            DispatchQueue.main.async {
                self.emptyLabel.text = self.filteredOrgs.isEmpty ? "No Organizations" : ""
                let begin = (self.orgTable.numberOfSections, self.numberOfSections(in: self.orgTable))
                if begin.0 == begin.1 {
                    self.orgTable.reloadSections(IndexSet(integersIn: 0..<self.orgTable.numberOfSections), with: .none)
                } else if begin.1 > begin.0 {
                    self.orgTable.beginUpdates()
                    self.orgTable.insertSections([1], with: .fade)
                    self.orgTable.reloadSections([0], with: .fade)
                    self.orgTable.endUpdates()
                } else {
                    self.orgTable.beginUpdates()
                    self.orgTable.deleteSections([1], with: .fade)
                    self.orgTable.reloadSections([0], with: .fade)
                    self.orgTable.endUpdates()
                }
            }
        }
        
    }
}
