//
//  AccountViewController.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/2.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

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
                let alert = UIAlertController(title: "Do you want to log off?", message: "Changes you've made have been saved.", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                    UserDefaults.standard.removeObject(forKey: KEY_ACCOUNT_TYPE)
                    User.current = nil
                    MainTabBarController.current.openScreen()
                }))
                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                
            }
        } else if indexPath.section == 1 && indexPath.row == 0 { //if the user tries to change the name
            if User.current == nil {
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
            } else {
                let modifyAccount = ModifyAccountPage(name: User.current!.displayedName)
                modifyAccount.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(modifyAccount, animated: true)
            }
        }
    }
    

    
    //create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell") as! AccountCell
        cell.setup(sectionNum: indexPath.section,rowNum: indexPath.row)
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
            return 4
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
    
}
