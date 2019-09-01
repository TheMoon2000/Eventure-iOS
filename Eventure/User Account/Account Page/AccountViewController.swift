//
//  AccountViewController.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/2.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import SwiftyJSON
import UIKit

class AccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    private var myTableView: UITableView!
    
    private var currentImageView: UIImageView!
    private var profilePicture: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        title = User.waitingForSync ? "Syncing..." : "Me"

        //myTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(userUpdated), name: USER_SYNC_FAILED, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userUpdated), name: USER_SYNC_SUCCESS, object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.performWithoutAnimation {
            self.myTableView.beginUpdates()
            self.myTableView.endUpdates()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func userUpdated() {
        DispatchQueue.main.async {
            self.title = "Me"
            self.navigationController?.navigationBar.setNeedsDisplay()
            UIView.performWithoutAnimation {
                self.myTableView.reloadRows(at: [[1, 1]], with: .none)
            }
        }
    }
    
    //when table view is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath != [4, 0] {
            guard User.current != nil else {
                popLoginReminder()
                return
            }
        }
        
        switch (indexPath.section, indexPath.row) {
            
        case (1, 0): // if the user tries to change account information
            let personalInfo = PersonalInfoPage()
            personalInfo.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(personalInfo, animated: true)
        case (1, 1):
            let profileInfo = ProfileInfoPage()
            profileInfo.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(profileInfo, animated: true)
        case (2, 0):
            let scanVC = ScannerViewController()
            scanVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(scanVC, animated: true)
        case (3, 3):
            //if user wants to change the tags
            let tagPicker = TagPickerView()
            tagPicker.customTitle = "What interests you?"
            tagPicker.customSubtitle = "Pick at least one. The more the better!"
            tagPicker.maxPicks = 3
            tagPicker.customButtonTitle = "Done"
            tagPicker.customContinueMethod = { tagPicker in
                
                tagPicker.spinner.removeFromSuperview()
                
                let loadingView: UIView = UIView()
                loadingView.frame = CGRect(x:0, y:0, width:110, height:110)
                loadingView.center = tagPicker.view.center
                loadingView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
                loadingView.clipsToBounds = true
                loadingView.layer.cornerRadius = 10
                
                let label = UILabel()
                label.text = "Updating..."
                label.font = .systemFont(ofSize: 17, weight: .medium)
                label.textColor = .white
                label.translatesAutoresizingMaskIntoConstraints = false
                loadingView.addSubview(label)
                label.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor).isActive = true
                label.topAnchor.constraint(equalTo: loadingView.topAnchor,constant:80).isActive = true
                
                loadingView.addSubview(tagPicker.spinner)
                tagPicker.view.addSubview(loadingView)
                
                tagPicker.spinner.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor).isActive = true
                tagPicker.spinner.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor, constant: -5).isActive = true
                
                tagPicker.spinner.startAnimating()
                
                User.current!.tags = tagPicker.selectedTags
                
                let url = URL(string: API_BASE_URL + "account/UpdateTags")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.addAuthHeader()
                
                var body = JSON()
                body.dictionaryObject?["uuid"] = User.current?.uuid
                let tagsArray = tagPicker.selectedTags.map { $0 }
                body.dictionaryObject?["tags"] = tagsArray
                request.httpBody = try? body.rawData()
                
                let task = CUSTOM_SESSION.dataTask(with: request) {
                    data, response, error in
                    
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                    guard error == nil else {
                        DispatchQueue.main.async {
                            internetUnavailableError(vc: self)
                        }
                        return
                    }
                    
                    let msg = String(data: data!, encoding: .ascii) ?? ""
                    switch msg {
                    case INTERNAL_ERROR:
                        serverMaintenanceError(vc: self)
                    case "success":
                        print("successfully updated tags")
                        User.current!.tags = Set(tagsArray)
                    default:
                        break
                    }
                }
                
                task.resume()
            }
            
            tagPicker.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(tagPicker, animated: true)
            
            DispatchQueue.main.async {
                tagPicker.selectedTags = User.current!.tags
            }
            
        case (4, 0): // if the log out/sign in button is clicked
            if (User.current == nil) {
                let login = LoginViewController()
                let nvc = InteractivePopNavigationController(rootViewController: login)
                nvc.isNavigationBarHidden = true
                login.navBar = nvc
                present(nvc, animated: true, completion: nil)
            } else {
                //pop out an alert window
                let alert = UIAlertController(title: "Do you want to log out?", message: "Changes you've made have been saved.", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { action in
                    UserDefaults.standard.removeObject(forKey: KEY_ACCOUNT_TYPE)
                    User.current = nil
                    MainTabBarController.current.openScreen()
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                self.present(alert, animated: true)
            }
        default:
            break
        }
    }
    

    
    //create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = SettingsItemCell()
        
        switch (indexPath.section, indexPath.row) {
            
        case (0, 0):
            cell.icon.image = User.current?.profilePicture
            if cell.icon.image == nil && User.current != nil {
                cell.icon.image = User.current!.gender == .male ? #imageLiteral(resourceName: "default male") : #imageLiteral(resourceName: "default_female")
            } else {
                cell.icon.image = #imageLiteral(resourceName: "guest_profile")
            }
            cell.imageWidthConstraint.constant = 65
            cell.heightConstraint.constant = 100
            cell.spacingConstraint.constant = 18
            cell.titleLabel.text = "Profile Picture"
        case (1, 0):
            cell.icon.image = #imageLiteral(resourceName: "default_user")
            cell.titleLabel.text = "Manage Account"
        case (1, 1):
            cell.icon.image = #imageLiteral(resourceName: "profile")
            cell.titleLabel.text = "Professional Profile"
            cell.valueLabel.text = User.current?.profileStatus
        case (2, 0):
            cell.icon.image = #imageLiteral(resourceName: "scan").withRenderingMode(.alwaysTemplate)
            cell.titleLabel.text = "Scan Event Code"
        case (3, 0):
            cell.icon.image = #imageLiteral(resourceName: "heart").withRenderingMode(.alwaysTemplate)
            cell.titleLabel.text = "Favorite Events"
        case (3, 1):
            cell.icon.image = #imageLiteral(resourceName: "done")
            cell.titleLabel.text = "Going"
        case (3, 2):
            cell.icon.image = #imageLiteral(resourceName: "subscribe")
            cell.titleLabel.text = "Subscriptions"
        case (3, 3):
            cell.icon.image = #imageLiteral(resourceName: "tag")
            cell.titleLabel.text = "My Tags"
        case (4, 0):
            let cell = UITableViewCell()
            cell.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            let label = UILabel()
            label.text = User.current != nil ? "Log Out" : "Log In"
            label.font = .systemFont(ofSize: 17)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            cell.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
            
            return cell
        default:
            break
        }
        
        return cell
    }
    
    //number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    //section titles
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return [
            "",
            "Personal Information",
            "Event Check-in",
            "Personal Interests",
            nil
        ][section]
    }
    
    //rows in sections
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int {
        return [1, 2, 1, 4, 1][section]
    }
    
    //eliminate first section header
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return [0, 30, 30, 30, 30][section]
    }
    
    
    //full screen profile picture when tapped
    @objc private func imageTapped(_ sender: UITapGestureRecognizer) {
        let fullScreen = ImageFullScreenPage(image: profilePicture)
        present(fullScreen, animated: true, completion: nil)
    }
    
    //exit profile picture fullscreen
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        sender.view?.removeFromSuperview()
        currentImageView = nil
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return currentImageView
    }
    
    func popLoginReminder() {
        let alert = UIAlertController(title: "Do you want to log in?", message: "Log in to make changes to your account.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            let login = LoginViewController()
            let nvc = InteractivePopNavigationController(rootViewController: login)
            nvc.isNavigationBarHidden = true
            login.navBar = nvc
            self.present(nvc, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
}
