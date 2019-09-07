//
//  EventViewController.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/10.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class EventViewController: UIViewController, EventProvider {
    
    private var isFiltering: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    
    // The search bar
    private var searchResultTable: EventSearchResults!
    private var searchController: UISearchController!
    private var topTabBg: UIVisualEffectView!
    private var topTab: UISegmentedControl!
    private var eventCatalog: UICollectionView!
    private var spinner: UIActivityIndicatorView!
    private var spinnerLabel: UILabel!
    private var emptyLabel: UILabel!
    
    private static var upToDate: Bool = false
    public static var chosenTags = Set<String>()
    
    public static var start: Date? {
        didSet (oldValue) {
            let originalBound = oldValue ?? Date()
            let newBound = start ?? Date()
            upToDate = upToDate && newBound >= originalBound
        }
    }
    
    public static var end: Date? {
        didSet (oldValue) {
            let originalBound = oldValue ?? .distantFuture
            let newBound = end ?? .distantFuture
            upToDate = upToDate && newBound <= originalBound
        }
    }
    
    private var NO_EVENT = "No events to show."
    
    private(set) var allEvents = [Event]()
    private(set) var filteredEvents = [Event]()
   
    var eventsForSearch: [Event] {
        return filteredEvents
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "Events"
        
        searchResultTable = EventSearchResults(parentVC: self)
        
        // Search bar setup
                
        searchController = {
            let sc = UISearchController(searchResultsController: searchResultTable)
            sc.searchResultsUpdater = searchResultTable
            sc.searchBar.placeholder = "Search Events"
            sc.searchBar.tintColor = MAIN_TINT
            navigationItem.hidesSearchBarWhenScrolling = false
            sc.obscuresBackgroundDuringPresentation = true
            
            navigationItem.searchController = sc
            return sc
        }()
        
        definesPresentationContext = true
        
        /*
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = MAIN_TINT
        searchController.searchBar.placeholder = "Search Events"
 */
//      navigationItem.hidesSearchBarWhenScrolling = false
        
        navigationItem.leftBarButtonItem = .init(image: #imageLiteral(resourceName: "options"), style: .plain, target: self, action: #selector(openOptions))
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .refresh, target: self, action: #selector(updateEvents))
        
        topTabBg = {
            let ev = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
            ev.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(ev)
            
            ev.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            ev.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            ev.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            ev.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            return ev
        }()
        
        topTab = {
            let tab = UISegmentedControl(items: ["All Events", "Trending", "Recommended"])
            tab.setEnabled(false, forSegmentAt: 1)
            if User.current == nil {
                tab.setEnabled(false, forSegmentAt: 2)
            }
            tab.tintColor = MAIN_TINT
            tab.selectedSegmentIndex = 0
            tab.translatesAutoresizingMaskIntoConstraints = false
            topTabBg.contentView.addSubview(tab)
            
            tab.leftAnchor.constraint(equalTo: topTabBg.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            tab.rightAnchor.constraint(equalTo: topTabBg.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
            tab.centerYAnchor.constraint(equalTo: topTabBg.centerYAnchor).isActive = true
            
            tab.addTarget(self, action: #selector(updateEvents), for: .valueChanged)
            return tab
        }()
        
        topTabBg.layoutIfNeeded()
        
        eventCatalog = {
           let ec = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
            ec.delegate = self
            ec.dataSource = self
            ec.contentInset.top = topTabBg.frame.height + 8
            ec.contentInset.bottom = 8
            ec.scrollIndicatorInsets.top = topTabBg.frame.height
            ec.backgroundColor = .init(white: 0.92, alpha: 1)
            ec.register(EventCell.classForCoder(), forCellWithReuseIdentifier: "event")
            ec.contentInsetAdjustmentBehavior = .always
            ec.translatesAutoresizingMaskIntoConstraints = false
            view.insertSubview(ec, belowSubview: topTabBg)
            
            ec.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            ec.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            ec.topAnchor.constraint(equalTo: topTabBg.topAnchor).isActive = true
            ec.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            return ec
        }()
        
        spinner = {
            let spinner = UIActivityIndicatorView(style: .whiteLarge)
            spinner.color = .lightGray
            spinner.hidesWhenStopped = true
            spinner.startAnimating()
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
        
        emptyLabel = {
            let label = UILabel()
            label.textColor = .darkGray
            label.font = .systemFont(ofSize: 17)
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: eventCatalog.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: eventCatalog.centerYAnchor).isActive = true
            
            return label
        }()
        
        updateEvents()
//        NotificationCenter.default.addObserver(self, selector: #selector(filteredByUser), name: NSNotification.Name("filter"), object: nil)
    }
    
    /// Refreshes the displayed events, fetching data from the server if needed.
    func fetchEventsIfNeeded() {
        if !EventViewController.upToDate {
            updateEvents()
        } else {
            refilter()
        }
    }
    
    @objc private func updateEvents() {
        //shouldFilter = false
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        spinner.startAnimating()
        spinnerLabel.isHidden = false
        emptyLabel.text = ""
        filteredEvents.removeAll()
        self.eventCatalog.reloadData()
        
        var parameters = [String : String]()
        if User.current != nil {
            parameters["userId"] = String(User.current!.uuid)
            parameters["userEmail"] = User.current!.email
        }
        if let start = EventViewController.start {
            parameters["lowerBound"] = DATE_FORMATTER.string(from: start)
        } else {
            parameters["lowerBound"] = DATE_FORMATTER.string(from: Date())
        }
        if let end = EventViewController.end {
            parameters["upperBound"] = DATE_FORMATTER.string(from: end)
        } else {
            parameters["upperBound"] = DATE_FORMATTER.string(from: .distantFuture)
        }
            
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/List",
                           parameters: parameters)!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        func stop() {
            self.spinner.stopAnimating()
            self.spinnerLabel.isHidden = true
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                DispatchQueue.main.async {
                    self.emptyLabel.text = CONNECTION_ERROR
                    stop()
                    internetUnavailableError(vc: self)
                }
                return
            }
            
            if let eventsList = try? JSON(data: data!).arrayValue {
                DispatchQueue.global(qos: .default).async {
                    var tmp = [Event]()
                    for event in eventsList {
                        tmp.append(Event(eventInfo: event))
                    }
                    tmp = tmp.sorted(by: { (e1: Event, e2: Event) -> Bool in
                        return (e1.startTime ?? Date.distantFuture) < (e2.startTime ?? Date.distantFuture)
                    })
                    EventViewController.upToDate = true
                    self.allEvents = tmp
                    DispatchQueue.main.async {
                        self.updateFiltered() {
                            self.eventCatalog.reloadSections([0])
                            stop()
                            if tmp.isEmpty {
                                self.emptyLabel.text = self.NO_EVENT
                            }
                        }
                    }
                }
            } else {
                print("Unable to parse '\(String(data: data!, encoding: .utf8)!)'")

                DispatchQueue.main.async {
                    stop()
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
    
    @objc private func openOptions() {
        // TODO: filtering options here
        /*
        let filter = FilterPageViewController()
        let nav = UINavigationController(rootViewController: filter)
        nav.navigationBar.tintColor = MAIN_TINT
        nav.navigationBar.barTintColor = .white
        nav.navigationBar.shadowImage = UIImage()
        present(nav, animated: true, completion: nil)
        */
        let filterTable = FilterDateTableViewController(parentVC: self)
        let nav = CheckinNavigationController(rootViewController:
            filterTable)
        present(nav, animated: true)
    }
    

}


extension EventViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredEvents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "event", for: indexPath) as! EventCell
        cell.setupCellWithEvent(event: filteredEvents[indexPath.row], withImage: true)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let detailPage = EventDetailPage()
        detailPage.interestedStatusChanged = { status in
            if let cell = collectionView.cellForItem(at: indexPath) as? EventCell {
                if status {
                    cell.interestedButton.setImage(#imageLiteral(resourceName: "star_filled"), for: .normal)
                } else {
                    cell.interestedButton.setImage(#imageLiteral(resourceName: "star_empty"), for: .normal)
                }
            }
        }
        detailPage.event = filteredEvents[indexPath.row]
        detailPage.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailPage, animated: true)
    }
}


extension EventViewController: UICollectionViewDelegateFlowLayout {
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

        return extraSpace / (rowCount + 1) - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        guard indexPath.row < filteredEvents.count else {
            return CGSize(width: 340, height: 500)
        }
        
        let event = filteredEvents[indexPath.row]
        
        let cell = EventCell()
        cell.setupCellWithEvent(event: event)
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
                            left: 8,
                            bottom: equalSpacing,
                            right: 8)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { context in
            self.eventCatalog.collectionViewLayout.invalidateLayout()
        }, completion: nil)
    }
}


