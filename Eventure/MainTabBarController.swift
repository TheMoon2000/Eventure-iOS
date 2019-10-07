//
//  MainTabBarController.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/5/26.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class MainTabBarController: UITabBarController {
    
    static var current: MainTabBarController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        view.tintColor = MAIN_TINT
    }
    
    func loadSupportedCampuses() {
        
        if !Campus.supported.isEmpty { return }
        
        let url = URL(string: API_BASE_URL + "account/Campuses")!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                print("Failed to connect to the server. Retrying in 10 seconds...")
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    self.loadSupportedCampuses()
                }
                return
            }
            
            if String(data: data!, encoding: .utf8) == UNAUTHORIZED_ERROR {
                DispatchQueue.main.async {
                    authorizationError()
                }
                return
            }
            
            if let allCampuses = try? JSON(data: data!).arrayValue {
                for campus in allCampuses {
                    if campus.dictionary != nil {
                        let new = Campus(json: campus)
                        Campus.supported[new.fullName] = new
                    }
                }
                print("Loaded supported campuses: \(Campus.supported.keys)")
            } else {
                print(String(data: data!, encoding: .utf8)!)
            }
        }
        
        task.resume()
    }
    
    func checkForNotices() {
        /*
        let alert = UIAlertController(
            title: "Server Notice",
            message: String(data: data!, encoding: .utf8),
            preferredStyle: .alert)
        alert.addAction(.init(title: "Dismiss", style: .cancel, handler: { action in
            
        }))
        self.present(alert, animated: true, completion: nil)*/
    }
    
    private func setupUserTabs() {
                
        let tab1 = EventViewController()
        tab1.tabBarItem = UITabBarItem(title: "Events", image: #imageLiteral(resourceName: "search"), tag: 0)

        let tab2: UIViewController
        if UIDevice.current.userInterfaceIdiom == .pad {
            tab2 = OrgSplitViewController()
        } else {
            tab2 = OrganizationsViewController()
        }
        tab2.tabBarItem = UITabBarItem(title: "Organizations", image: #imageLiteral(resourceName: "organization"), tag: 1)
        
        let tab3 = AccountViewController()
        tab3.tabBarItem = UITabBarItem(title: "Me", image: #imageLiteral(resourceName: "home"), tag: 2)
        
        viewControllers = [tab1, tab2, tab3].map { vc in
            if vc is OrgSplitViewController {
                return vc
            }
            
            let nav = UINavigationController(rootViewController: vc)
            
            /// REPLACE
            nav.navigationBar.barTintColor = AppColors.navbar
         
            return nav
        }
        
    }
    
    private func setupOrganizationTabs() {
        
        tabBar.tintColor = MAIN_TINT
        
        let tab1 = OrgEventViewController()
        tab1.tabBarItem = UITabBarItem(title: "Event Posts", image: #imageLiteral(resourceName: "post"), tag: 0)
        
        let tab2 = OrgAccountPageController()
        tab2.tabBarItem = UITabBarItem(title: "Dashboard", image: #imageLiteral(resourceName: "dashboard"), tag: 1)
    
        viewControllers = [tab1, tab2].map {
            let nav = UINavigationController(rootViewController: $0)
            nav.navigationBar.barTintColor = AppColors.navbar
            
            return nav
        }
    }
    
    /// Should be called when user finished login.
    func openScreen(isUserAccount: Bool = true, page: Int = 0) {
        if isUserAccount {
            print("Logged in as '" + (User.current?.displayedName ?? "guest") + "'")
            setupUserTabs()
            User.current?.getProfilePicture(nil)
        } else {
            print("Logged in as organization '\(Organization.current?.title ?? "unknown")'")
            setupOrganizationTabs()
            Organization.current?.getLogoImage(nil)
        }
        selectedIndex = page
        dismiss(animated: true)
    }
    
    func loginSetup() {
        
        loadSupportedCampuses()
        checkForNotices()
        Major.recoverCache()
        Major.updateCurrentMajors(nil)
        
        if let type = UserDefaults.standard.string(forKey: KEY_ACCOUNT_TYPE) {
            if type == ACCOUNT_TYPE_ORG, let current = Organization.cachedOrgAccount(at: CURRENT_USER_PATH) {
                Organization.current = current
                User.current = nil
                openScreen(isUserAccount: false)
            } else if type == ACCOUNT_TYPE_USER, let current = User.cachedUser(at: CURRENT_USER_PATH) {
                User.current = current
                Organization.current = nil
                openScreen(isUserAccount: true)
            } else {
                openScreen()
            }
        } else {
            // Login as guest
            openScreen()
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
