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
    private var loadMoreLabel: UILabel!
    private var shouldLoadMore = false
    
    // Refresh control
    private var refreshControl = UIRefreshControl()
    
    private var upToDate: Bool = false
    var chosenTags = Set<Tag>()
    
    var start: Date? {
        didSet (oldValue) {
            let originalBound = oldValue ?? Date()
            let newBound = start ?? Date()
            upToDate = upToDate && newBound >= originalBound
        }
    }
    
    var end: Date? {
        didSet (oldValue) {
            let originalBound = oldValue ?? .distantFuture
            let newBound = end ?? .distantFuture
            upToDate = upToDate && newBound <= originalBound
        }
    }
    
    private var NO_EVENT = "No events to show."
    
    private(set) var allEvents = [Event]()
    private(set) var filteredEvents = [Event]()
    private(set) var eventsDisplayed = 20
   
    var eventsForSearch: [Event] {
        return filteredEvents
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 12.0, *), traitCollection.userInterfaceStyle == .dark {
            topTabBg.effect = UIBlurEffect(style: .regular)
        } else {
            topTabBg.effect = UIBlurEffect(style: .extraLight)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = AppColors.canvas
        title = "Events"
        
        searchResultTable = EventSearchResults(parentVC: self)
        
        // Search bar setup
                
        searchController = {
            let sc = UISearchController(searchResultsController: searchResultTable)
            sc.searchResultsUpdater = searchResultTable
            sc.searchBar.placeholder = "Search Events"
            sc.searchBar.tintColor = AppColors.main
            navigationItem.hidesSearchBarWhenScrolling = false
            sc.obscuresBackgroundDuringPresentation = true
            
            navigationItem.searchController = sc
            return sc
        }()
        
        definesPresentationContext = true
        
        navigationItem.leftBarButtonItem = .init(image: #imageLiteral(resourceName: "options"), style: .plain, target: self, action: #selector(openOptions))
        
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        refreshControl.tintColor = AppColors.lightControl
        
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .refresh, target: self, action: #selector(refreshButton))
        
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
            let tab = UISegmentedControl(items: ["All Events", "Trending", "Recommended"])
            tab.setEnabled(false, forSegmentAt: 1)
            if User.current == nil {
                tab.setEnabled(false, forSegmentAt: 2)
            }
            tab.tintColor = AppColors.main
            tab.selectedSegmentIndex = 0
            tab.translatesAutoresizingMaskIntoConstraints = false
            topTabBg.contentView.addSubview(tab)
            
            tab.leftAnchor.constraint(equalTo: topTabBg.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            tab.rightAnchor.constraint(equalTo: topTabBg.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
            tab.centerYAnchor.constraint(equalTo: topTabBg.centerYAnchor).isActive = true
            
            tab.addTarget(self, action: #selector(refilter), for: .valueChanged)
            return tab
        }()
        
        topTabBg.layoutIfNeeded()
        
        eventCatalog = {
            let layout = TopAlignedCollectionViewFlowLayout()
            layout.footerReferenceSize = CGSize(width: 300, height: 50)
            let ec = UICollectionView(frame: .zero, collectionViewLayout: layout)
            ec.delegate = self
            ec.dataSource = self
            ec.backgroundColor = AppColors.canvas
            ec.contentInset.top = topTabBg.frame.height + 8
            ec.contentInset.bottom = 8 - layout.footerReferenceSize.height
            ec.scrollIndicatorInsets.top = topTabBg.frame.height
            ec.register(EventFooterView.classForCoder(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer")
            ec.register(EventCell.classForCoder(), forCellWithReuseIdentifier: "event")
            ec.contentInsetAdjustmentBehavior = .always
            ec.addSubview(refreshControl)
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
            spinner.color = AppColors.lightControl
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
            label.font = .appFontMedium(17)
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
            
            label.centerXAnchor.constraint(equalTo: eventCatalog.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: eventCatalog.centerYAnchor).isActive = true
            
            return label
        }()
        
        updateEvents()
    }
    
    /// Refreshes the displayed events, fetching data from the server if needed.
    func fetchEventsIfNeeded() {
        if !upToDate {
            updateEvents()
        } else {
            refilter()
        }
    }
    
    @objc private func pullToRefresh() {
        updateEvents(pulled: true)
    }
    
    @objc private func refreshButton() {
        updateEvents()
    }
    
    private func updateEvents(pulled: Bool = false) {
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        emptyLabel.text = ""
        filteredEvents.removeAll()
        if !pulled {
            self.eventCatalog.reloadData()
            spinner.startAnimating()
            spinnerLabel.isHidden = false
        }
        
        var parameters = [String : String]()
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
        
        func stop() {
            self.spinner.stopAnimating()
            self.spinnerLabel.isHidden = true
            self.refreshControl.endRefreshing()
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                DispatchQueue.main.async {
                    stop()
                    if self.eventCatalog.numberOfItems(inSection: 0) == 0 {
                        self.emptyLabel.text = CONNECTION_ERROR
                    }
                    internetUnavailableError(vc: self)
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
                    tmp = tmp.sorted(by: { (e1: Event, e2: Event) -> Bool in
                        return (e1.startTime ?? Date.distantFuture) < (e2.startTime ?? Date.distantFuture)
                    })
                    self.upToDate = true
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
                    if self.eventCatalog.numberOfItems(inSection: 0) == 0 {
                        self.emptyLabel.text = SERVER_ERROR
                    }
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
        nav.navigationBar.tintColor = AppColors.main
        nav.navigationBar.barTintColor = .white
        nav.navigationBar.shadowImage = UIImage()
        present(nav, animated: true, completion: nil)
        */
        let filterTable = FilterDateTableViewController(parentVC: self)
        let nav = UINavigationController(rootViewController:
            filterTable)
        nav.navigationBar.customize()
        
        present(nav, animated: true)
    }
    

}


extension EventViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(filteredEvents.count, eventsDisplayed)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "event", for: indexPath) as! EventCell
        guard indexPath.row < filteredEvents.count else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "event", for: [0, 0])
        }
        
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let v = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer", for: indexPath)
            return v
        }
        return UICollectionReusableView()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { context in
            self.eventCatalog?.collectionViewLayout.invalidateLayout()
        }, completion: nil)
    }
}


