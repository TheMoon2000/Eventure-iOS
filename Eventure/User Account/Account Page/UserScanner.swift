//
//  UserScanner.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/20.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class UserScanner: ScannerViewController {
    
    var accountVC: AccountViewController?

    override func decryptDataString(_ string: String) -> String? {
        if string.contains("checkin?") {
            return string.components(separatedBy: "=").last
        } else if string.contains("ticket?") {
            return "ticket: " + string.components(separatedBy: "=").last!
        }
        return nil
    }
    
    override func processDecryptedCode(string: String) {
        super.processDecryptedCode(string: string)
        
        print("processing \(string)")
        
        // Handling for ticket IDs
        if string.hasPrefix("ticket: ") {
            let ticketID = String(string.suffix(36))
            processTicketID(id: ticketID)
            return
        }
        
        // Handling for event IDs
        let eventID = string
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/GetEvent",
                           parameters: ["uuid": eventID])!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
            }
            
            guard error == nil else {
                DispatchQueue.main.async {
                    self.cameraPrompt.text = "No internet connection."
                    self.cameraPrompt.textColor = WARNING_COLOR
                    self.session.startRunning()
                }
                return
            }
            
            if let json = try? JSON(data: data!) {
                let event = Event(eventInfo: json)
                event.getCover(nil)
                let checkinForm = CheckinPageController(event: event)
                DispatchQueue.main.async {
                    self.present(CheckinNavigationController(rootViewController: checkinForm), animated: true) {
                        self.navigationController?.popViewController(animated: false)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.cameraPrompt.text = "The event you scanned does not exist or has been deleted by its host organization."
                    self.cameraPrompt.textColor = LIGHT_RED
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
                if self?.cameraPrompt.textColor == LIGHT_RED {
                    self?.cameraPrompt.text = self?.cameraDefaultText
                    self?.cameraPrompt.textColor = .white
                }
            }
        }
        
        task.resume()
    }
    
    func processTicketID(id: String) {
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/LookupTicket",
                           parameters: ["ticketId": id])!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.spinner.stopAnimating()
            }
            
            guard error == nil else {
                DispatchQueue.main.async {
                    self.cameraPrompt.text = "No internet connection."
                    self.cameraPrompt.textColor = WARNING_COLOR
                    self.session.startRunning()
                }
                return
            }
                        
            if let json = try? JSON(data: data!), json.dictionary != nil {
                let ticket = Ticket(ticketInfo: json)
                
                if !ticket.transferable || (ticket.transferLocked && ticket.userID != -1) {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Could not initiate ticket transfer", message: "The ticket you just scanned does not support transfer.", preferredStyle: .alert)
                        alert.addAction(.init(title: "OK", style: .cancel, handler: { _ in
                            self.session.startRunning()
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                    return
                }
                
                let scannedPage = TicketScannedPage(ticket: ticket, parentVC: self)
                let nav = PortraitNavigationController(rootViewController: scannedPage)

                DispatchQueue.main.async {
                    self.present(nav, animated: true) {
                        self.navigationController?.popViewController(animated: false)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.cameraPrompt.text = "There was an error loading the information for this ticket. Perhaps the event organizer invalidated it?"
                    self.cameraPrompt.textColor = LIGHT_RED
                    self.session.startRunning()
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
                if self?.cameraPrompt.textColor == LIGHT_RED {
                    self?.cameraPrompt.text = self?.cameraDefaultText
                    self?.cameraPrompt.textColor = .white
                }
            }
        }
        task.resume()
    }
    
}


extension UserScanner {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        if let message = detectQRCode(image), let uuid = decryptDataString(message) {
            picker.dismiss(animated: true)
            processDecryptedCode(string: uuid)
        } else {
            let alert = UIAlertController(title: "This is not an Eventure code!", message: "Please try a different image.", preferredStyle: .alert)
            alert.addAction(.init(title: "OK", style: .cancel))
            picker.present(alert, animated: true, completion: nil)
        }
    }
}
