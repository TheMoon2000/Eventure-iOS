//
//  EventSearchView.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/3/12.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class EventSearchView: UIViewController {
    
    private var emptyLabel: UILabel!
    private var loadingBG: UIView!
    private var searchBar: UISearchBar!
    private var cancelButton: UIButton!
    private var keywordsTable: UITableView!
    
    private var eventsTable: UITableView!
    
    private var allEvents = [Event]()
    private var filteredEvents = [Event]()
    private var finishedFetching = false
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        transitioningDelegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Search"
        
        view.backgroundColor = AppColors.tableBG

        loadingBG = view.addLoader()
        loadingBG.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        loadingBG.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        cancelButton = {
            let button = UIButton(type: .system)
            button.setTitle("Cancel", for: .normal)
            button.titleLabel?.font = .appFontMedium(17)
            button.tintColor = AppColors.main
            button.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(button)
            
            button.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -15).isActive = true
            
            button.addTarget(self, action: #selector(cancelSearch), for: .touchUpInside)
            
            return button
        }()

        searchBar = {
            let sb = UISearchBar()
            sb.placeholder = "Search Events..."
            sb.backgroundImage = UIImage()
            sb.autocorrectionType = .no
            sb.tintColor = AppColors.main
            sb.backgroundColor = .clear
            sb.delegate = self
            sb.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(sb)
            
            sb.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 5).isActive = true
            sb.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
            sb.centerYAnchor.constraint(equalTo: cancelButton.centerYAnchor).isActive = true
            sb.heightAnchor.constraint(equalToConstant: 36).isActive = true
            sb.rightAnchor.constraint(equalTo: cancelButton.leftAnchor, constant: -5).isActive = true
            
            return sb
        }()
        
        keywordsTable = {
            let table = UITableView()
            table.delegate = self
            table.dataSource = self
            table.alwaysBounceVertical = true
            table.keyboardDismissMode = .interactive
            table.separatorColor = AppColors.line
            table.tableFooterView = UIView()
            table.translatesAutoresizingMaskIntoConstraints = false
            table.refreshControl = UIRefreshControl()
            table.refreshControl?.addTarget(self, action: #selector(refreshKeywords), for: .valueChanged)
            view.addSubview(table)
            
            table.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            table.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            table.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10).isActive = true
            let b = table.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            b.priority = .defaultHigh
            b.isActive = true
            
            return table
        }()
        
        eventsTable = {
            let table = UITableView()
            table.isHidden = true // Initially hidden
            table.separatorStyle = .none
            table.backgroundColor = .clear
            table.contentInset.top = 5
            table.contentInset.bottom = 5
            table.delegate = self
            table.dataSource = self
            table.tableFooterView = UIView()
            table.alwaysBounceVertical = true
            table.register(EventOverviewTableCell.classForCoder(), forCellReuseIdentifier: "event")
            table.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(table)
            
            table.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            table.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            table.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10).isActive = true
            let b = table.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            b.priority = .defaultHigh
            b.isActive = true
            
            return table
        }()
        
        emptyLabel = {
            let label = UILabel()
            label.textColor = .gray
            label.text = ""
            label.font = .appFontRegular(17)
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
            
            return label
        }()
        
        searchBar.becomeFirstResponder()
        loadEvents()
    }
    
    @objc private func cancelSearch() {
        dismiss(animated: true)
    }
    
    private func loadEvents() {
        
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
    
    @objc private func refreshKeywords() {
        LocalStorage.updateKeywords { status in
            if status == 0 {
                self.keywordsTable.reloadSections([0], with: .automatic)
            } else if status == -1 && (self.searchBar.text ?? "").isEmpty {
                self.emptyLabel.text = CONNECTION_ERROR
                internetUnavailableError(vc: self)
            } else if status == -2 && (self.searchBar.text ?? "").isEmpty {
                self.emptyLabel.text = SERVER_ERROR
                serverMaintenanceError(vc: self)
            }
        }
    }
}
    
// MARK - Animations.
// Details: https://developer.apple.com/library/archive/featuredarticles/ViewControllerPGforiPhoneOS/CustomizingtheTransitionAnimations.html
    
extension EventSearchView {
    
