//
//  EventSearchView.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/3/12.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class EventSearchView: UIViewController {
    
    private var emptyLabel: UILabel!
    private var loadingBG: UIView!
    
    private var titleView: UIView!
    private var searchBar: UISearchBar!
    private var cancelButton: UIButton!
    
    private var keywordsTable: UITableView!
    private var eventsTable: UITableView!
    
    private var allEvents = [Event]()
    private var filteredEvents = [Event]()
    private var finishedFetching = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Search"
        
        view.backgroundColor = AppColors.tableBG

        loadingBG = view.addLoader()
        loadingBG.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        loadingBG.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        titleView = {
            let v = UIView()
            v.translatesAutoresizingMaskIntoConstraints = false
            
            v.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
            v.heightAnchor.constraint(equalToConstant: 42).isActive = true
            
            return v
        }()
        
        
        cancelButton = {
            let button = UIButton(type: .system)
            button.setTitle("Cancel", for: .normal)
            button.titleLabel?.font = .appFontMedium(17)
            button.tintColor = AppColors.main
            button.translatesAutoresizingMaskIntoConstraints = false
            titleView.addSubview(button)
            
            button.rightAnchor.constraint(equalTo: titleView.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
            
            button.addTarget(self, action: #selector(cancelSearch), for: .touchUpInside)
            
            return button
        }()

        
        searchBar = {
            let sb = UISearchBar()
            sb.placeholder = "Search Events..."
//            sb.backgroundImage = UIImage()
            sb.autocorrectionType = .no
            sb.tintColor = AppColors.main
//            sb.backgroundColor = .clear
            sb.delegate = self
            
            if #available(iOS 13.0, *) {
                sb.searchTextField.font = .appFontRegular(17)
            }
            
            sb.translatesAutoresizingMaskIntoConstraints = false
            titleView.addSubview(sb)
            
            sb.leftAnchor.constraint(equalTo: titleView.safeAreaLayoutGuide.leftAnchor, constant: 5).isActive = true
            sb.topAnchor.constraint(equalTo: titleView.safeAreaLayoutGuide.topAnchor, constant: 1).isActive = true
            sb.centerYAnchor.constraint(equalTo: cancelButton.centerYAnchor).isActive = true
            sb.bottomAnchor.constraint(equalTo: titleView.bottomAnchor).isActive = true
            sb.rightAnchor.constraint(equalTo: cancelButton.leftAnchor, constant: -5).isActive = true
            
            return sb
        }()
        
        keywordsTable = {
            let table = UITableView()
            table.delegate = self
            table.dataSource = self
            table.backgroundColor = AppColors.tableBG
            table.alwaysBounceVertical = true
            table.keyboardDismissMode = .interactive
            table.separatorColor = AppColors.line
            table.tableFooterView = UIView()
            table.translatesAutoresizingMaskIntoConstraints = false
            table.refreshControl = UIRefreshControl()
            table.refreshControl?.addTarget(self, action: #selector(refreshKeywords), for: .valueChanged)
            view.addSubview(table)
            
            table.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            table.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            table.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5).isActive = true
            let b = table.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            b.priority = .defaultHigh
            b.isActive = true
            
            return table
        }()
        
        eventsTable = {
            let table = UITableView()
            table.isHidden = true // Initially hidden
            table.separatorStyle = .none
            table.backgroundColor = .clear
            table.contentInset.bottom = 5
            table.delegate = self
            table.dataSource = self
            table.tableFooterView = UIView()
            table.alwaysBounceVertical = true
            table.register(EventOverviewTableCell.classForCoder(), forCellReuseIdentifier: "event")
            table.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(table)
            
            table.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            table.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            table.topAnchor.constraint(equalTo: keywordsTable.topAnchor).isActive = true
            let b = table.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            b.priority = .defaultHigh
            b.isActive = true
            
            return table
        }()
        
        emptyLabel = {
            let label = UILabel()
            label.textColor = .gray
            label.text = ""
            label.font = .appFontRegular(17)
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
            
            return label
        }()
        
        navigationItem.titleView = titleView
        
        searchBar.becomeFirstResponder()
        loadEvents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.barTintColor = AppColors.tableBG
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    @objc private func cancelSearch() {
        dismiss(animated: true)
    }
    
    private func loadEvents() {
        
        var parameters = [String: String]()
        
        if User.current != nil {
            parameters["userId"] = String(User.current!.uuid)
            parameters["userEmail"] = User.current!.email
        }
        parameters["lowerBound"] = DATE_FORMATTER.string(from: Date())
        parameters["upperBound"] = DATE_FORMATTER.string(from: .distantFuture)
       
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/List",
                           parameters: parameters)!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
                        
            guard error == nil else {
                DispatchQueue.main.async {
                    internetUnavailableError(vc: self)
                    self.emptyLabel.text = CONNECTION_ERROR
                }
                return
            }
            
            if let eventsList = try? JSON(data: data!).arrayValue {
                DispatchQueue.global(qos: .default).async {
                    var tmp = [Event]()
                    for event in eventsList {
                        let newEvent = Event(eventInfo: event)
                        if newEvent.isPublic || (User.current?.memberships.contains { $0.orgID == newEvent.hostID } ?? false) {
                            tmp.append(newEvent)
                        }
                    }
                    tmp.sort(by: { (e1: Event, e2: Event) -> Bool in
                        return (e1.startTime ?? Date.distantFuture) < (e2.startTime ?? Date.distantFuture)
                    })
                    
                    self.allEvents = tmp
                    self.finishedFetching = true
                    
                    DispatchQueue.main.async {
                        self.emptyLabel.text = ""
                    }
                }
            } else {
                print("Unable to parse '\(String(data: data!, encoding: .utf8)!)'")

                DispatchQueue.main.async {
                    self.emptyLabel.text = SERVER_ERROR
                }
                
                if String(data: data!, encoding: .utf8) == INTERNAL_ERROR {
                    DispatchQueue.main.async {
                        serverMaintenanceError(vc: self)
                    }
                }
            }
        }
        
        task.resume()
    }
    
    @objc private func refreshKeywords() {
        LocalStorage.updateKeywords { status in
            self.keywordsTable.refreshControl?.endRefreshing()
            
            if status == 0 {
                self.keywordsTable.reloadSections([0], with: .automatic)
            } else if status == -1 && (self.searchBar.text ?? "").isEmpty {
                self.emptyLabel.text = CONNECTION_ERROR
                internetUnavailableError(vc: self)
            } else if status == -2 && (self.searchBar.text ?? "").isEmpty {
                self.emptyLabel.text = SERVER_ERROR
                serverMaintenanceError(vc: self)
            }
        }
    }
}

