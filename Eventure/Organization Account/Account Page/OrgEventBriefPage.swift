//
//  OrgEventBriefPage.swift
//  Eventure
//
//  Created by Prince Wang on 2019/9/2.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class OrgEventBriefPage: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //Variables here

    static var changed: Bool = false

    private var myTableView: UITableView!
    private var spinner: UIActivityIndicatorView!
    private var spinnerLabel: UILabel!
    private var backGroundLabel: UILabel!



    private var eventDictionaryList = [Event]()
    private var eventToIndex = [Event : IndexPath]()

    private var today = [Event]()
    private var tomorrow = [Event]()
    private var thisWeek = [Event]()
    private var future = [Event]()
    private var past = [Event]()

    private var sections = 0
    private var labels = [String]()
    private var displayedEvents = [[Event]]()
    private var rowsForSection = [Int]()

    //viewDidLoad and TableView here

    override func viewDidLoad() {
        super.viewDidLoad()


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
            label.text = "no events posted yet"
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

    override func viewWillAppear(_ animated: Bool) {
        if OrgEventBriefPage.changed {
            clearAll()
            viewDidLoad()
            OrgEventBriefPage.changed = false
        }
    }

    //FIXME: Fix this function
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let detailPage = EventDetailPage()
        detailPage.hidesBottomBarWhenPushed = true
        detailPage.event = displayedEvents[indexPath.section][indexPath.row]
        navigationController?.pushViewController(detailPage, animated: true)
    }

    //FIXME: fix this event
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {


        let event = displayedEvents[indexPath.section][indexPath.row]
        eventToIndex[event] = indexPath

        let cell = EventsCell()
        cell.titleLabel.text = event.title

        cell.setTime(for: event)

        if event.eventVisual != nil {
            cell.icon.image = event.eventVisual
        } else {
            cell.icon.image = UIImage(named: "cover_placeholder")
        }
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {return sections}
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {return labels[section]}
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int {return rowsForSection[section]}

    //FIXME:ask Jeff why
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {return 50}
        return 30
    }





    //functions here

    func retrieveEvents() {
        spinner.startAnimating()
        spinnerLabel.isHidden = false

        //Retrieve using API
        var parameters = [String: String]()

        //This probably would always be true
        if Organization.current != nil {
            parameters["orgId"] = String(Organization.current!.id)
        }

        let url = URL.with(base: API_BASE_URL, API_Name: "events/List", parameters: parameters)!
        var request = URLRequest(url:url)
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

            if let eventsList = try? JSON(data: data!).arrayValue {
                for eventData in eventsList {
                    if (true) {

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


    }// function ends here

    func groupEventsTime() {

        let today = Date()
        let calender = Calendar.current
        for event in eventDictionaryList {
            let eventDate = event.startTime
            let eventDateComponents = calender.dateComponents([.year, .month, .day, .hour, .minute, .second], from: eventDate!)
            let todayDateComponents = calender.dateComponents([.year, .month, .day, .hour, .minute, .second], from: today)
            let isSameYear = eventDateComponents.year == todayDateComponents.year
            let isSameMonth = eventDateComponents.month == todayDateComponents.month
            let isSameDay = eventDateComponents.day == todayDateComponents.day

            if (isSameDay && isSameYear && isSameMonth) {
                self.today.append(event)
            } else if (isSameYear && isSameMonth && (eventDateComponents.day! - todayDateComponents.day! == 1)) {
                self.tomorrow.append(event)
            } else if (isSameYear && isSameMonth && (eventDateComponents.day! - todayDateComponents.day! <= 7)) {
                self.thisWeek.append(event)
            } else if (eventDate! > today) {
                self.future.append(event)
            } else {
                self.past.append(event)
            }
        }
        self.today = self.today.sorted(by: { $0.startTime! < $1.startTime! })
        self.tomorrow = self.tomorrow.sorted(by: { $0.startTime! < $1.startTime! })
        self.thisWeek = self.thisWeek.sorted(by: { $0.startTime! < $1.startTime! })
        self.future = self.future.sorted(by: { $0.startTime! < $1.startTime! })
        self.past = self.past.sorted(by: { $0.startTime! > $1.startTime! })

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
        if self.thisWeek.count > 0 {
            sections += 1
            labels.append("This Week")
            displayedEvents.append(self.thisWeek)
            rowsForSection.append(self.thisWeek.count)
        }
        if self.future.count > 0 {
            sections += 1
            labels.append("In the future...")
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
        thisWeek.removeAll()
        future.removeAll()
        past.removeAll()

        sections = 0
        labels.removeAll()
        displayedEvents.removeAll()
        rowsForSection.removeAll()

        eventDictionaryList.removeAll()
        eventToIndex.removeAll()
    }
}

