//
//  OrgEventViewController.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/11.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class OrgEventViewController: UIViewController {
    
    var showTopTab: Bool {
        return true
    }
    
    var orgID: String? {
        return Organization.current?.id
    }
    
    var useRefreshControl: Bool {
        return false
    }
    
    // Date bounds
    var lowerBound: Date?
    var upperBound: Date?
    
    private let refreshControl = UIRefreshControl()
    private let refreshControlAttributes: [NSAttributedString.Key: Any] = [
        NSMutableAttributedString.Key.foregroundColor: UIColor.gray,
        .font: UIFont.systemFont(ofSize: 17, weight: .medium)
    ]
    
    private var topTabBg: UIVisualEffectView!
    private var topTab: UISegmentedControl!
    var eventCatalog: UICollectionView!
    private var spinner: UIActivityIndicatorView!
    private var spinnerLabel: UILabel!
    private var publishedLabel: UILabel!
    private var draftLabel: UILabel!
    
    var allEvents = [Event]()
    var allDrafts = [Event]()
    var displayedEvents: [Event] {
        if topTab.selectedSegmentIndex == 0 {
            return allEvents
        } else {
            return allDrafts
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "Event Posts"
        
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #selector(createNewEvent))
        
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
            let tab = UISegmentedControl(items: ["Published", "Drafts"])
            tab.tintColor = MAIN_TINT
            tab.selectedSegmentIndex = 0
            tab.translatesAutoresizingMaskIntoConstraints = false
            topTabBg.contentView.addSubview(tab)
            
            tab.leftAnchor.constraint(equalTo: topTabBg.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            tab.rightAnchor.constraint(equalTo: topTabBg.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
            tab.centerYAnchor.constraint(equalTo: topTabBg.centerYAnchor).isActive = true
            
            tab.addTarget(self, action: #selector(changedTab), for: .valueChanged)
            
            return tab
        }()
        
        topTabBg.layoutIfNeeded()
        
        topTabBg.isHidden = !showTopTab
        
        eventCatalog = {
            let ec = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
            ec.delegate = self
            ec.dataSource = self
            if useRefreshControl {
                ec.refreshControl = self.refreshControl
            }
            ec.contentInset.top = 8
            ec.contentInset.bottom = 8
            if !topTabBg.isHidden {
                ec.scrollIndicatorInsets.top = topTabBg.frame.height
                ec.contentInset.top += topTabBg.frame.height
            }
            ec.backgroundColor = .init(white: 0.92, alpha: 1)
            ec.register(OrgEventCell.classForCoder(), forCellWithReuseIdentifier: "org event")
            ec.contentInsetAdjustmentBehavior = .always
            ec.translatesAutoresizingMaskIntoConstraints = false
            view.insertSubview(ec, belowSubview: topTabBg)
            
            ec.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            ec.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            if topTabBg.isHidden {
                ec.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            } else {
                ec.topAnchor.constraint(equalTo: topTabBg.topAnchor).isActive = true
            }
            ec.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            return ec
        }()
        
        spinner = {
            let spinner = UIActivityIndicatorView(style: .whiteLarge)
            spinner.color = .lightGray
            spinner.hidesWhenStopped = true
            spinner.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(spinner)
            
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            spinner.centerYAnchor.constraint(equalTo: eventCatalog.centerYAnchor, constant: -5).isActive = true
            
            return spinner
        }()
        
        spinnerLabel = {
            let label = UILabel()
            label.text = "Loading events..."
            label.isHidden = true
            label.font = .systemFont(ofSize: 17, weight: .medium)
            label.textColor = .darkGray
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: spinner.centerXAnchor).isActive = true
            label.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 10).isActive = true
            
            return label
        }()
        
        publishedLabel = {
            let label = UILabel()
            label.textColor = .darkGray
            label.font = .systemFont(ofSize: 17)
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: eventCatalog.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: eventCatalog.centerYAnchor).isActive = true
            
            return label
        }()
        
        draftLabel = {
            let label = UILabel()
            label.isHidden = true
            label.textColor = .darkGray
            label.font = .systemFont(ofSize: 17)
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: eventCatalog.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: eventCatalog.centerYAnchor).isActive = true
            
            return label
            }()
        
        refreshControl.addTarget(self, action: #selector(pullDownRefresh), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Reload", attributes: refreshControlAttributes)
        refreshControl.tintColor = MAIN_TINT
        
        // Fetch all events and draft events
        updateEvents()
        updateDrafts()
    }
    
    @objc private func pullDownRefresh() {
        updateEvents(pulled: true)
    }
    
    func updateDrafts() {
        if let orgSpecificEvents = Event.readFromFile(path: DRAFTS_PATH.path)[Organization.current!.id] {
            allDrafts = orgSpecificEvents
        }
    }
    
    private func updateEvents(pulled: Bool = false) {
        
        publishedLabel.text = ""

        if !pulled {
            spinner.startAnimating()
            spinnerLabel.isHidden = false
            allEvents.removeAll()
            eventCatalog.reloadSections(IndexSet(arrayLiteral: 0))
            refreshControl.isEnabled = false
            refreshControl.isHidden = true
        }
        
        var parameters = [String : String]()
        parameters["id"] = orgID
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/List", parameters: parameters)!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            DispatchQueue.main.async {
                if !pulled {
                    self.spinner.stopAnimating()
                    self.spinnerLabel.isHidden = true
                    self.refreshControl.isEnabled = true
                    self.refreshControl.isHidden = false
                } else {
                    self.refreshControl.endRefreshing()
                }
            }
            
            guard error == nil else {
                DispatchQueue.main.async {
                    if self.allEvents.isEmpty {
                        self.publishedLabel.text = CONNECTION_ERROR
                    } else {
                        internetUnavailableError(vc: self)
                    }
                }
                return
            }
            
            if let eventsList = try? JSON(data: data!).arrayValue {
                self.allEvents.removeAll()
                for eventData in eventsList {
                    let event = Event(eventInfo: eventData)
                    if self.filterFunction(event) {
                        self.allEvents.append(event)
                    }
                }
                self.allEvents.sort { self.sortFunction(event1: $0, event2: $1) }
                
                DispatchQueue.main.async {
                    self.eventCatalog.reloadData()
                    self.publishedLabel.text = self.allEvents.isEmpty ? "No Events" : ""
                }
            } else {
                print("Unable to parse '\(String(data: data!, encoding: .utf8)!)'")
                
                DispatchQueue.main.async {
                    self.publishedLabel.text = SERVER_ERROR
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
    
    @objc private func changedTab() {
        eventCatalog.reloadData()
        
        let isDraftMode = topTab.selectedSegmentIndex == 1
        publishedLabel.isHidden = isDraftMode
        draftLabel.isHidden = !isDraftMode
    }
    
    
    @objc private func createNewEvent() {
        let draftEvent = Event.empty
        let editor = EventDraft(event: draftEvent)
        editor.orgEventView = self
        let nav = UINavigationController(rootViewController: editor)
        nav.navigationBar.tintColor = MAIN_TINT
        nav.navigationBar.barTintColor = .white
        nav.navigationBar.shadowImage = UIImage()
        present(nav, animated: true, completion: nil)
    }
    
}

// MARK: - Extension on datasource and delegate
extension OrgEventViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let count = displayedEvents.count
        
        if topTab.selectedSegmentIndex == 1 {
            draftLabel.text = count == 0 ? "No Drafts" : ""
        }
        
        return count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "org event", for: indexPath) as! OrgEventCell
        cell.parentVC = self
        cell.setupCellWithEvent(event: displayedEvents[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let detailPage = EventDetailPage()
        detailPage.hidesBottomBarWhenPushed = true
        detailPage.orgEventView = self
        detailPage.event = displayedEvents[indexPath.row]
        navigationController?.pushViewController(detailPage, animated: true)
    }
}

