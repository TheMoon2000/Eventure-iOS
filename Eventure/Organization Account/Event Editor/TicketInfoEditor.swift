//
//  TicketInfoEditor.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/17.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class TicketInfoEditor: UITableViewController {
    
    private var admissionInfo: AdmissionType!
    private var parentVC: TicketTypes!
    private var contentCells = [UITableViewCell]()
        
    required init(parentVC: TicketTypes, admissionInfo: AdmissionType) {
        super.init(nibName: nil, bundle: nil)
        
        self.parentVC = parentVC
        self.admissionInfo = admissionInfo
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Edit"

        view.backgroundColor = EventDraft.backgroundColor
        tableView.separatorStyle = .none
        tableView.contentInset.top = 8
        tableView.contentInset.bottom = 8
        tableView.keyboardDismissMode = .interactive
        tableView.tableFooterView = UIView()
        
        navigationItem.rightBarButtonItem = .init(title: "Done", style: .done, target: self, action: #selector(done))
        
        let typeCell = DraftCapacityCell(title: "Ticket type:")
        typeCell.valueField.placeholder = "e.g. General Admission"
        typeCell.valueField.text = admissionInfo.typeName
        typeCell.valueField.textColor = MAIN_TINT
        typeCell.valueField.keyboardType = .default
        typeCell.valueField.autocapitalizationType = .words
        typeCell.valueField.returnKeyType = .next
        typeCell.changeHandler = { field in
            self.parentVC.draftPage.edited = true
            self.admissionInfo.typeName = field.text!
        }
        
        typeCell.returnHandler = { field in
            let priceCell = self.contentCells[1] as? DraftCapacityCell
            priceCell?.valueField.becomeFirstResponder()
        }
        
        contentCells.append(typeCell)
        
        let priceCell = DraftCapacityCell(title: "Price (in USD):")
        priceCell.valueField.placeholder = "0.00"
        priceCell.valueField.text = admissionInfo.price != nil ? admissionInfo.priceDescription : ""
        priceCell.valueField.keyboardType = .decimalPad
        priceCell.changeHandler = { field in
            self.parentVC.draftPage.edited = true
            self.admissionInfo.price = Double(field.text!)
        }
        priceCell.returnHandler = { field in
            if let double = Double(field.text!) {
                self.admissionInfo.price = double
            } else {
                self.admissionInfo.price = 0.0
            }
            field.text = self.admissionInfo.priceDescription
        }
        contentCells.append(priceCell)
        
        let quotaCell = DraftCapacityCell(title: "Quota (0 = no quota):")
        if let quota = admissionInfo.quota {
            quotaCell.valueField.text = String(quota)
        }
        quotaCell.valueField.placeholder = "0"
        quotaCell.changeHandler = { field in
            self.parentVC.draftPage.edited = true
            self.admissionInfo.quota = Int(field.text!)
        }
        
        contentCells.append(quotaCell)
        
        let notesCell = DraftLocationCell()
        notesCell.promptLabel.text = "Additional notes (optional):"
        notesCell.valueText.textColor = .darkGray
        notesCell.setPlaceholder(string: "Where should people buy tickets from you offline?")
        notesCell.valueText.insertText(admissionInfo.notes)
        notesCell.textChangeHandler = { tv in
            self.admissionInfo.notes = tv.text
            self.parentVC.draftPage.edited = true
            
            UIView.performWithoutAnimation {
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
        }
        contentCells.append(notesCell)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        parentVC.resortAndReload()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if admissionInfo.typeName.isEmpty {
            (contentCells[0] as? DraftCapacityCell)?.valueField.becomeFirstResponder()
        }
    }
    
    @objc private func done() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentCells.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return contentCells[indexPath.row]
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
