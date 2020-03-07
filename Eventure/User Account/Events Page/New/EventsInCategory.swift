//
//  EventsInCategory.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/2/10.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class EventsInCategory: UIViewController, EventProvider {

    private var allEvents = [Event]()
    private var displayLimit = 20
    
    var eventsForSearch: [Event] {
        return allEvents
    }
    
    private var category: Tag!
    private var eventsTable: UITableView!
    private var loadingBG: UIVisualEffectView!
    private var emptyLabel: UILabel!
    
    // Time bounds
    var start: Date?
    var end: Date?
    
    
    init(category: Tag) {
        super.init(nibName: nil, bundle: nil)
        self.category = category
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = category.name
        view.backgroundColor = AppColors.tableBG
        
        navigationItem.rightBarButtonItem = .init(image: #imageLiteral(resourceName: "options"), style: .plain, target: self, action: #selector(openOptions))
        
        setup()
        loadEvents()
    }
    
    private func setup() {
        eventsTable = {
            let tv = UITableView()
            tv.dataSource = self
            tv.delegate = self
            (tv as UIScrollView).delegate = self
            tv.tableFooterView = UIView()
            tv.backgroundColor = .clear
            tv.separatorStyle = .none
            tv.contentInset.top = 5
            tv.contentInset.bottom = 5
            tv.register(EventOverviewTableCell.classForCoder(), forCellReuseIdentifier: "event")
            tv.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(tv)
            
            tv.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            tv.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            tv.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            tv.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            return tv
        }()
        
        let rc = UIRefreshControl()
        rc.tintColor = AppColors.lightControl
        rc.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        eventsTable.refreshControl = rc
        
        
        loadingBG = view.addLoader()
        loadingBG.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        loadingBG.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        emptyLabel = {
            let label = UILabel()
            label.textColor = .gray
            label.font = .appFontRegular(17)
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: loadingBG.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: loadingBG.centerYAnchor).isActive = true
            
            return label
        }()
    }
    
    func fetchEventsIfNeeded() {
        loadEvents()
    }
    
    private func loadEvents(_ pulled: Bool = false) {
        
        if !pulled {
            loadingBG.isHidden = false
        }
        
        emptyLabel.text = ""
        
        var parameters = ["categoryId": String(category.id)]
        
        if User.current != nil {
            parameters["userId"] = String(User.current!.uuid)
            parameters["userEmail"] = User.current!.email
        }
        
        if let start = self.start {
            parameters["lowerBound"] = DATE_FORMATTER.string(from: start)
        } else {
            parameters["lowerBound"] = DATE_FORMATTER.string(from: Date())
        }
        
        if let end = self.end {
            parameters["upperBound"] = DATE_FORMATTER.string(from: end)
        } else {
            parameters["upperBound"] = DATE_FORMATTER.string(from: .distantFuture)
        }
       
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/List",
                           parameters: parameters)!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            DispatchQueue.main.async {
                self.eventsTable.refreshControl?.endRefreshing()
            }
            
            guard error == nil else {
                DispatchQueue.main.async {
                    self.loadingBG.isHidden = true
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
                    print("Loaded \(tmp.count) events for category \"\(self.category.name)\"")
                    
                    DispatchQueue.main.async {
                        self.loadingBG.isHidden = true
                        self.eventsTable.reloadData()
                        if tmp.isEmpty {
                            self.emptyLabel.text = "No events."
                        }
                    }
                }
            } else {
                print("Unable to parse '\(String(data: data!, encoding: .utf8)!)'")

                DispatchQueue.main.async {
                    self.loadingBG.isHidden = true
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
    
    @objc private func pullToRefresh() {
        loadEvents(true)
    }

    @objc private func openOptions() {
        let filterTable = FilterDateTableViewController(parentVC: self)
        let nav = UINavigationController(rootViewController:
            filterTable)
        nav.navigationBar.customize()
        present(nav, animated: true)
    }
    
}


extension EventsInCategory: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(allEvents.count, displayLimit)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = EventOverviewTableCell()
        cell.eventTitle.text = allEvents[indexPath.row].title
        cell.dateTime.text = allEvents[indexPath.row].timeDescription
        cell.location.text = allEvents[indexPath.row].location
        
        Organization.getLogoImage(orgID: allEvents[indexPath.row].hostID) { image in
            cell.orgLogo.backgroundColor = nil
            if image == UIImage.empty {
                cell.orgLogo.image = #imageLiteral(resourceName: "group").withRenderingMode(.alwaysTemplate)
            } else {
                cell.orgLogo.image = image ?? #imageLiteral(resourceName: "group").withRenderingMode(.alwaysTemplate)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = tableView.dequeueReusableCell(withIdentifier: "event", for: indexPath) as! EventOverviewTableCell
        cell.eventTitle.text = allEvents[indexPath.row].title
        cell.dateTime.text = allEvents[indexPath.row].timeDescription
        cell.location.text = allEvents[indexPath.row].location
        
        return cell.preferredHeight(width: tableView.frame.width)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let detailPage = EventDetailPage()
        detailPage.interestedStatusChanged = { status in
            print(status)
        }
        detailPage.event = allEvents[indexPath.row]
        detailPage.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailPage, animated: true)
    }
}

extension EventsInCategory: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // UITableView only moves in one direction, y axis
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height

        if maximumOffset - currentOffset <= 30.0 {
            if displayLimit < allEvents.count {
                
                let indices: [IndexPath] = (displayLimit..<min(displayLimit + 10, allEvents.count)).map { [0, $0] }
                
                displayLimit += 10
                eventsTable.insertRows(at: indices, with: .fade)
                
            }
        }
    }
}