// MARK: - Extension on flow layout
extension OrgEventViewController: UICollectionViewDelegateFlowLayout {
    var cardWidth: CGFloat {
        if usableWidth < 500 {
            return usableWidth - 16
        } else {
            let numFit = floor(usableWidth / 320)
            return ((usableWidth - 8) / numFit) - 8
        }
    }
    
    var usableWidth: CGFloat {
        return eventCatalog.safeAreaLayoutGuide.layoutFrame.width
    }
    
    var equalSpacing: CGFloat {
        let rowCount = floor(usableWidth / cardWidth)
        let extraSpace = usableWidth - rowCount * cardWidth
        
        return extraSpace / (rowCount + 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cell = OrgEventCell()
        cell.setupCellWithEvent(event: displayedEvents[indexPath.row])
        return CGSize(width: cardWidth,
                      height: cell.preferredHeight(width: cardWidth))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return equalSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return equalSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: equalSpacing,
                            left: equalSpacing,
                            bottom: equalSpacing,
                            right: equalSpacing)
    }

}

// MARK: - Sorting and filtering events
extension OrgEventViewController {
    
    /// The sort function to use for the list of events. By default, descending order is used (latest events appear first).
    func sortFunction(event1: Event, event2: Event) -> Bool {
        if event2.startTime == nil {
            return true
        } else if event1.startTime == nil {
            return false
        } else {
            return event1.startTime!.timeIntervalSince(event2.startTime!) >= 0
        }
    }
    
    /// The filter that is applied to all events.
    func filterFunction(_ event: Event) -> Bool {
        if event.startTime == nil {
            return false
        }
        
        let lowCond = lowerBound == nil || event.startTime!.timeIntervalSince(lowerBound!) >= 0
        let highCond = upperBound == nil || event.endTime == nil || event.endTime!.timeIntervalSince(upperBound!) <= 0
        let hostCond = orgID == nil || event.hostID == orgID
        
        return lowCond && highCond && hostCond
    }
}
