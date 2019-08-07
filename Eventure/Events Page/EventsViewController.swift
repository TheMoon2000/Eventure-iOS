//
//  EventsViewController.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/5/26.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class EventsViewController: UIViewController {
    var events: [Event] = []
    var canvas: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        title = "Events"
        getEvents()
        populateCanvas()
        
    }
    private func randString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    private func getEvents() {
        //TODO: add Server Retrieval, now only manually creating events
        self.events = {
            let result = [Event]()
            for _ in 1...5 {
                let e = Event(id: String(Int.random(in: 1...1000)), title: randString(length: 10), time: String(Int.random(in: 1999...2019))+"-"+String(Int.random(in: 1...12))+"-"+String(Int.random(in: 1...31)), location: randString(length: 10), tags: [randString(length: 4),randString(length: 4)], hostTitle: randString(length: 15))
                events.append(e)
            }
            return result
        }()
    }
    private func populateCanvas() {
        canvas = UITableView(frame: view.bounds, style: .plain)
        
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