extension EventViewController {
    
    func refilter() {
        self.emptyLabel.text = ""
        self.updateFiltered {
            self.spinner.startAnimating()
            self.spinnerLabel.isHidden = false
            self.eventCatalog.reloadSections([0])
            self.spinner.stopAnimating()
            self.spinnerLabel.isHidden = true
            self.emptyLabel.text = self.filteredEvents.isEmpty ? self.NO_EVENT : ""
        }
    }
    
    func updateFiltered(handler: (() -> ())? = nil) {
//        var cnt = 0
        let tabName = topTab.titleForSegment(at: topTab.selectedSegmentIndex)!
        DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + 0.1) {
            self.filteredEvents = self.allEvents.filter { (event: Event) -> Bool in
                
                if event.startTime == nil || event.endTime == nil { return false }
                if event.startTime! < (EventViewController.start ?? Date()) {
                    return false
                }
                
                if let end = EventViewController.end, event.endTime! > end {
                    return false
                }
                
                if !EventViewController.chosenTags.isEmpty && event.tags.intersection(EventViewController.chosenTags).isEmpty {
                    return false
                }
                
                if tabName == "Recommended" {
                    // If the current tab is 'Recommended', the current user must be logged in
                    if event.tags.intersection(User.current!.tags).isEmpty {
                        return false
                    }
                } else if tabName == "Trending" {
                    // TODO: Replace with code to filter out non-trending events
                }

                return true
            }
            print("\(self.allEvents.count) events, \(self.filteredEvents.count) visible")
            // TODO: Apply sorting algorithm depending on user settings
            self.filteredEvents.sort(by: { $0.startTime! < $1.startTime! })
            DispatchQueue.main.async {
                handler?()
            }
        }
    }
    
   
}
