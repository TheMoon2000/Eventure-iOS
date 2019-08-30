//
//  EventCheckinOverview.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/29.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class EventCheckinOverview: UIViewController {
    
    var event: Event!
    var qrCode: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let encrypted = NSString(string: event.uuid).aes256Encrypt(withKey: AES_KEY)
        let code = URL_PREFIX + encrypted!


        qrCode = {
            let iv = UIImageView(image: generateQRCode(from: code))
            iv.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(iv)
            
            iv.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
            iv.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -30).isActive = true
            iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
            
            return iv
        }()
    }
    
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

}
