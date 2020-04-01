//
//  AllDiningHalls.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/3/25.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON
import XLPagerTabStrip

class AllDiningHalls: UIViewController {
    
    private var diningMenus = [[String: DiningMenu]]() // One menu object for each dining hall for each day
    private var currentDay = 0 // Number between 0 - 6
    
    private var loader: UIVisualEffectView!
    private var tabs: DiningMenuTabsMain!
    
    private var navigator: UIVisualEffectView!
    private var navigatorTitle: UILabel!
    private var previousButton: UIButton!
    private var nextButton: UIButton!
    
    var mealtime: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        title = "Dining Hall Menus"
        view.backgroundColor = AppColors.canvas
                
        loader = view.addLoader()
        loader.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        loader.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true

        navigator = {
            let v = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
            v.backgroundColor = AppColors.canvas.withAlphaComponent(0.5)
            v.layer.shadowOpacity = 0.05
            v.layer.shadowOffset.height = -1
            v.layer.shadowRadius = 4
            v.isHidden = true
            v.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(v)
            
            v.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            v.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            v.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            v.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50).isActive = true
            
            return v
        }()
        
        navigatorTitle = {
            let label = UILabel()
            label.font = .appFontMedium(15)
            label.textColor = AppColors.emphasis
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            navigator.contentView.addSubview(label)
            
            label.centerYAnchor.constraint(equalTo: navigator.safeAreaLayoutGuide.centerYAnchor).isActive = true
            return label
        }()
        
        previousButton = {
            let button = UIButton(type: .system)
            button.tintColor = AppColors.control
            button.setImage(#imageLiteral(resourceName: "previous").withRenderingMode(.alwaysTemplate), for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.translatesAutoresizingMaskIntoConstraints = false
            navigator.contentView.addSubview(button)
            
            button.centerYAnchor.constraint(equalTo: navigatorTitle.centerYAnchor).isActive = true
            button.leftAnchor.constraint(equalTo: navigator.safeAreaLayoutGuide.leftAnchor, constant: 15).isActive = true
            button.rightAnchor.constraint(equalTo: navigatorTitle.leftAnchor, constant: -5).isActive = true
            button.widthAnchor.constraint(equalToConstant: 28).isActive = true
            button.heightAnchor.constraint(equalToConstant: 20).isActive = true
            
            button.addTarget(self, action: #selector(prevMeal), for: .touchUpInside)
            
            return button
        }()
        
        nextButton = {
            let button = UIButton(type: .system)
            button.tintColor = AppColors.control
            button.setImage(#imageLiteral(resourceName: "next").withRenderingMode(.alwaysTemplate), for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.translatesAutoresizingMaskIntoConstraints = false
            navigator.contentView.addSubview(button)
            
            button.centerYAnchor.constraint(equalTo: navigatorTitle.centerYAnchor).isActive = true
            button.rightAnchor.constraint(equalTo: navigator.safeAreaLayoutGuide.rightAnchor, constant: -15).isActive = true
            button.leftAnchor.constraint(equalTo: navigatorTitle.rightAnchor, constant: 5).isActive = true
            button.widthAnchor.constraint(equalToConstant: 28).isActive = true
            button.heightAnchor.constraint(equalToConstant: 20).isActive = true
            
            button.addTarget(self, action: #selector(nextMeal), for: .touchUpInside)
            
            return button
        }()
        
        let line = UIView()
        line.backgroundColor = AppColors.line
        line.translatesAutoresizingMaskIntoConstraints = false
        navigator.contentView.addSubview(line)
        
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        line.leftAnchor.constraint(equalTo: navigator.leftAnchor).isActive = true
        line.rightAnchor.constraint(equalTo: navigator.rightAnchor).isActive = true
        line.topAnchor.constraint(equalTo: navigator.topAnchor).isActive = true
        
        
        let currentHour = Date.currentHour
        
        if currentHour > 20 || currentHour <= 9 {
            mealtime = 0
        } else if currentHour <= 14 {
            mealtime = 1
        } else {
            mealtime = 2
        }
        
        updateNavigatorTitle()
        fetchDiningInfo()
    }
    
    private func updateNavigatorTitle() {
        
        previousButton.isEnabled = true
        nextButton.isEnabled = true
        
        switch (currentDay, mealtime) {
        case (0, 0):
            navigatorTitle.text = "Today‘s Breakfast"
            previousButton.isEnabled = false
        case (0, 1):
            navigatorTitle.text = "Today‘s Lunch"
        case (0, 2):
            navigatorTitle.text = "Today's Dinner"
        case (1, 0):
            navigatorTitle.text = "Tomorrow's Breakfast"
        case (1, 1):
            navigatorTitle.text = "Tomorrow's Lunch"
        case (1, 2):
            navigatorTitle.text = "Tomorrow's Dinner"
        default:
            let mealName = ["Breakfast", "Lunch", "Dinner"][mealtime]
            let df = DateFormatter()
            df.dateFormat = "EEEE"
            df.locale = .init(identifier: "en_US")
            let day = Date().addingTimeInterval(86400 * Double(currentDay))
            navigatorTitle.text = df.string(from: day) + "‘s \(mealName)"
        }
        
        if (currentDay, mealtime) == (6, 2) {
            nextButton.isEnabled = false
        }
    }
    
    @objc private func prevMeal() {
        if mealtime > 0 {
            mealtime -= 1
        } else if currentDay > 0 {
            currentDay -= 1
            mealtime = 2
        }
        
        updateNavigatorTitle()
        tabs.viewControllers.forEach { ($0 as? DiningMenuVC)?.updateMeal(day: currentDay, mealTime: mealtime) }
    }
    
    @objc private func nextMeal() {
        if mealtime < 2 {
            mealtime += 1
        } else if currentDay < 6 {
            currentDay += 1
            mealtime = 0
        }
        
        updateNavigatorTitle()
        tabs.viewControllers.forEach { ($0 as? DiningMenuVC)?.updateMeal(day: currentDay, mealTime: mealtime) }
    }
    
    private func showTabs() {
        
        guard !diningMenus.isEmpty else { return }
        
        tabs = {
            let tabs = DiningMenuTabsMain(menus: diningMenus, mealTime: mealtime)
            tabs.view.translatesAutoresizingMaskIntoConstraints = false
            navigator.isHidden = false
            view.insertSubview(tabs.view, belowSubview: navigator)
            
            tabs.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            tabs.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            tabs.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            tabs.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            addChild(tabs)
            tabs.didMove(toParent: self)
            
            return tabs
        }()
    }
    
    private func fetchDiningInfo() {
                
        loader.isHidden = false
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/GetDiningMenu",
                           parameters: [:])!
        var request = URLRequest(url: url)
        request.addAuthHeader()

        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            DispatchQueue.main.async {
                UIView.transition(with: self.loader, duration: 0.2, options: .curveEaseOut, animations: {
                    self.loader.isHidden = true
                })
            }
            
            guard error == nil else {
                internetUnavailableError(vc: self)
                return
            }
            
            var tmp = [[String: DiningMenu]].init(repeating: [:], count: 21)
            
            if let info = try? JSON(data: data!).dictionaryValue {
                                                                
                for (mealName, mealMenus) in info {
                    let mealtime = ["Breakfast", "Lunch", "Dinner"].index(of: mealName) ?? 0
                    
                    for menu in mealMenus.arrayValue {
                        if mealtime == 0 {
                            let menu = BreakfastMenu(json: menu)
                            tmp[menu.day * 3][menu.location] = menu
                        } else if mealtime == 1 {
                            let menu = LunchDiningMenu(json: menu)
                            tmp[menu.day * 3 + 1][menu.location] = menu
                        } else {
                            let menu = DinnerDiningMenu(json: menu)
                            tmp[menu.day * 3 + 2][menu.location] = menu
                        }
                    }
                }
                
                self.diningMenus = tmp
                DispatchQueue.main.async {
                    self.showTabs()
                }
            } else {
                print("An error occurred while parsing dining menus!")
            }
        }
        
        task.resume()
    }

}
    
