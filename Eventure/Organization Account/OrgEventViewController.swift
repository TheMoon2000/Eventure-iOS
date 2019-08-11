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

    private let refreshControl = UIRefreshControl()
    private let refreshControlAttributes: [NSAttributedString.Key: Any] = [
        NSMutableAttributedString.Key.foregroundColor: UIColor.gray,
        .font: UIFont.systemFont(ofSize: 17, weight: .medium)
    ]
    
    private var topTabBg: UIVisualEffectView!
    private var topTab: UISegmentedControl!
    private var eventCatalog: UICollectionView!
    private var spinner: UIActivityIndicatorView!
    private var spinnerLabel: UILabel!
    
    private(set) var allEvents = [Event]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "Event Posts"
        
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
            
            return tab
        }()
        
        topTabBg.layoutIfNeeded()
        
        eventCatalog = {
            let ec = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
            ec.delegate = self
            ec.dataSource = self
            ec.refreshControl = self.refreshControl
            ec.contentInset.top = topTabBg.frame.height + 8
            ec.contentInset.bottom = 8
            ec.scrollIndicatorInsets.top = topTabBg.frame.height
            ec.backgroundColor = .init(white: 0.92, alpha: 1)
            ec.register(OrgEventCell.classForCoder(), forCellWithReuseIdentifier: "org event")
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
        
        refreshControl.addTarget(self, action: #selector(pullDownRefresh), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Reload", attributes: refreshControlAttributes)
        refreshControl.tintColor = MAIN_TINT
        
        //        updateEvents()
        generateRandomEvents()
    }
    
    /// Debugging only
    private func generateRandomEvents() {
        
        func randString(length: Int) -> String {
            let letters = "abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 "
            return String((0..<length).map{ _ in letters.randomElement()! })
        }
        
        for _ in 1...20 {
            let e = Event(uuid: UUID().uuidString,
                          title: randString(length: 25),
                          time: String(Int.random(in: 1999...2019))+"-"+String(Int.random(in: 1...12))+"-"+String(Int.random(in: 1...31)),
                          location: randString(length: 30),
                          tags: [randString(length: 4),randString(length: 4)],
                          hostTitle: randString(length: 30))
            allEvents.append(e)
        }
    }
    
    @objc private func pullDownRefresh() {
        updateEvents(pulled: true)
    }
    
    private func updateEvents(pulled: Bool = false) {
        
        if !pulled {
            spinner.startAnimating()
            spinnerLabel.isHidden = false
            allEvents.removeAll()
            eventCatalog.reloadSections(IndexSet(arrayLiteral: 0))
            refreshControl.isEnabled = false
            refreshControl.isHidden = true
        }
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/List", parameters: [:])!
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
                    internetUnavailableError(vc: self)
                }
                return
            }
            
            if let eventsList = try? JSON(data: data!).arrayValue {
                self.allEvents.removeAll()
                for event in eventsList {
                    self.allEvents.append(Event(eventInfo: event))
                }
                DispatchQueue.main.async {
                    self.eventCatalog.reloadSections(IndexSet(arrayLiteral: 0))
                }
            } else {
                print(String(data: data!, encoding: .utf8)!)
            }
        }
        
        task.resume()
    }
    
    
}

// MARK: - Extension on datasource and delegate
extension OrgEventViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allEvents.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "org event", for: indexPath) as! OrgEventCell
        cell.setupCellWithEvent(event: allEvents[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let detailPage = EventDetailPage()
        detailPage.event = allEvents[indexPath.row]
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
        cell.setupCellWithEvent(event: allEvents[indexPath.row])
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
