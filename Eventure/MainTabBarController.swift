//
//  MainTabBarController.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/5/26.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        self.setupTabs()
    }
    
    private func setupTabs() {
        
        tabBar.tintColor = MAIN_TINT
        
        // Here are some demo tabs. Replace them!
        let tab1 = FirstTabViewController()
        let tab2 = SecondTabViewController()
        tab1.tabBarItem = UITabBarItem(title: "First Tab", image: #imageLiteral(resourceName: "search"), tag: 0)
        tab2.tabBarItem = UITabBarItem(title: "Second Tab", image: #imageLiteral(resourceName: "settings"), tag: 1)
        
        self.viewControllers = [tab1, tab2].map {
            let nav = UINavigationController(rootViewController: $0)
            
            /// REPLACE
            nav.navigationBar.barTintColor = NAVBAR_TINT
            
            return nav
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
