//
//  subscriberListPage.swift
//  Eventure
//
//  Created by Prince Wang on 2019/9/1.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class SubscriberListPage: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //number of rows in the only section: number of subscribers
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.subscriberDictionaryList.count
    }
    
    
    //define variables that stores all the subscribers of the club
    
    static var changed: Bool = false
    
    //counts the number of subscribers
    private var subscriberCount = 0
    private var myTableView: UITableView!
    private var spinner: UIActivityIndicatorView!
    private var spinnerLabel: UILabel!
    private var backGroundLabel: UILabel!
    
    private var displayedUsers = [[User]]()
    private var labels = [String]()
    private var sections = 0
    private var rowsForSection = [Int]()
    
    
    private var subscriberDictionaryList = [User]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        title = String(Organization.current!.subscribers.count) + " Subscribers"
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
            label.text = "no subscribers yet"
            label.isHidden = true
            label.font = .systemFont(ofSize: 17, weight: .medium)
            label.textColor = .darkGray
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: spinner.centerXAnchor).isActive = true
            label.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 10).isActive = true
            
            return label
        }()
        
        retreiveSubscribers()
        
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
        if SubscriberListPage.changed {
            clearAll()
            viewDidLoad()
            SubscriberListPage.changed = false
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("place0")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let subscriber = self.subscriberDictionaryList[indexPath.row]
        let cell = SubscribersCell()
        cell.titleLabel.text = subscriber.displayedName //FIXME: wait for jerry
        
        if subscriber.profilePicture != nil {
            cell.icon.image = subscriber.profilePicture
        } else {
            //fixme: change profile picture based on gender
            cell.icon.image = #imageLiteral(resourceName: "icons8-gender_neutral_user.png")
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {return 1}
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {return 50}
        return 30
    }
    
    
    
    
    //Done
    func retreiveSubscribers() {
        spinner.startAnimating()
        spinnerLabel.isHidden = false
        
        var parameters = [String: String] ()
        parameters["orgId"] = String(Organization.current!.id)
        
        let url = URL.with(base: API_BASE_URL, API_Name: "account/ListSubscribers", parameters: parameters)!
        
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
            
            if let subscriberList = try? JSON(data: data!).arrayValue {
                for subscriberData in subscriberList {
                    let subscriber = User(userInfo: subscriberData)
                    //store this User
                    self.subscriberDictionaryList.append(subscriber)
                    print(subscriber.displayedName)
                    self.subscriberCount += 1
                }
                //Don't need to group events
                
                DispatchQueue.main.async {
                    if (self.subscriberDictionaryList.count == 0) {
                        self.backGroundLabel.isHidden = false
                    }
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
    } //function ends here
    
    func clearAll() {
        
        sections = 0
        labels.removeAll()
        rowsForSection.removeAll()
        
        subscriberDictionaryList.removeAll()
    }
    
}
