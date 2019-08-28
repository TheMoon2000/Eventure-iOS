//
//  GenericOneFieldPage.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/26.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class GenericOneFieldPage: UITableViewController {
    
    var fieldName = "[Replace Me]"
    var submitAction: ((UITextField, UIActivityIndicatorView) -> ())? {
        didSet {
            textCell.submitAction = self.submitAction
        }
    }
    
    var textCell: GenericTextCell!
    
    required init(fieldName: String, fieldDefault: String, type: String) {
        super.init(nibName: nil, bundle: nil)
        
        self.fieldName = fieldName
        tableView = UITableView(frame: .zero, style: .grouped)
        navigationItem.rightBarButtonItem = .init(title: "Done", style: .done, target: self, action: #selector(doneButtonPressed))
        
        textCell = GenericTextCell(title: fieldName, type: type)
        textCell.inputField.text = fieldDefault
        textCell.submitAction = submitAction
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fieldName
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return textCell
    }

    @objc private func doneButtonPressed() {
        textCell.submit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
