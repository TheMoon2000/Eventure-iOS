//
//  LikedEvents.swift
//  Eventure
//
//  Created by jeffhe on 2019/9/1.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class LikedEvents: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    static var changed: Bool = false
    
    private var myTableView: UITableView!
    
    private var loadingBG: UIView!
    private var backGroundLabel: UILabel!
    
    private var eventUUIDList: Set<String> = User.current!.favoritedEvents
    private var eventDictionaryList = [Event]()
    private var eventToIndex = [Event : IndexPath]()
    
    private var today = [Event]()
    private var tomorrow = [Event]()
    private var last7Days = [Event]()
    private var future = [Event]()
    private var past = [Event]()
    
    private var sections = 0
    private var labels = [String]()
    private var displayedEvents = [[Event]]()
    private var rowsForSection = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Favorites"
        
        // Do any additional setup after loading the view.
        view.backgroundColor = AppColors.canvas
        
        myTableView = {
            let tv = UITableView(frame: .zero, style: .grouped)
            tv.dataSource = self
            tv.delegate = self
            tv.backgroundColor = .clear
            view.addSubview(tv)

            tv.translatesAutoresizingMaskIntoConstraints = false
            tv.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            tv.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            tv.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            tv.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            
            return tv
        }()
        
        backGroundLabel = {
            let label = UILabel()
            label.text = "No favorited events."
            label.isHidden = true
            label.font = .systemFont(ofSize: 17)
            label.textColor = .gray
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: myTableView.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: myTableView.centerYAnchor).isActive = true
            
            return label
        }()
        
        loadingBG = view.addLoader()
        loadingBG.centerXAnchor.constraint(equalTo: myTableView.centerXAnchor).isActive = true
        loadingBG.centerYAnchor.constraint(equalTo: myTableView.centerYAnchor).isActive = true
        
        retrieveEvents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if LikedEvents.changed {
            clearAll()
            viewDidLoad()
            LikedEvents.changed = false
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let detailPage = SubscribedEventDetailPage()
        //let detailPage = EventDetailPage()
        detailPage.hidesBottomBarWhenPushed = true
        detailPage.event = displayedEvents[indexPath.section][indexPath.row]
        navigationController?.pushViewController(detailPage, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let event = displayedEvents[indexPath.section][indexPath.row]
        eventToIndex[event] = indexPath
        
        let cell = EventsCell()
        cell.titleLabel.text = event.title
        
        cell.setTime(for: event)
        
        if event.eventVisual != nil {
            cell.icon.image = event.eventVisual
        } else if !event.hasVisual {
            cell.icon.image = #imageLiteral(resourceName: "berkeley")
        } else {
            cell.icon.image = #imageLiteral(resourceName: "cover_placeholder")
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {return sections}
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {return labels[section]}
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int {return rowsForSection[section]}
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {return 50}
        return 30
    }
    
    func retrieveEvents() {
        
        loadingBG.isHidden = false
        
        var parameters = [String : String]()
        if User.current != nil {
            parameters["userId"] = String(User.current!.uuid)
        }
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/List", parameters: parameters)!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            DispatchQueue.main.async {
                self.loadingBG.isHidden = true
            }
            
            guard error == nil else {
                DispatchQueue.main.async {
                    internetUnavailableError(vc: self)
                    self.navigationController?.popViewController(animated: true)
                }
                return
            }
            
            if let eventsList = try? JSON(data: data!).arrayValue {
                for eventData in eventsList {
                    if (eventData.dictionary?["Is favorited"]?.bool ?? false)! {
                        let event = Event(eventInfo: eventData)
                        
                        event.getCover { eventWithImage in
                            if let index = self.eventToIndex[event] {
                                if let cell = self.myTableView.cellForRow(at: index) as? EventsCell {
                                    cell.icon.image = eventWithImage.eventVisual
                                }
                            }
                        }
                        
                        self.eventDictionaryList.append(event)
                    }
                }
                
                //group events according to their time
                self.groupEventsTime()
                
                DispatchQueue.main.async {
                    if (self.eventDictionaryList.count == 0) {
                        self.backGroundLabel.isHidden = false
                    }
                    self.myTableView.reloadData()
                }
            } else {
                print("Unable to parse '\(String(data: data!, encoding: .utf8)!)'")
                
                if String(data: data!, encoding: .utf8) == INTERNAL_ERROR {
                    DispatchQueue.main.async {
                        serverMaintenanceError(vc: self)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
        
        task.resume()
    }
    
    func groupEventsTime() {
        
        let todayMidnight = Date().midnight
        for event in eventDictionaryList {
            // Use the information below to group events by time
            
            if event.startTime == nil {
                self.past.append(event)
                continue
            }
            
            let eventMidnight = event.startTime!.midnight
            let offset = eventMidnight.timeIntervalSince(todayMidnight)
            
            if todayMidnight.compare(eventMidnight) == .orderedSame {
                self.today.append(event)
            } else if offset == 24 * 3600 {
                self.tomorrow.append(event) // Exactly tomorrow
            } else if offset > 24 * 3600 {
                self.future.append(event)
            } else if offset >= -7 * 86400 {
                self.last7Days.append(event)
            } else {
                self.past.append(event)
            }
        }
        
        // Sort all the groups
        today.sort { Event.oldestFirst($0, $1) }
        tomorrow.sort { Event.oldestFirst($0, $1) }
        last7Days.sort { Event.lastestFirst($0, $1) }
        future.sort { Event.oldestFirst($0, $1) }
        past.sort { Event.lastestFirst($0, $1) }
        
        if self.today.count > 0 {
            sections += 1
            labels.append("Today")
            displayedEvents.append(self.today)
            rowsForSection.append(self.today.count)
        }
        if self.tomorrow.count > 0 {
            sections += 1
            labels.append("Tomorrow")
            displayedEvents.append(self.tomorrow)
            rowsForSection.append(self.tomorrow.count)
        }
        if self.last7Days.count > 0 {
            sections += 1
            labels.append("Last 7 days")
            displayedEvents.append(self.last7Days)
            rowsForSection.append(self.last7Days.count)
        }
        if self.future.count > 0 {
            sections += 1
            labels.append("Coming up")
            displayedEvents.append(self.future)
            rowsForSection.append(self.future.count)
        }
        if self.past.count > 0 {
            sections += 1
            labels.append("Past Events")
            displayedEvents.append(self.past)
            rowsForSection.append(self.past.count)
        }
        
    }
    

    
    func clearAll() {
        today.removeAll()
        tomorrow.removeAll()
        last7Days.removeAll()
        future.removeAll()
        past.removeAll()
        
        sections = 0
        labels.removeAll()
        displayedEvents.removeAll()
        rowsForSection.removeAll()
        
        eventUUIDList.removeAll()
        eventDictionaryList.removeAll()
        eventToIndex.removeAll()
        
    }
}


class SubscribedEventDetailPage: EventDetailPage {
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !User.current!.favoritedEvents.contains(event.uuid) {
            LikedEvents.changed = true
        }
    }
}