    class PresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
        
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return 0.35
        }
        
        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            let container = transitionContext.containerView
            let toView = transitionContext.view(forKey: .to)!
            
            let finalFrame = transitionContext.finalFrame(for: transitionContext.viewController(forKey: .to)!)
            
            toView.clipsToBounds = true
            toView.layer.cornerRadius = 30
            toView.transform = CGAffineTransform(scaleX: 1.0, y: 0.82)
            toView.frame.origin = .zero
            toView.frame.size.height = finalFrame.height * 0.8
            toView.layer.opacity = 0.2
            
            container.addSubview(toView)
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                toView.layer.cornerRadius = 0
                toView.transform = .identity
                toView.frame.origin = .zero
                toView.frame.size.height = finalFrame.height
                toView.layer.opacity = 1.0
            }, completion: { _ in
                transitionContext.completeTransition(true)
            })
        }
    }
    
    class DismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
        
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return 0.35
        }
        
        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            let container = transitionContext.containerView
            let fromView = transitionContext.view(forKey: .from)!
                        
            fromView.layer.cornerRadius = 0
            fromView.layer.opacity = 1.0
            fromView.endEditing(true)
            (transitionContext.viewController(forKey: .from) as? EventSearchView)?.emptyLabel.isHidden = true
            
            container.addSubview(fromView)
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                fromView.layer.cornerRadius = 30
                fromView.transform = CGAffineTransform(scaleX: 1.0, y: 0.85)
                fromView.frame.origin = .zero
                fromView.layer.opacity = 0.0
            }, completion: { _ in
                transitionContext.completeTransition(true)
            })
        }
    }
    
}

extension EventSearchView: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentAnimator()
        
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
}

// MARK - Table view data source & delegate

extension EventSearchView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == keywordsTable {
            return LocalStorage.keywords.count
        } else if tableView == eventsTable {
            return eventsTable.isHidden ? 0 : filteredEvents.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == keywordsTable {
            let cell = KeywordSuggestionCell()
            cell.keywordTitle.text = LocalStorage.keywords[indexPath.row]
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "event", for: indexPath) as! EventOverviewTableCell
            cell.eventTitle.text = filteredEvents[indexPath.row].title
            cell.dateTime.text = filteredEvents[indexPath.row].timeDescription
            cell.location.text = filteredEvents[indexPath.row].location
            cell.orgLogo.image = nil
            cell.orgLogo.backgroundColor = AppColors.disabled
            
            let currentTime = Date()
            cell.lastUpdatedTime = currentTime
            
            Organization.getLogoImage(orgID: filteredEvents[indexPath.row].hostID) { image in
                if cell.lastUpdatedTime != currentTime { return }
                cell.orgLogo.backgroundColor = nil
                if image == UIImage.empty {
                    cell.orgLogo.image = #imageLiteral(resourceName: "group").withRenderingMode(.alwaysTemplate)
                } else {
                    cell.orgLogo.image = image ?? #imageLiteral(resourceName: "group").withRenderingMode(.alwaysTemplate)
                }
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == keywordsTable {
            searchBar.text = LocalStorage.keywords[indexPath.row].lowercased()
            searchBar.resignFirstResponder()
            searchBar(searchBar, textDidChange: searchBar.text!)
        } else {
            let detailPage = EventDetailPage()
            detailPage.hidesBottomBarWhenPushed = true
            detailPage.event = filteredEvents[indexPath.row]
//            navigationController?.pushViewController(detailPage, animated: true)
            let nav = UINavigationController(rootViewController: detailPage)
            nav.navigationBar.customize()
            present(nav, animated: true, completion: nil)
        }
    }
    
}


extension EventSearchView: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if CharacterSet(charactersIn: searchText).isSubset(of: .whitespacesAndNewlines) {
            keywordsTable.isHidden = false
            eventsTable.isHidden = true
            emptyLabel.text = ""
            eventsTable.reloadData()
            return
        }
        
        keywordsTable.isHidden = true
        eventsTable.isHidden = false
        
        guard finishedFetching else {
            emptyLabel.text = "Loading events..."
            return
        }
        
        let searchString = searchText.lowercased()
        
        DispatchQueue.global(qos: .default).async {
            self.filteredEvents = self.allEvents.filter { event in
                if searchString.isEmpty { return true }
                
                let tagNames = event.tags.map { LocalStorage.tags[$0]?.name ?? "" }

                for target in [event.title, event.eventDescription, event.hostTitle, event.location, tagNames.joined(separator: " ")] {
                    if target.lowercased().contains(searchString) {
                        return true
                    }
                }
                
                return false
            }
            DispatchQueue.main.async {
                self.eventsTable.reloadSections(IndexSet(arrayLiteral: 0), with: .automatic)
                if self.filteredEvents.isEmpty {
                    self.emptyLabel.text = "No events found."
                } else {
                    self.emptyLabel.text = ""
                }
            }
        }
        
    }
}