extension EventViewController {
    
    @objc func refilter() {
        self.emptyLabel.text = ""
        self.updateFiltered {
            self.spinner.startAnimating()
            self.spinnerLabel.isHidden = false
            self.eventCatalog.reloadData()
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
                if event.startTime! < (self.start ?? Date()) {
                    return false
                }
                
                if let end = self.end, event.endTime! > end {
                    return false
                }
                
                if !self.chosenTags.isEmpty && event.tags.intersection(self.chosenTags).isEmpty {
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


extension EventViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.contentSize.height - 50
        let scrolled = scrollView.safeAreaLayoutGuide.layoutFrame.height + scrollView.contentOffset.y - 10
        if height <= scrollView.safeAreaLayoutGuide.layoutFrame.height { return }
        if let footer = eventCatalog?.supplementaryView(forElementKind: UICollectionView.elementKindSectionFooter, at: [0, 0]) as? EventFooterView {
            footer.textLabel.alpha = (scrolled - height) / 70
            if eventsDisplayed < filteredEvents.count {
                if footer.textLabel.alpha >= 1 {
                    footer.textLabel.text = "Release to load more"
                    shouldLoadMore = true
                } else {
                    footer.textLabel.text = "Load more..."
                    shouldLoadMore = false
                }
            } else {
                footer.textLabel.text = "No more events to load"
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if shouldLoadMore {
            shouldLoadMore = false
            eventsDisplayed += 20
            eventCatalog.reloadSections([0])
        }
    }
}
