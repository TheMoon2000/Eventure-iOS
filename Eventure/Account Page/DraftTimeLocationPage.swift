//
//  DraftTimeLocationPage.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/23.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class DraftTimeLocationPage: UITableViewController {

    var draftPage: EventDraft!
    var contentCells = [UITableViewCell]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .init(white: 0.95, alpha: 1)
        tableView.tableFooterView = UIView()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        draftPage.currentPage = 1
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentCells.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

}
