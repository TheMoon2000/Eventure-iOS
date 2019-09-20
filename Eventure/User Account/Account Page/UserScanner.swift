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

    override func decryptDataString(_ string: String) -> String? {
        let components = string.components(separatedBy: "?id=")
        guard components.count >= 2 else {
            return decryptLegacyQR(string)
        }
        return components[1]
    }
    
    private func decryptLegacyQR(_ string: String) -> String? {
        guard string.hasPrefix(URL_PREFIX) else { return nil }
        
        let encrypted = string[string.index(string.startIndex, offsetBy: URL_PREFIX.count)...]
        
        if let decrypted = NSString(string: String(encrypted)).aes256Decrypt(withKey: AES_KEY) {
            
            return decrypted
        }
        
        return nil
    }
    
    override func processDecryptedCode(string: String) {
        super.processDecryptedCode(string: string)
        
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
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                if self.cameraPrompt.textColor == LIGHT_RED {
                    self.cameraPrompt.text = self.cameraDefaultText
                    self.cameraPrompt.textColor = .white
                }
            }
        }
        
        task.resume()
    }
    
}


extension UserScanner {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        if let message = detectQRCode(image), let eventUUID = decryptDataString(message) {
            picker.dismiss(animated: true)
            processDecryptedCode(string: eventUUID)
        } else {
            let alert = UIAlertController(title: "This is not an Eventure event code!", message: "Please try a different image.", preferredStyle: .alert)
            alert.addAction(.init(title: "OK", style: .cancel))
            picker.present(alert, animated: true, completion: nil)
        }
    }
}
