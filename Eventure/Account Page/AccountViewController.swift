//
//  AccountViewController.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/2.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import SwiftyJSON
import UIKit

class AccountViewController: UIViewController,UITableViewDelegate, UITableViewDataSource  {
    
    private var myArray: NSArray = ["First","Second","Sign In"] //experimental
    
    private var myTableView: UITableView!
    
    private var currentImageView: UIImageView!
    private var profilePicture: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        title = "Me"

        //myTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        myTableView = UITableView()
        myTableView.register(AccountCell.classForCoder(), forCellReuseIdentifier: "MyCell")
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
        //make sure table view appears limited
        self.myTableView.tableFooterView = UIView(frame: CGRect.zero)
        
    }
   

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    //when table view is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 3 && indexPath.row == 0 { //if the log off/sign in button is clicked
            if (tableView.cellForRow(at: indexPath)! as! AccountCell).function!.text! == "Sign In" {
                let login = LoginViewController()
                let nvc = InteractivePopNavigationController(rootViewController: login)
                nvc.isNavigationBarHidden = true
                login.navBar = nvc
                present(nvc, animated: true, completion: nil)
            } else {
                //pop out an alert window
                let alert = UIAlertController(title: "Do you want to log out?", message: "Changes you've made have been saved.", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Log out", style: .destructive, handler: { action in
                    UserDefaults.standard.removeObject(forKey: KEY_ACCOUNT_TYPE)
                    User.current = nil
                    MainTabBarController.current.openScreen()
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                
            }
        } else if indexPath.section == 1 && indexPath.row == 0 { //if the user tries to change account information
            if User.current == nil {
                popLoginReminder()
            } else {
                let personalInfo = PersonalInfoPage()
                personalInfo.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(personalInfo, animated: true)
            }
        } else if indexPath.section == 2 && indexPath.row == 3 { //if user wants to change the tags
            if User.current == nil {
                popLoginReminder()
            } else {
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
                
            }
        }
    }
    

    
    //create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell") as! AccountCell
        cell.setup(sectionNum: indexPath.section,rowNum: indexPath.row, type:"Account")
        if indexPath.section == 0 && indexPath.row == 0 {
            profilePicture = cell.functionImage.image
            cell.functionImage.isUserInteractionEnabled = true
            cell.functionImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:))))
        }
        return cell
    }
    
    //make the size of first cell (profile picture) larger
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0  {
            return 110.0
        }
        return 55.0
    }
    
    //number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }
    
    //section titles
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 1) {
            return "Personal Information"
        }
        if (section == 2) {
            return "Personal Interests"
        }
        if (section == 3) {
            return "Account"
        }
        return ""
    }
    
    //rows in sections
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int {
        if(section == 0) {
            return 1
        } else if(section == 1) {
            return 1
        } else if (section == 2){
            return 4
        } else {
            return 1
        }
    }
    
    //eliminate first section header
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 1.0 : 32
    }
    
    
    //full screen profile picture when tapped
    @objc private func imageTapped(_ sender: UITapGestureRecognizer) {
        let sv = UIScrollView(frame: UIScreen.main.bounds)
        sv.backgroundColor = .white
        sv.maximumZoomScale = 3.0
        sv.minimumZoomScale = 1.0
        sv.delegate = self
        
        let iv = UIImageView(image: profilePicture)
        iv.contentMode = .center
        currentImageView = iv
        iv.frame = sv.frame
        
        sv.addSubview(iv)
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        sv.addGestureRecognizer(tap)
        
        self.view.addSubview(sv)
        self.navigationController?.isNavigationBarHidden = true
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
