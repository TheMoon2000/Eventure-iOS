//
//  OrgScanner.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/20.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class OrgScanner: ScannerViewController {
    
    var event: Event?
    
    override var INVALID_CODE: String {
        return "Oops, this doesn't look like an event ticket."
    }

    override func decryptDataString(_ string: String) -> String? {
        if string.contains("ticket?") {
            return "ticket: " + string.components(separatedBy: "=").last!
        }
        return nil
    }
    
    override func processDecryptedCode(string: String) {
        super.processDecryptedCode(string: string)
        
        // Handling for ticket IDs
        if string.hasPrefix("ticket: ") {
            let ticketID = String(string.suffix(36))
            let at = ActivateTicket(ticketID: ticketID, event: event)
            present(at, animated: true) {
                self.resetDisplay()
            }
        }
    }
    
}

extension OrgScanner {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        if let message = detectQRCode(image), let ticketID = decryptDataString(message) {
            picker.dismiss(animated: true)
            processDecryptedCode(string: ticketID)
        } else {
            let alert = UIAlertController(title: "This is not an Eventure entrance code!", message: "Please try a different image.", preferredStyle: .alert)
            alert.addAction(.init(title: "OK", style: .cancel))
            picker.present(alert, animated: true, completion: nil)
        }
    }
}

