//
//  CheckinTable.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/2.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class CheckinTable: UIViewController {
    
    private var event: Event!
    private var sheetInfo: SignupSheet!
    private var banner: UIVisualEffectView!
    
    private var spinner: UIActivityIndicatorView!
    private var spinnerLabel: UILabel!
    private var emptyLabel: UILabel!
    
    private var checkinTitle: UILabel!
    private var checkinSubtitle: UILabel!
    private var checkinTable: UITableView!
    
    var sortedRegistrants = [UserBrief]()
    
    required init(event: Event, sheet: SignupSheet) {
        super.init(nibName: nil, bundle: nil)
        
        self.event = event
        self.sheetInfo = sheet
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = EventDraft.backgroundColor
        
        banner = {
            let v = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
            v.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(v)
            
            v.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            v.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            v.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            
            return v
        }()
        
        checkinTitle = {
            let label = UILabel()
            label.numberOfLines = 3
            label.lineBreakMode = .byWordWrapping
            label.text = "Online Check-in"
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 24, weight: .medium)
            label.textColor = .init(white: 0.1, alpha: 1)
            label.translatesAutoresizingMaskIntoConstraints = false
            banner.contentView.addSubview(label)

            label.leftAnchor.constraint(equalTo: banner.leftAnchor, constant: 30).isActive = true
            label.rightAnchor.constraint(equalTo: banner.rightAnchor, constant: -30).isActive = true
            label.topAnchor.constraint(equalTo: banner.topAnchor, constant: 20).isActive = true
            
            return label
        }()
        
        checkinSubtitle = {
            let label = UILabel()
            
            let word = sheetInfo.registrants.count == 1 ? "person" : "people"
            if sheetInfo.capacity == 0 {
                label.text = "\(sheetInfo.registrants.count) \(word) checked in."
            } else {
                label.text = "\(sheetInfo.registrants.count) / \(sheetInfo.capacity) \(word) checked in."
            }
            
            label.numberOfLines = 5
            label.lineBreakMode = .byWordWrapping
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 17)
            label.textColor = .darkGray
            label.translatesAutoresizingMaskIntoConstraints = false
            banner.contentView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: banner.leftAnchor, constant: 30).isActive = true
            label.rightAnchor.constraint(equalTo: banner.rightAnchor, constant: -30).isActive = true
            label.topAnchor.constraint(equalTo: checkinTitle.bottomAnchor, constant: 10).isActive = true
            label.bottomAnchor.constraint(equalTo: banner.bottomAnchor, constant: -20).isActive = true
            
            return label
        }()
        
        banner.layoutIfNeeded()

        checkinTable = {
            let tv = UITableView()
            tv.dataSource = self
            tv.contentInsetAdjustmentBehavior = .always
            tv.register(CheckinUserCell.classForCoder(), forCellReuseIdentifier: "user")
            tv.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(tv)
            
            tv.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            tv.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            tv.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            tv.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            return tv
        }()
        
        spinner = {
            let spinner = UIActivityIndicatorView(style: .whiteLarge)
            spinner.tintColor = .lightGray
            spinner.hidesWhenStopped = true
            spinner.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(spinner)
            
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20).isActive = true
            
            return spinner
        }()
        
        spinnerLabel = {
            let label = UILabel()
            label.isHidden = true
            label.text = "Fetching registrants..."
            label.font = .systemFont(ofSize: 17)
            label.textColor = .darkGray
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: spinner.centerXAnchor).isActive = true
            label.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 10).isActive = true
            
            return label
        }()
        
        emptyLabel = {
            let label = UILabel()
            label.isHidden = true
            label.text = "No one checked in yet. Be the first!"
            label.font = .systemFont(ofSize: 17)
            label.textColor = .darkGray
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
            label.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -30).isActive = true
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            
            return label
        }()
        
        fetchRegistrants()
    }
    
    private func fetchRegistrants() {
        spinner.startAnimating()
        spinnerLabel.isHidden = false
        
        // TODO
    }
    
    private func adjustTableInset() {
        banner.layoutIfNeeded()
        checkinTable.contentInset.top = banner.frame.height
        checkinTable.scrollIndicatorInsets.top = banner.frame.height
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in self.adjustTableInset()})
    }
    

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension CheckinTable: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedRegistrants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "user") as! CheckinUserCell
        
        cell.setup(brief: sortedRegistrants[indexPath.row])
        
        return cell
    }

}
