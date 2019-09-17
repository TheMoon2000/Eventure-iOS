//
//  DraftTicketsPage.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/17.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class DraftTicketsPage: UITableViewController {
    
    var draftPage: EventDraft!
    
    private var contentCells = [UITableViewCell]()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        draftPage.currentPage = 2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = EventDraft.backgroundColor
        tableView.tintColor = MAIN_TINT
        tableView.contentInset.top = 8
        tableView.contentInset.bottom = 8

    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 && !draftPage.draft.requiresTicket {
            return 0
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = SettingsSwitchCell()
            cell.backgroundColor = EventDraft.backgroundColor
            cell.titleLabel.text = "Enable ticketing"
            cell.enabled = false
            cell.switchHandler = { on in
                self.draftPage.draft.requiresTicket = on
                
                if let bottom = tableView.cellForRow(at: [0, 1]) as? DatePickerTopCell {
                    UIView.animate(withDuration: 0.2) {
                        for item in [bottom.leftLabel, bottom.rightLabel, bottom.indicator] {
                            item?.alpha = on ? 1.0 : 0.0
                        }
                    }
                }
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
            return cell
        } else if indexPath.row == 1 {
            let cell = DatePickerTopCell(title: "Manage ticket...")
            let typesCount = draftPage.draft.admissionTypes.count
            cell.rightLabel.text = typesCount == 0 ? "Not set" : "\(typesCount) \(typesCount) defined"
            if !draftPage.draft.requiresTicket {
                [cell.leftLabel, cell.rightLabel, cell.indicator].forEach { $0?.alpha = 0.0 }
            }
            
            return cell
        }

        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            let alert = UIAlertController(title: "Ticketing", message: "You should turn on this feature if your event requires entrance tickets.", preferredStyle: .alert)
            alert.addAction(.init(title: "Close", style: .cancel))
            present(alert, animated: true, completion: nil)
        } else if indexPath.row == 1 {
            let vc = TicketTypesEditor(event: draftPage.draft)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    

}
