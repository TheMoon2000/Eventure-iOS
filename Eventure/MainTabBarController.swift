//
//  MainTabBarController.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/5/26.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    static var current: MainTabBarController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        self.setupUserTabs() // Guest login assumes user identity
        
        view.tintColor = MAIN_TINT
    }
    
    private func setupUserTabs() {
                
        let tab1 = EventViewController()
        tab1.tabBarItem = UITabBarItem(title: "Events", image: #imageLiteral(resourceName: "search"), tag: 0)

        let tab2 = OrganizationsViewController()
        tab2.tabBarItem = UITabBarItem(title: "Organizations", image: #imageLiteral(resourceName: "organization"), tag: 1)
        
        let tab3 = AccountViewController()
        tab3.tabBarItem = UITabBarItem(title: "Me", image: #imageLiteral(resourceName: "home"), tag: 2)
        
        
        viewControllers = [tab1, tab2, tab3].map {
            let nav = UINavigationController(rootViewController: $0)
            
            /// REPLACE
            nav.navigationBar.barTintColor = NAVBAR_TINT
         
            return nav
        }
    }
    
    private func setupOrganizationTabs() {
        
        tabBar.tintColor = MAIN_TINT
        
        let tab1 = OrgEventViewController()
        tab1.tabBarItem = UITabBarItem(title: "Event Posts", image: #imageLiteral(resourceName: "post"), tag: 0)
        
        let tab2 = AccountViewController()
        tab2.tabBarItem = UITabBarItem(title: "Account Settings", image: #imageLiteral(resourceName: "settings"), tag: 1)
    
        viewControllers = [tab1, tab2].map {
            let nav = UINavigationController(rootViewController: $0)
            /// REPLACE
            nav.navigationBar.barTintColor = NAVBAR_TINT
            
            return nav
        }
    }
    
    /// Should be called when user finished login.
    func openScreen(isUserAccount: Bool = true) {
        if isUserAccount {
            print("Logged in as '" + (User.current?.displayedName ?? "guest") + "'")
            setupUserTabs()
        } else {
            print("Logged in as organization '\(Organization.current?.title ?? "unknown")'")
            setupOrganizationTabs()
        }
        dismiss(animated: true, completion: nil)
    }
    
    func loginSetup() {
        if let type = UserDefaults.standard.string(forKey: KEY_ACCOUNT_TYPE) {
            if type == ACCOUNT_TYPE_ORG {
                openScreen(isUserAccount: false)
            } else {
                setupUserTabs()
            }
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
    
}
