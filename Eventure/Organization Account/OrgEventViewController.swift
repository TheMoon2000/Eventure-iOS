//
//  OrgEventViewController.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/11.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class OrgEventViewController: UIViewController, EventProvider {
    
    var showTopTab: Bool {
        return true
    }
    
    var orgID: String? {
        return Organization.current?.id
    }
    
    var useRefreshControl: Bool { return false }
    
    var EMPTY_STRING: String { return "No published events." }
    
    private let refreshControl = UIRefreshControl()
    private let refreshControlAttributes: [NSAttributedString.Key: Any] = [
        NSMutableAttributedString.Key.foregroundColor: UIColor.gray,
        .font: UIFont.systemFont(ofSize: 17, weight: .medium)
    ]
    
    // Date bounds
    var lowerBound: Date?
    var upperBound: Date?
    
    private var searchController: UISearchController!
    private var searchResults: EventSearchResults!
    
    private var topTabBg: UIVisualEffectView!
    private var topTab: UISegmentedControl!
    var eventCatalog: UICollectionView!
    private var spinner: UIActivityIndicatorView!
    private var spinnerLabel: UILabel!
    private var publishedLabel: UILabel!
    private var draftLabel: UILabel!
    
    private var loadMoreLabel: UILabel!
    private var shouldLoadMore = false
    private(set) var eventsDisplayed = 20
    
    var allEvents = Set<Event>() {
        didSet {
            if !self.allEvents.isEmpty {
                Organization.current?.numberOfEvents = self.allEvents.count
            }
        }
    }
    
    var allDrafts = Set<Event>() {
        didSet {
            updateFiltered()
        }
    }
    
    /// An ordered list of events that should be shown.
    var filteredEvents = [Event]()
    
    var eventsForSearch: [Event] {
        return filteredEvents
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .dark {
                topTabBg.effect = UIBlurEffect(style: .regular)
            } else {
                topTabBg.effect = UIBlurEffect(style: .extraLight)
            }
        } else {
            topTabBg.effect = UIBlurEffect(style: .extraLight)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = AppColors.canvas
        title = "Event Posts"
        
        // Search bar setup
        searchResults = EventSearchResults(parentVC: self)
        searchController = UISearchController(searchResultsController: searchResults)
        searchController.searchResultsUpdater = searchResults
        searchController.searchBar.tintColor = MAIN_TINT
        searchController.searchBar.placeholder = "Search Your Events"
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
        
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
            let layout = TopAlignedCollectionViewFlowLayout()
            layout.footerReferenceSize = CGSize(width: 300, height: 50)
            let ec = UICollectionView(frame: .zero, collectionViewLayout: layout)
            ec.delegate = self
            ec.dataSource = self
            if useRefreshControl {
                ec.refreshControl = self.refreshControl
            }
            ec.alwaysBounceVertical = true
            ec.contentInset.top = 8
            ec.contentInset.bottom = 8 - layout.footerReferenceSize.height
            ec.backgroundColor = AppColors.canvas
            if !topTabBg.isHidden {
                ec.scrollIndicatorInsets.top = topTabBg.frame.height
                ec.contentInset.top += topTabBg.frame.height
            }
            ec.register(OrgEventCell.classForCoder(), forCellWithReuseIdentifier: "org event")
            ec.register(EventFooterView.classForCoder(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer")
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
        // refreshControl.attributedTitle = NSAttributedString(string: "Reload", attributes: refreshControlAttributes)
        // refreshControl.tintColor = MAIN_TINT
        
        // Fetch all events and draft events
        updateEvents()
        updateDrafts()
    }
    
    @objc private func pullDownRefresh() {
        updateEvents(pulled: true)
    }
    
    func updateDrafts() {
        if Organization.current == nil { return }
        if let orgSpecificEvents = Event.readFromFile(path: DRAFTS_PATH.path)[Organization.current!.id] {
            allDrafts = orgSpecificEvents
        }
    }
    
    @objc private func updateEvents(pulled: Bool = false) {
        
        publishedLabel.text = ""

        if !pulled {
            spinner.startAnimating()
            spinnerLabel.isHidden = false
            allEvents.removeAll()
            filteredEvents.removeAll()
            eventCatalog.reloadData()
            refreshControl.isEnabled = false
            refreshControl.isHidden = true
        }
        
        func endRefreshing() {
            if !pulled {
                self.spinner.stopAnimating()
                self.spinnerLabel.isHidden = true
                self.refreshControl.isEnabled = true
                self.refreshControl.isHidden = false
            } else {
                self.refreshControl.endRefreshing()
            }
        }
        
        var parameters = [String : String]()
        parameters["orgId"] = orgID
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/List",
                           parameters: parameters)!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                DispatchQueue.main.async {
                    endRefreshing()
                    if self.allEvents.isEmpty {
                        self.publishedLabel.text = CONNECTION_ERROR
                    } else {
                        internetUnavailableError(vc: self)
                    }
                }
                return
            }
            
            if let eventsList = try? JSON(data: data!).arrayValue {
                
                var tmp = Set<Event>()
                for eventJSON in eventsList {
                    let event = Event(eventInfo: eventJSON)
                    event.getBanner(nil)
                    tmp.insert(event)
                }
                DispatchQueue.main.async {
                    self.allEvents = tmp
                    self.updateFiltered {
                        self.eventCatalog.reloadData()
                        endRefreshing()
                    }
                    self.publishedLabel.text = self.allEvents.isEmpty ? self.EMPTY_STRING : ""
                }
            } else {
                endRefreshing()
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
    
    @objc func refresh() {
        updateEvents(pulled: false)
    }
    
    @objc private func changedTab() {
        let isDraftMode = topTab.selectedSegmentIndex == 1
        publishedLabel.isHidden = isDraftMode
        draftLabel.isHidden = !isDraftMode
        
        if isDraftMode {
            navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #selector(createNewEvent))
            spinner.alpha = 0.0
            spinnerLabel.alpha = 0.0
        } else {
            navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
            spinner.alpha = 1.0
            spinnerLabel.alpha = 1.0
        }
        topTab.isUserInteractionEnabled = false
        updateFiltered {
            self.eventCatalog.reloadData()
            self.topTab.isUserInteractionEnabled = true
        }
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
        
        let count = min(filteredEvents.count, eventsDisplayed)
        
        if topTab.selectedSegmentIndex == 0 {
            publishedLabel.text = count == 0 && !spinner.isAnimating ? EMPTY_STRING : ""
        } else if topTab.selectedSegmentIndex == 1 {
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
        
        cell.setupCellWithEvent(event: self.filteredEvents[indexPath.row], withImage: true)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let detailPage = EventDetailPage()
        detailPage.hidesBottomBarWhenPushed = true
        detailPage.orgEventView = self
        detailPage.event = filteredEvents[indexPath.row]
        navigationController?.pushViewController(detailPage, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let v = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer", for: indexPath)
            return v
        }
        return UICollectionReusableView()
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
        return extraSpace / (rowCount + 1) - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cell = OrgEventCell()
        
        guard indexPath.row < filteredEvents.count else {
            return CGSize(width: 350, height: 550) // Arbitrary size
        }
        
        cell.setupCellWithEvent(event: filteredEvents[indexPath.row])
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
    
    /// The filter that is adjusted by user settings.
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


extension OrgEventViewController {

    func updateFiltered(_ handler: (() -> ())? = nil) {
        let tab = topTab.selectedSegmentIndex
        DispatchQueue.global(qos: .default).async {
            if tab == 0 {
                self.filteredEvents = self.allEvents.filter { self.filterFunction($0)
                }
                . sorted { self.sortFunction(event1: $0, event2: $1) }
            } else {
                self.filteredEvents = self.allDrafts.sorted { self.sortFunction(event1: $0, event2: $1) }
            }
            DispatchQueue.main.async {
                handler?()
            }
        }
        
    }
}

extension OrgEventViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.contentSize.height - 50
        let scrolled = scrollView.safeAreaLayoutGuide.layoutFrame.height + scrollView.contentOffset.y - 10
        if height <= scrollView.safeAreaLayoutGuide.layoutFrame.height { return }
        if let footer = eventCatalog?.supplementaryView(forElementKind: UICollectionView.elementKindSectionFooter, at: [0, 0]) as? EventFooterView {
            if !filteredEvents.isEmpty && !spinner.isAnimating {
                footer.textLabel.alpha = (scrolled - height) / 80
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
            } else {
                footer.textLabel.alpha = 0.0
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if shouldLoadMore {
            shouldLoadMore = false
            eventsDisplayed += 10
            eventCatalog.reloadData()
        }
    }
}