// MARK - Table view data source & delegate

extension EventSearchView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == keywordsTable {
            return LocalStorage.keywords.count
        } else if tableView == eventsTable {
            return eventsTable.isHidden ? 0 : filteredEvents.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == keywordsTable {
            let cell = KeywordSuggestionCell()
            cell.keywordTitle.text = LocalStorage.keywords[indexPath.row]
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "event", for: indexPath) as! EventOverviewTableCell
            cell.eventTitle.text = filteredEvents[indexPath.row].title
            cell.dateTime.text = filteredEvents[indexPath.row].timeDescription
            cell.location.text = filteredEvents[indexPath.row].location
            cell.orgLogo.image = nil
            cell.orgLogo.backgroundColor = AppColors.disabled
            
            let currentTime = Date()
            cell.lastUpdatedTime = currentTime
            
            Organization.getLogoImage(orgID: filteredEvents[indexPath.row].hostID) { image in
                if cell.lastUpdatedTime != currentTime { return }
                cell.orgLogo.backgroundColor = nil
                if image == UIImage.empty {
                    cell.orgLogo.image = #imageLiteral(resourceName: "group").withRenderingMode(.alwaysTemplate)
                } else {
                    cell.orgLogo.image = image ?? #imageLiteral(resourceName: "group").withRenderingMode(.alwaysTemplate)
                }
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == keywordsTable {
            searchBar.text = LocalStorage.keywords[indexPath.row].lowercased()
            searchBar.resignFirstResponder()
            searchBar(searchBar, textDidChange: searchBar.text!)
        } else {
            let detailPage = EventDetailPage()
            detailPage.hidesBottomBarWhenPushed = true
            detailPage.event = filteredEvents[indexPath.row]
            navigationController?.pushViewController(detailPage, animated: true)
        }
    }
    
}


extension EventSearchView: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if CharacterSet(charactersIn: searchText).isSubset(of: .whitespacesAndNewlines) {
            keywordsTable.isHidden = false
            eventsTable.isHidden = true
            emptyLabel.text = ""
            eventsTable.reloadData()
            return
        }
        
        keywordsTable.isHidden = true
        eventsTable.isHidden = false
        
        guard finishedFetching else {
            emptyLabel.text = "Loading events..."
            return
        }
        
        let searchString = searchText.lowercased()
        
        DispatchQueue.global(qos: .default).async {
            self.filteredEvents = self.allEvents.filter { event in
                if searchString.isEmpty { return true }
                
                let tagNames = event.tags.map { LocalStorage.tags[$0]?.name ?? "" }

                for target in [event.title, event.eventDescription, event.hostTitle, event.location, tagNames.joined(separator: " ")] {
                    if target.lowercased().contains(searchString) {
                        return true
                    }
                }
                
                return false
            }
            DispatchQueue.main.async {
                self.eventsTable.reloadSections(IndexSet(arrayLiteral: 0), with: .automatic)
                if self.filteredEvents.isEmpty {
                    self.emptyLabel.text = "No events found."
                } else {
                    self.emptyLabel.text = ""
                }
            }
        }
        
    }
}
