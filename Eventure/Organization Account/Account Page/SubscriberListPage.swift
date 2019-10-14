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
    
    
    
    
    //define variables that stores all the subscribers of the club
    static var changed: Bool = false
    
    //counts the number of subscribers
    private var subscriberCount = 0
    private var myTableView: UITableView!
    private var backGroundLabel: UILabel!
    private var loadingBG: UIView!
    
    private var subscriberDictionaryList = Set<User>()
    private var sortedSubscribers = [User]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Subscribers"
        
        loadingBG = view.addLoader()
        loadingBG.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        loadingBG.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        backGroundLabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 17)
            label.textColor = .gray
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 10).isActive = true
            
            return label
        }()
        
        retreiveSubscribers()
        
        view.backgroundColor = AppColors.tableBG
        
        myTableView = UITableView(frame: .zero, style: .grouped)
        myTableView.dataSource = self
        myTableView.delegate = self
        myTableView.backgroundColor = .clear
        self.view.addSubview(myTableView)
        //set location constraints of the tableview
        myTableView.translatesAutoresizingMaskIntoConstraints = false
        myTableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        myTableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        myTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        myTableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        self.view.bringSubviewToFront(backGroundLabel)
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let subscriber = self.sortedSubscribers[indexPath.row]
        
        let cell = SubscribersCell()
        cell.titleLabel.text = subscriber.displayedName.isEmpty ? subscriber.displayedName : subscriber.fullName
        if cell.titleLabel.text!.isEmpty {
            cell.titleLabel.text = "User #\(subscriber.userID)"
        }
        cell.subtitleLabel.text = subscriber.email
        if cell.subtitleLabel.text!.isEmpty {
            cell.subtitleLabel.text = "Email not provided"
        }
        
        if subscriber.profilePicture != nil {
            cell.icon.image = subscriber.profilePicture
        } else {
            cell.icon.image = #imageLiteral(resourceName: "guest").withRenderingMode(.alwaysTemplate)
            subscriber.getProfilePicture { withProfile in
                cell.icon.image = withProfile.profilePicture
            }
        }
        
        return cell
    }
    
    //number of rows in the only section: number of subscribers
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.subscriberDictionaryList.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {return 50}
        return 30
    }
    
    
    func retreiveSubscribers() {
        backGroundLabel.text = ""
        
        loadingBG.isHidden = false
        
        var parameters = [String: String]()
        parameters["orgId"] = String(Organization.current!.id)
        
        let url = URL.with(base: API_BASE_URL, API_Name: "account/ListSubscribers", parameters: parameters)!
        
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            DispatchQueue.main.async {
                self.loadingBG.isHidden = true
            }
            
            guard error == nil else {
                DispatchQueue.main.async {
                    self.backGroundLabel.text = "Bad internet connection"
                    internetUnavailableError(vc: self)
                    self.navigationController?.popViewController(animated: true)
                }
                return
            }
            
            if let subscriberList = try? JSON(data: data!).arrayValue {
                for subscriberData in subscriberList {
                    let subscriber = User(userInfo: subscriberData)
                    //store this User
                    self.subscriberDictionaryList.insert(subscriber)
                }
                
                self.sortedSubscribers = self.subscriberDictionaryList.sorted {
                    (user1, user2) -> Bool in
                    user1.username.lowercased() < user2.username.lowercased()
                }
                
                DispatchQueue.main.async {
                    if (self.subscriberDictionaryList.count == 0) {
                        self.backGroundLabel.text = "No subscribers"
                    } else {
                        self.backGroundLabel.text = ""
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
    } //function ends here
    
    
}
