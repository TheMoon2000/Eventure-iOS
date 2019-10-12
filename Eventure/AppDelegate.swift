//
//  AppDelegate.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/5/26.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    static var suppressNotifications = false
    
    var orientationLock = UIInterfaceOrientationMask.all
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        
        let entrypoint = MainTabBarController()
        MainTabBarController.current = entrypoint
        window?.rootViewController = entrypoint
        entrypoint.loginSetup()
        
        window?.makeKeyAndVisible()
        
        application.applicationIconBadgeNumber = 0
        
        if User.current == nil && Organization.current == nil && !UserDefaults.standard.bool(forKey: "Has logged in") {
            let login = LoginViewController()
            let nvc = InteractivePopNavigationController(rootViewController: login)
            nvc.isNavigationBarHidden = true
            login.navBar = nvc
            nvc.modalPresentationStyle = .fullScreen
            entrypoint.present(nvc, animated: false)
            UserDefaults.standard.setValue(true, forKey: "Has logged in")
        }
        
        registerForPushNotifications()
        
        if let notification = launchOptions?[.remoteNotification] as? [String: Any], let aps = notification["aps"] {
            handleAPSPacket(packet: JSON(aps))
        }
        
        return true
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Eventure")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            
            guard granted else { return }
            // 2. Attempt registration for remote notifications on the main thread
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        // 1. Convert device token to string
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        // 2. Print device token to use for PNs payloads
        print("Device Token: \(token)")
        User.token = token
        
        // 3. Register for notification actions
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // 1. Print out error if PNs registration not successful
        print("Failed to register for remote notifications with error: \(error)")
        User.token = "no token"
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        guard userInfo["aps"] != nil else { return }
        
        handleAPSPacket(packet: JSON(userInfo["aps"]!))
    }
    
    func handleAPSPacket(packet: JSON) {
        
        if AppDelegate.suppressNotifications { return }
        
        let info = packet.dictionaryValue
        
        guard let type = info["type"]?.string, let keyType = NotificationKeys(rawValue: type) else {
            print("WARNING: Notification type is not defined or unrecognized")
            return
        }
        
        switch keyType {
        case .oneTimeCode:
            guard let code = info["code"]?.string else { return }
            guard let username = info["name"]?.string else { return }
            guard let title_base64 = info["list name"]?.string, let titleData = Data(base64Encoded: title_base64) else {
                print("WARNING: Cannot parse APS packet: \(info)")
                return
            }
            
            guard let title = String(data: titleData, encoding: .utf8) else { return }
            
            let alert = UIAlertController(title: "New check-in request", message: "User '\(username)' would like to check-in for '\(title)'. The 6-digit verification code is \(code).", preferredStyle: .alert)
            alert.addAction(.init(title: "Done", style: .cancel))
            UIApplication.topMostViewController?.present(alert, animated: true, completion: nil)
        case .generalNotice:
            guard let alertInfo = info["alert"]?.dictionary else { return }
            guard let title = alertInfo["title"]?.string else { return }
            guard let body = alertInfo["body"]?.string else { return }
            
            let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
            alert.addAction(.init(title: "Dismiss", style: .cancel))
            UIApplication.topMostViewController?.present(alert, animated: true)
        case .ticketActivation:
            NotificationCenter.default.post(name: TICKET_ACTIVATED, object: packet.dictionaryObject as? [String : String])
        case .ticketRequest:
            NotificationCenter.default.post(name: NEW_TICKET_REQUEST, object: nil)
        case .ticketTransferRequest:
            print(info)
            guard let alertMsg = info["alert"]?.dictionary?["body"]?.string else { return }
            guard let requesterID = info["Requester ID"]?.int else { return }
            guard let ticketID = info["Ticket ID"]?.string else { return }
            
            let alert = UIAlertController(title: "Ticket transfer request", message: alertMsg + "\n\n" + "If you approve this ticket transfer, the requester will immediately become the new owner of this ticket. Please confirm that you have received all necessary payments (if any) before proceeding.", preferredStyle: .alert)
            alert.addAction(.init(title: "Decline", style: .cancel, handler: { _ in
                self.respondToTransferRequest(ticketID: ticketID, approve: false, newOwner: requesterID)
            }))
            alert.addAction(.init(title: "Approve", style: .default, handler: { _ in
                self.respondToTransferRequest(ticketID: ticketID, approve: true, newOwner: requesterID)
            }))
            UIApplication.topMostViewController?.present(alert, animated: true)
        case .ticketTransferApproved, .ticketTransferDeclined:
            let approved = keyType == .ticketTransferApproved
            let ticketID = info["Ticket ID"]?.string ?? ""
            NotificationCenter.default.post(name: TICKET_TRANSFER_STATUS, object: (approved, ticketID))
        default:
            print(info)
        }
    }
    
    @objc private func respondToTransferRequest(ticketID: String, approve: Bool, newOwner: Int) {
        
        let parameters = [
            "ticketId": ticketID,
            "approve": approve ? "1" : "0",
            "newOwner": String(newOwner)
        ]
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/RespondTransferRequest",
                           parameters: parameters)!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                DispatchQueue.main.async {
                    internetUnavailableError(vc: UIApplication.topMostViewController!)
                }
                return
            }
        }
        
        task.resume()
    }
    
}

extension AppDelegate {
    struct AppUtility {
        static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                delegate.orientationLock = orientation
            }
        }
        
        static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
            self.lockOrientation(orientation)
            UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        }
    }
}

