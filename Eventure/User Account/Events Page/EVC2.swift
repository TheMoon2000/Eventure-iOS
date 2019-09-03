//
//  EventsViewController.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/5/26.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class EventsViewController2: UITableViewController {
    var events = [Event]()
    var cells = [EventCell]()
    var fetchingmore = false
    var event: Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        title = "Events"
        self.tableView.register(EventCell.self, forCellReuseIdentifier: "cell")
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = CGFloat(EventCell.height)
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = .init(white: 0.95, alpha: 1)
        
        getEvents()
        
        
    }
    
    
    private func randString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    private func getEvents() {
        //TODO: add Server Retrieval, now only manually creating events
        var result = [Event]()
        for _ in 1...20 {
            let e = Event(uuid: UUID().uuidString, title: randString(length: 10), time: String(Int.random(in: 1999...2019))+"-"+String(Int.random(in: 1...12))+"-"+String(Int.random(in: 1...31)), location: randString(length: 10), tags: [randString(length: 4),randString(length: 4)], hostTitle: randString(length: 15))
            result.append(e)
        }
        events.append(contentsOf: result)
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(EventCell.height)
        //return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //return [1, 4, 3, 1][section]
        
        return events.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EventCell
        //cell.textLabel?.text = " \(events[indexPath.row].title)"
        cell.makeEvent(e: events[indexPath.row])
        
        return cell
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(events.count)
        let down = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.height
        print("\(down)|\(contentHeight)|\(frameHeight)")
        if (down > contentHeight - frameHeight) {
            if (!fetchingmore) {
                fetchingmore = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    self.getEvents()
                    self.fetchingmore = false
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        event = events[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        let nextVC = DetailViewController()
        nextVC.event = event
        present(nextVC, animated: true, completion: nil)
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
