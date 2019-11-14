//
//  StatEventList.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/10/30.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON
import XLPagerTabStrip

class StatEventList: UIViewController, IndicatorInfoProvider {
    
    private var tableView: UITableView!
    private var bottomBanner: UIVisualEffectView!
    private var bannerTitle: UILabel!
    private var loader: UIView!
    private var emptyLabel: UILabel!
    
    private var refreshControl = UIRefreshControl()
    private var eventCollection = Set<Event>() {
        didSet {
            eventList = eventCollection.sorted { event1, event2 in
                if event1.interested.count != event2.interested.count {
                    return event1.interested.count > event2.interested.count
                } else {
                    return event1.title.lowercased() < event2.title.lowercased()
                }
            }
        }
    }
    private var eventList = [Event]()

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl.tintColor = AppColors.lightControl
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        
        let topLine: UIView = {
            let line = UIView()
            line.backgroundColor = AppColors.line.withAlphaComponent(0.5)
            line.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(line)
            
            line.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            line.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            line.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            line.heightAnchor.constraint(equalToConstant: 1).isActive = true
            
            return line
        }()
        
        tableView = {
            let tv = UITableView()
            tv.tableFooterView = UIView()
            tv.backgroundColor = AppColors.tableBG
            tv.separatorColor = AppColors.line
            tv.contentInset.bottom = 48
            tv.dataSource = self
            tv.delegate = self
            tv.addSubview(refreshControl)
            tv.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(tv)
            
            tv.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            tv.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            tv.topAnchor.constraint(equalTo: topLine.bottomAnchor).isActive = true
            tv.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            return tv
        }()
        
        bottomBanner = {
            let effect: UIVisualEffect
            if #available(iOS 12.0, *), traitCollection.userInterfaceStyle == .dark {
                effect = UIBlurEffect(style: .regular)
            } else {
                effect = UIBlurEffect(style: .extraLight)
            }
            
            let banner = UIVisualEffectView(effect: effect)
            banner.isHidden = true
            banner.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(banner)
            
            let line = UIView()
            line.backgroundColor = AppColors.line.withAlphaComponent(0.5)
            line.translatesAutoresizingMaskIntoConstraints = false
            banner.contentView.addSubview(line)
            
            line.leftAnchor.constraint(equalTo: banner.leftAnchor).isActive = true
            line.rightAnchor.constraint(equalTo: banner.rightAnchor).isActive = true
            line.topAnchor.constraint(equalTo: banner.topAnchor).isActive = true
            line.heightAnchor.constraint(equalToConstant: 1).isActive = true
            
            banner.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            banner.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            banner.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            banner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -48).isActive = true
            
            return banner
        }()
        
        bannerTitle = {
            let label = UILabel()
            label.text = "Loading..."
            label.font = .systemFont(ofSize: 16)
            label.textColor = AppColors.prompt
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            bottomBanner.contentView.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: bottomBanner.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: bottomBanner.centerYAnchor).isActive = true
            
            return label
        }()
        
        emptyLabel = {
            let label = UILabel()
            label.isHidden = true
            label.textColor = AppColors.prompt
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: tableView.centerYAnchor).isActive = true
            
            return label
        }()
        
        loader = view.addLoader()
        loader.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
        loader.centerYAnchor.constraint(equalTo: tableView.centerYAnchor).isActive = true
        
        fetchEvents()
    }

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "By Event")
    }
    
    @objc private func pullToRefresh() {
        fetchEvents(pulled: true)
    }
    
    private func fetchEvents(pulled: Bool = false) {
        
        if !pulled {
            loader.isHidden = false
        }
        
        bannerTitle.text = "Loading..."
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/List",
                           parameters: ["orgId": Organization.current!.id])!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            DispatchQueue.main.async {
                self.loader.isHidden = true
                self.refreshControl.endRefreshing()
            }
            
            guard error == nil else {
                DispatchQueue.main.async {
                    if self.eventList.isEmpty {
                        self.emptyLabel.text = CONNECTION_ERROR
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
                DispatchQueue.global(qos: .default).async {
                    self.eventCollection = tmp
                    DispatchQueue.main.async {
                        self.bottomBanner.isHidden = false
                        self.emptyLabel.text = tmp.isEmpty ? "No Events" : ""
                        self.tableView.reloadData()
                        let s = tmp.count == 1 ? "" : "s"
                        self.bannerTitle.text = "\(tmp.count) Event\(s) in total."
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let effect: UIVisualEffect
        if #available(iOS 12.0, *), traitCollection.userInterfaceStyle == .dark {
            effect = UIBlurEffect(style: .regular)
        } else {
            effect = UIBlurEffect(style: .extraLight)
        }
        
        bottomBanner.effect = effect
    }
    
}


extension StatEventList: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let event = eventList[indexPath.row]
        
        let cell = EventsCell()
        cell.titleLabel.text = event.title
        cell.dateLabel.text = "\(event.interested.count) interested"
        
        if !event.hasVisual {
            cell.icon.image = #imageLiteral(resourceName: "berkeley")
        } else if event.eventVisual == nil {
            cell.icon.image = #imageLiteral(resourceName: "cover_placeholder")
            event.getCover { withImage in
                cell.icon.image = withImage.eventVisual
            }
        } else {
            cell.icon.image = event.eventVisual
        }
                
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let statsPage = EventDetailStats(event: eventList[indexPath.row])
        navigationController?.pushViewController(statsPage, animated: true)
    }
}
