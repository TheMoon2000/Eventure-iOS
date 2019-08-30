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
    private var titleLabel: UILabel!
    private var subtitleLabel: UILabel!
    private var qrCode: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationController?.navigationBar.shadowImage = UIImage()
        
        let encrypted = NSString(string: event.uuid).aes256Encrypt(withKey: AES_KEY)
        let code = URL_PREFIX + encrypted!

        titleLabel = {
            let label = UILabel()
            label.text = "Event Check-in Code"
            label.textAlignment = .center
            label.textColor = .init(white: 0.1, alpha: 1)
            label.font = .systemFont(ofSize: 25, weight: .semibold)
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
            
            return label
        }()
        
        subtitleLabel = {
            let label = UILabel()
            label.numberOfLines = 5
            label.lineBreakMode = .byWordWrapping
            label.text = "Present this QR code at check-in to collect information about who's attending your event."
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 17)
            label.textColor = .init(white: 0.1, alpha: 1)
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15).isActive = true
            label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
            label.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -30).isActive = true
            
            return label
        }()

        qrCode = {
            let iv = UIImageView(image: generateQRCode(from: code))
            iv.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(iv)
            
            iv.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 40).isActive = true
            iv.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -40).isActive = true
            iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
            
            let center = iv.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 20)
            center.priority = .defaultHigh
            center.isActive = true
            
            iv.topAnchor.constraint(greaterThanOrEqualTo: subtitleLabel.bottomAnchor, constant: 50).isActive = true
            
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
