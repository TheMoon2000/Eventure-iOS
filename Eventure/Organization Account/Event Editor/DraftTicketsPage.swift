//
//  DraftTicketsPage.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/17.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import TOCropViewController

class DraftTicketsPage: UITableViewController {
    
    var draftPage: EventDraft!
    
    private var optionsExpanded = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        draftPage.currentPage = 2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = AppColors.canvas
        tableView.tintColor = AppColors.main
        tableView.contentInset.top = 6
        tableView.contentInset.bottom = 6

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 1 || indexPath.row == 2) && !draftPage.draft.requiresTicket {
            return 0
        }
        
        if indexPath.row == 3 || indexPath.row == 4 {
            return optionsExpanded ? UITableView.automaticDimension : 0
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = SettingsSwitchCell()
            cell.titleLabel.text = "Enable ticketing"
            cell.enabled = draftPage.draft.requiresTicket
            cell.switchHandler = { on in
                self.draftPage.draft.requiresTicket = on
                self.draftPage.edited = true
                
                for i in [1, 2] {
                    if let bottom = tableView.cellForRow(at: [0, i]) as? DatePickerTopCell {
                        UIView.transition(with: bottom, duration: 0.2, options: .curveEaseInOut, animations: {
                            for item in [bottom.leftLabel, bottom.rightLabel, bottom.indicator] {
                                item?.alpha = on ? 1.0 : 0.0
                            }
                        })
                    }
                }
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
            return cell
        case 1:
            let cell = DatePickerTopCell(title: "Manage tickets...")
            let typesCount = draftPage.draft.admissionTypes.count
            let typesNoun = typesCount == 1 ? "type" : "types"
            cell.rightLabel.text = typesCount == 0 ? "Not set" : "\(typesCount) \(typesNoun) defined"
            if !draftPage.draft.requiresTicket {
                [cell.leftLabel, cell.rightLabel, cell.indicator].forEach { $0?.alpha = 0.0 }
            }
            
            return cell
        case 2:
            let cell = DatePickerTopCell(title: "Ticket QR code layout")
            cell.rightLabel.text = ["Standard", "Image below"][draftPage.draft.ticketStyle.rawValue]
            if !draftPage.draft.requiresTicket {
                [cell.leftLabel, cell.rightLabel, cell.indicator].forEach { $0?.alpha = 0.0 }
            }
            
            return cell
        case 3:
            let cell = TicketStyleTypeCell(position: .top)
            cell.layoutType = .standard
            cell.checked = draftPage.draft.ticketStyle == .standard
            cell.visible = optionsExpanded
            return cell
        case 4:
            let cell = TicketStyleTypeCell(position: .bottom)
            cell.layoutType = .imageBelow
            cell.checked = draftPage.draft.ticketStyle == .imageBelow
            cell.visible = optionsExpanded
            
            return cell
        default:
            return UITableViewCell()
        }

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath)!
        
        switch indexPath.row {
        case 0:
            let alert = UIAlertController(title: "Ticketing", message: "You should turn on this feature if your event requires entrance tickets.", preferredStyle: .alert)
            alert.addAction(.init(title: "Close", style: .cancel))
            present(alert, animated: true, completion: nil)
        case 1:
            let vc = TicketTypes(draftPage: draftPage)
            self.navigationController?.pushViewController(vc, animated: true)
        case 2:
            optionsExpanded.toggle()
            
            let topCell = cell as! DatePickerTopCell
            optionsExpanded ? topCell.expand() : topCell.collapse()
            
            UIView.animate(withDuration: 0.2) {
                for row in 3...4 {
                    if let s = tableView.cellForRow(at: [0, row]) as? TicketStyleTypeCell {
                        s.visible = self.optionsExpanded
                    }
                }
            }
            
            tableView.beginUpdates()
            tableView.endUpdates()
        case 3:
            UISelectionFeedbackGenerator().selectionChanged()
            draftPage.draft.ticketStyle = .standard
            draftPage.edited = true
            
            let standardCell = cell as! TicketStyleTypeCell
            standardCell.checked = true
            
            if let below = tableView.cellForRow(at: [0, 4]) as? TicketStyleTypeCell {
                below.checked = false
            }
            
            if let header = tableView.cellForRow(at: [0, 2]) as? DatePickerTopCell {
                header.rightLabel.text = "Standard"
            }
        case 4:
            UISelectionFeedbackGenerator().selectionChanged()
            draftPage.draft.ticketStyle = .imageBelow
            draftPage.edited = true
            
            let belowCell = cell as! TicketStyleTypeCell
            let alreadySelected = belowCell.checked
            
            belowCell.checked = true
            
            if let top = tableView.cellForRow(at: [0, 3]) as? TicketStyleTypeCell {
                top.checked = false
            }
            
            if let header = tableView.cellForRow(at: [0, 2]) as? DatePickerTopCell {
                header.rightLabel.text = "Image below"
            }
            
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            if !draftPage.draft.hasBannerImage {
                alert.title = "Specify an image?"
                alert.message = "You have not yet chosen a custom image to be placed below your tickets' QR codes. Press continue to do so. Alternatively, you could come back later, but bear in mind that you cannot generate custom ticket QR codes for your event until this image is provided."
                alert.addAction(.init(title: "Pick Later", style: .cancel))
                alert.addAction(.init(title: "Pick Now", style: .default, handler: { _ in
                    let picker = UIImagePickerController()
                    picker.delegate = self
                    picker.sourceType = .photoLibrary
                    self.present(picker, animated: true)
                }))
                self.present(alert, animated: true)
            } else if alreadySelected {
                alert.title = "Update custom image?"
                alert.message = "You already have an image that can be used to generate QR codes."
                alert.addAction(.init(title: "Cancel", style: .cancel))
                alert.addAction(.init(title: "Update Image", style: .default, handler: { _ in
                    let picker = UIImagePickerController()
                    picker.delegate = self
                    picker.sourceType = .photoLibrary
                    self.present(picker, animated: true)
                }))
                self.present(alert, animated: true)
            }
        default:
            break
        }
    }
    

}


extension DraftTicketsPage: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let original = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        let cropper = TOCropViewController(image: original)
        cropper.rotateButtonsHidden = true
        cropper.delegate = self
        picker.present(cropper, animated: true)
    }
}

extension DraftTicketsPage: TOCropViewControllerDelegate {
    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        
        draftPage.bannerEdited = true
        draftPage.draft.hasBannerImage = true
        draftPage.draft.bannerImage = image.sizeDown(maxWidth: 800)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        self.dismiss(animated: true, completion: nil)
    }
}

