//
//  EventSearchResults.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/3.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class NewEventSearchResults: UITableViewController, UISearchResultsUpdating {
    
    private var parentVC: EventHomePage!
    var allEvents = [Event]()
    var filteredEvents = [Event]()
    var finishedFetching = false
    
    private var LOADING = "Loading events..."
    private var emptyLabel: UILabel!
    
    required init(parentVC: EventHomePage) {
        super.init(nibName: nil, bundle: nil)
        
        self.parentVC = parentVC
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = AppColors.canvas
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.contentInset.top = 5
        tableView.contentInset.bottom = 5
        
        emptyLabel = {
            let label = UILabel()
            label.text = "Type keyword to search"
            label.textAlignment = .center
            label.textColor = AppColors.prompt
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
            
            return label
        }()
        
        
        loadEvents()
    }
    
    private func loadEvents() {
        emptyLabel.text = LOADING
        
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
                        self.updateSearchResults(for: self.parentVC.searchController)
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

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        emptyLabel?.isHidden = !filteredEvents.isEmpty
        
        return filteredEvents.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = EventOverviewTableCell()
        
        let thisEvent = filteredEvents[indexPath.row]
        
        cell.eventTitle.text = thisEvent.title
        cell.dateTime.text = thisEvent.timeDescription
        cell.location.text = thisEvent.location
        
        Organization.getLogoImage(orgID: thisEvent.hostID) { image in
            cell.orgLogo.backgroundColor = nil
            if image == UIImage.empty {
                cell.orgLogo.image = #imageLiteral(resourceName: "group").withRenderingMode(.alwaysTemplate)
            } else {
                cell.orgLogo.image = image ?? #imageLiteral(resourceName: "group").withRenderingMode(.alwaysTemplate)
            }
        }
        
        return cell
    }

    func updateSearchResults(for searchController: UISearchController) {
        searchController.searchResultsController?.view.isHidden = false
        let searchString = searchController.searchBar.text!.lowercased()
        
        guard finishedFetching else {
            emptyLabel.text = LOADING
            return
        }
        
        guard !searchString.isEmpty else {
            filteredEvents = []
            emptyLabel.text = "Type to search."
            return
        }
        
        DispatchQueue.global(qos: .default).async {
            self.filteredEvents = self.allEvents.filter { event in
                if searchString.isEmpty { return true }
                
                for target in [event.title, event.eventDescription, event.hostTitle, event.location] {
                    if target.lowercased().contains(searchString) {
                        return true
                    }
                }
                
                return false
            }
            DispatchQueue.main.async {
                self.tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .automatic)
                if self.filteredEvents.isEmpty {
                    self.emptyLabel.text = "No events found."
                } else {
                    self.emptyLabel.text = ""
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let detailPage = EventDetailPage()
        detailPage.hidesBottomBarWhenPushed = true
        detailPage.event = filteredEvents[indexPath.row]
        if let oe = parentVC as? OrgEventViewController {
            detailPage.orgEventView = oe
        }
        parentVC.navigationController?.pushViewController(detailPage, animated: true)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
