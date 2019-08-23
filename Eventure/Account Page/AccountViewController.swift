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
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("triggered")
        if UserDefaults.standard.string(forKey: KEY_ACCOUNT_TYPE) == nil {
            print("Not signed in")
            myArray = ["First","Second","Sign In"]
            
        } else {
            print("signed in")
            myArray = ["First","Second","Sign Out"]
        }
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
        print("Num: \(indexPath.row)")
        print("Value: \(myArray[indexPath.row])")
        if indexPath.row == 2 {
            if tableView.cellForRow(at: indexPath)!.textLabel!.text! == "Sign In" {
                let login = LoginViewController()
                let nvc = InteractivePopNavigationController(rootViewController: login)
                nvc.isNavigationBarHidden = true
                login.navBar = nvc
                present(nvc, animated: true, completion: nil)
            } else {
                print("signing out")
                UserDefaults.standard.removeObject(forKey: KEY_ACCOUNT_TYPE)
                User.current = nil
                MainTabBarController.current.openScreen()
            }
        }
        if indexPath.row == 1{
            myTableView.cellForRow(at: indexPath)?.textLabel!.text! = "change"
        }
    }
    

    
    //create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell") as! AccountCell
        cell.setup(rowNum: indexPath.row)
        return cell
    }
    
    //make the size of first cell (profile picture) larger
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 || indexPath.section == 3 && indexPath.row == 0 {
            return 100.0
        }
        return 50.0
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
    
    
}
