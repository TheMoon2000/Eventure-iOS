//
//  CheckedInEvents.swift
//  Eventure
//
//  Created by jeffhe on 2019/9/3.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class CheckedInEvents: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    static var changed: Bool = false
    
    private var myTableView: UITableView!
    
    private var spinner: UIActivityIndicatorView!
    private var spinnerLabel: UILabel!
    
    private var backGroundLabel: UILabel!
    
    private var recordDictionaryList = [CheckinRecord]()
    private var eventUUIDList = [String]()
    private var eventToIndex = [CheckinRecord : IndexPath]()
    
    private var today = [CheckinRecord]()
    private var tomorrow = [CheckinRecord]()
    private var thisWeek = [CheckinRecord]()
    private var future = [CheckinRecord]()
    private var past = [CheckinRecord]()
    
    private var sections = 0
    private var labels = [String]()
    private var displayedRecords = [[CheckinRecord]]()
    private var rowsForSection = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Events I Checked In"
        
        spinner = {
            let spinner = UIActivityIndicatorView(style: .whiteLarge)
            spinner.color = .lightGray
            spinner.hidesWhenStopped = true
            spinner.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(spinner)
            
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -5).isActive = true
            
            return spinner
        }()
        
        spinnerLabel = {
            let label = UILabel()
            label.text = "Updating..."
            label.isHidden = true
            label.font = .systemFont(ofSize: 17, weight: .medium)
            label.textColor = .darkGray
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: spinner.centerXAnchor).isActive = true
            label.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 10).isActive = true
            
            return label
        }()
        
        backGroundLabel = {
            let label = UILabel()
            label.text = "Oops, nothing here..."
            label.isHidden = true
            label.font = .systemFont(ofSize: 17, weight: .medium)
            label.textColor = .darkGray
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: spinner.centerXAnchor).isActive = true
            label.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 10).isActive = true
            
            return label
        }()
        
        
        retrieveEvents()
        
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        
        myTableView = UITableView(frame: .zero, style: .grouped)
        myTableView.dataSource = self
        myTableView.delegate = self
        myTableView.backgroundColor = UIColor.init(white: 0.95, alpha: 1)
        self.view.addSubview(myTableView)
        //set location constraints of the tableview
        myTableView.translatesAutoresizingMaskIntoConstraints = false
        myTableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        myTableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        myTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        myTableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        self.view.bringSubviewToFront(spinnerLabel)
        self.view.bringSubviewToFront(spinner)
        self.view.bringSubviewToFront(backGroundLabel)
        
        
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let eventUUID = displayedRecords[indexPath.section][indexPath.row].sheetID
        
        spinner.startAnimating()
        spinnerLabel.text = "Retrieving..."
        spinnerLabel.isHidden = false
        
        var parameters = [String : String]()
        parameters["uuid"] = eventUUID
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/GetEvent", parameters: parameters)!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                DispatchQueue.main.async {
                    internetUnavailableError(vc: self)
                    self.navigationController?.popViewController(animated: true)
                }
                return
            }
            
            if let eventDictionary = try? JSON(data: data!){
                let event = Event(eventInfo: eventDictionary)
                
                event.getCover { eventWithImage in
                    self.spinner.stopAnimating()
                    self.spinnerLabel.isHidden = true
                    let detailPage = EventDetailPage()
                    detailPage.hidesBottomBarWhenPushed = true
                    detailPage.event = eventWithImage
                    self.navigationController?.pushViewController(detailPage, animated: true)
                }
                
                DispatchQueue.main.async {
                    
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
        
        print(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let record = displayedRecords[indexPath.section][indexPath.row]
        eventToIndex[record] = indexPath
        
        let cell = EventsCell()
        cell.titleLabel.text = record.eventTitle
        
        cell.dateLabel.text = "Checked in at " + record.checkedInDate.readableString()
        
        if record.coverImage != nil {
            cell.icon.image = record.coverImage
        } else {
            cell.icon.image = #imageLiteral(resourceName: "cover_placeholder")
            record.getCover { recordWithCover in
                cell.icon.image = recordWithCover.coverImage
            }
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
        
        spinner.startAnimating()
        spinnerLabel.isHidden = false
        
        
        
        var parameters = [String : String]()
        if User.current != nil {
            parameters["userId"] = String(User.current!.uuid)
        }
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/GetCheckedInEvents", parameters: parameters)!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.spinnerLabel.isHidden = true
            }
            
            guard error == nil else {
                DispatchQueue.main.async {
                    internetUnavailableError(vc: self)
                    self.navigationController?.popViewController(animated: true)
                }
                return
            }
            
            if let recordList = try? JSON(data: data!).arrayValue {
                for record in recordList {
                    self.recordDictionaryList.append(CheckinRecord(json: record))
                }
                
                //group events according to their time
                self.groupEventsTime()
                
                DispatchQueue.main.async {
                    if (self.recordDictionaryList.count == 0) {
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
        
        let today = Date()
        let calender = Calendar.current
        for record in recordDictionaryList {
            let eventDateComponents = calender.dateComponents([.year, .month, .day, .hour, .minute, .second], from: record.checkedInDate)
            let todayDateComponents = calender.dateComponents([.year, .month, .day, .hour, .minute, .second], from: today)
            let isSameYear = eventDateComponents.year == todayDateComponents.year
            let isSameMonth = eventDateComponents.month == todayDateComponents.month
            let isSameDay = eventDateComponents.day == todayDateComponents.day
            
            if (isSameDay && isSameYear && isSameMonth) {
                self.today.append(record)
            } else if (isSameYear && isSameMonth && (eventDateComponents.day! - todayDateComponents.day! == 1)) {
                self.tomorrow.append(record)
            } else if (isSameYear && isSameMonth && (eventDateComponents.day! - todayDateComponents.day! <= 7)) {
                self.thisWeek.append(record)
            } else if (record.checkedInDate > today) {
                self.future.append(record)
            } else {
                self.past.append(record)
            }
        }
        
        let sortFunction: ((CheckinRecord, CheckinRecord) -> Bool) = {
            return $0.checkedInDate < $1.checkedInDate
        }
        
        self.today = self.today.sorted(by: sortFunction)
        self.tomorrow = self.tomorrow.sorted(by: sortFunction)
        self.thisWeek = self.thisWeek.sorted(by: sortFunction)
        self.future = self.future.sorted(by: sortFunction)
        self.past = self.past.sorted(by: sortFunction)
        
        if self.today.count > 0 {
            sections += 1
            labels.append("Today")
            displayedRecords.append(self.today)
            rowsForSection.append(self.today.count)
        }
        if self.tomorrow.count > 0 {
            sections += 1
            labels.append("Tomorrow")
            displayedRecords.append(self.tomorrow)
            rowsForSection.append(self.tomorrow.count)
        }
        if self.thisWeek.count > 0 {
            sections += 1
            labels.append("This Week")
            displayedRecords.append(self.thisWeek)
            rowsForSection.append(self.thisWeek.count)
        }
        if self.future.count > 0 {
            sections += 1
            labels.append("In the future...")
            displayedRecords.append(self.future)
            rowsForSection.append(self.future.count)
        }
        if self.past.count > 0 {
            sections += 1
            labels.append("Past Events")
            displayedRecords.append(self.past)
            rowsForSection.append(self.past.count)
        }
        
    }
    
    
    
    func clearAll() {
        today.removeAll()
        tomorrow.removeAll()
        thisWeek.removeAll()
        future.removeAll()
        past.removeAll()
        
        sections = 0
        labels.removeAll()
        displayedRecords.removeAll()
        rowsForSection.removeAll()
        
        recordDictionaryList.removeAll()
        eventToIndex.removeAll()
        
    }
    
    // Unused
    /*
    func retrieveSingleEvent(UUID: String) {
    
        
        var parameters = [String : String]()
        if User.current != nil {
            parameters["uuid"] = UUID
        }
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/GetEvent", parameters: parameters)!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                DispatchQueue.main.async {
                    internetUnavailableError(vc: self)
                    self.navigationController?.popViewController(animated: true)
                }
                return
            }
            
            if let eventDictionary = try? JSON(data: data!){
                let event = Event(eventInfo: eventDictionary)
                
                event.getCover { eventWithImage in
                    if let index = self.eventToIndex[event] {
                        if let cell = self.myTableView.cellForRow(at: index) as? EventsCell {
                            cell.icon.image = eventWithImage.eventVisual
                        }
                    }
                }
                
                self.eventDictionaryList.append(event)
                
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
        
    }*/
   
}
