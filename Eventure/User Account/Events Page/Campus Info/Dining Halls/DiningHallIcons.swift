//
//  DiningHallIcons.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/4/1.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import UIKit

class DiningHallIcons: UIViewController {
    
    private var iconTable: UITableView!
    let staticContent: [(icon: UIImage, name: String)] = [
        (#imageLiteral(resourceName: "Milk"), "Milk"),
        (#imageLiteral(resourceName: "Egg"), "Egg"),
        (#imageLiteral(resourceName: "Shellfish"), "Shellfish"),
        (#imageLiteral(resourceName: "Fish"), "Fish"),
        (#imageLiteral(resourceName: "Tree Nuts"), "Tree Nuts"),
        (#imageLiteral(resourceName: "Wheat"), "Wheat"),
        (#imageLiteral(resourceName: "Peanuts"), "Peanuts"),
        (#imageLiteral(resourceName: "Sesame"), "Sesame"),
        (#imageLiteral(resourceName: "Soybeans"), "Soybeans"),
        (#imageLiteral(resourceName: "Vegan Option").withRenderingMode(.alwaysTemplate), "Vegan Option"),
        (#imageLiteral(resourceName: "Vegetarian Option").withRenderingMode(.alwaysTemplate), "Vegetarian Option"),
        (#imageLiteral(resourceName: "Contains Gluten").withRenderingMode(.alwaysTemplate), "Contains Gluten"),
        (#imageLiteral(resourceName: "Contains Pork").withRenderingMode(.alwaysTemplate), "Contains Pork"),
        (#imageLiteral(resourceName: "Contains Alcohol").withRenderingMode(.alwaysTemplate), "Contains Alcohol"),
        (#imageLiteral(resourceName: "Halal").withRenderingMode(.alwaysTemplate), "Halal"),
        (#imageLiteral(resourceName: "Kosher").withRenderingMode(.alwaysTemplate), "Kosher")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "Dining Hall Icon Definitions"
        view.backgroundColor = AppColors.tableBG
        
        navigationItem.rightBarButtonItem = .init(image: #imageLiteral(resourceName: "cross"), style: .plain, target: self, action: #selector(close))
        
        iconTable = {
            let tv = UITableView()
            tv.backgroundColor = AppColors.tableBG
            tv.allowsSelection = false
            tv.dataSource = self
            tv.separatorStyle = .none
            tv.contentInset.top = 20
            tv.contentInset.bottom = 20
            tv.tableFooterView = UIView()
            tv.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(tv)
            
            tv.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            tv.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            tv.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            tv.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            return tv
        }()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        iconTable.contentOffset.y = -30
    }
    
    @objc private func close() {
        self.dismiss(animated: true)
    }
}

extension DiningHallIcons: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return staticContent.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = DiningIconDefinitionCell()
        cell.icon.image = staticContent[indexPath.row].icon
        cell.title.text = staticContent[indexPath.row].name
        
        return cell
    }
    
}
