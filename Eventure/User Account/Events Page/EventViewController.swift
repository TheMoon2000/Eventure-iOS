//
//  EventViewController.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/10.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class EventViewController: UIViewController {
    
    private var topTabBg: UIVisualEffectView!
    private var topTab: UISegmentedControl!
    private var eventCatalog: UICollectionView!
    private var spinner: UIActivityIndicatorView!
    private var spinnerLabel: UILabel!
    
    private(set) var allEvents = [Event]()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        title = "Events"
        
        func randString(length: Int) -> String {
            let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            return String((0..<length).map{ _ in letters.randomElement()! })
        }
        
        topTabBg = {
            let ev = UIVisualEffectView(effect: UIBlurEffect(style: .light))
            ev.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(ev)
            
            ev.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            ev.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            ev.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            ev.heightAnchor.constraint(equalToConstant: 60).isActive = true
            
            return ev
        }()
        
        topTab = {
            let tab = UISegmentedControl(items: ["Recommended", "Trending", "All Events"])
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
            ec.contentInset.top = topTabBg.frame.height
            ec.scrollIndicatorInsets.top = topTabBg.frame.height
            ec.backgroundColor = .init(white: 0.96, alpha: 1)
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
            spinner.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(spinner)
            
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            spinner.centerYAnchor.constraint(equalTo: eventCatalog.centerYAnchor, constant: -5).isActive = true
            
            return spinner
        }()
        
        spinnerLabel = {
            let label = UILabel()
            label.text = "Loading events..."
            label.font = .systemFont(ofSize: 17, weight: .medium)
            label.textColor = .darkGray
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: spinner.centerXAnchor).isActive = true
            label.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 10).isActive = true
            
            return label
        }()
        
        updateEvents()
    }
    
    private func updateEvents() {
        
        allEvents.removeAll()
        spinner.startAnimating()
        spinnerLabel.isHidden = false
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/List", parameters: [:])!
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
                }
                return
            }
            
            if let eventsList = try? JSON(data: data!).arrayValue {
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension EventViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allEvents.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "event", for: indexPath) as! EventCell
        cell.setupCellWithEvent(event: allEvents[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
    }
}

extension EventViewController: UICollectionViewDelegateFlowLayout {
    static let width: CGFloat = 360
    
    var usableWidth: CGFloat {
        return eventCatalog.safeAreaLayoutGuide.layoutFrame.width
    }
    
    var equalSpacing: CGFloat {
        let rowCount = floor(usableWidth / EventViewController.width)
        let extraSpace = usableWidth - rowCount * EventViewController.width
        return extraSpace / (rowCount + 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: EventViewController.width,
                      height: 385)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return equalSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return equalSpacing
    }
}
