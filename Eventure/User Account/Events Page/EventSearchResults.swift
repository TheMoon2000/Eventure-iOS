//
//  EventSearchResults.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/3.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class EventSearchResults: UITableViewController, UISearchResultsUpdating {
    
    private var parentVC: EventProvider!
    var allEvents: [Event] {
        return parentVC.eventsForSearch
    }
    var filteredEvents = [Event]()
    
    private var emptyLabel: UILabel!
    
    required init(parentVC: EventProvider) {
        super.init(nibName: nil, bundle: nil)
        
        self.parentVC = parentVC
        
        emptyLabel = {
            let label = UILabel()
            label.isHidden = true
            label.text = "No search results."
            label.textAlignment = .center
            label.textColor = AppColors.prompt
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
            
            return label
        }()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = AppColors.canvas
        tableView.tableFooterView = UIView()
        tableView.register(EventsCell.classForCoder(), forCellReuseIdentifier: "event")
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        emptyLabel?.isHidden = !filteredEvents.isEmpty
        
        return filteredEvents.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "event") as! EventsCell
        
        let thisEvent = filteredEvents[indexPath.row]
        
        cell.titleLabel.text = thisEvent.title
        cell.setTime(for: thisEvent)
        if let cover = thisEvent.eventVisual {
            cell.icon.image = cover
        } else {
            cell.icon.image = #imageLiteral(resourceName: "cover_placeholder")
            thisEvent.getCover { eventWithVisual in
                cell.icon.image = eventWithVisual.eventVisual
            }
        }
        
        return cell
    }

    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text!.lowercased()
        
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
//                print("\(self.filteredEvents.count) / \(self.allEvents.count) displayed")
                self.tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .none)
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
