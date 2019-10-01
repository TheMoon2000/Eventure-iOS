//
//  TicketImageBelowQR.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/30.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class TicketImageBelowQR: UIView {

    private(set) var titleLabel: UILabel!
    private(set) var subtitleLabel: UILabel!
    private(set) var qrCode: UIImageView!
    private(set) var orgLogo: UIImageView!
    private(set) var ticketType: UILabel!
    private(set) var customImage: UIImageView!
    private(set) var redeemCode: UILabel!
    
    required init(banner: UIImage) {
        super.init(frame: .zero)

        qrCode = {
            let iv = UIImageView()
            iv.translatesAutoresizingMaskIntoConstraints = false
            addSubview(iv)
            
            iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
            iv.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            iv.widthAnchor.constraint(equalToConstant: 230).isActive = true
            iv.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 40).isActive = true
            iv.leftAnchor.constraint(equalTo: leftAnchor, constant: 90).isActive = true
            iv.rightAnchor.constraint(equalTo: rightAnchor, constant: -90).isActive = true
            
            return iv
        }()
        
        orgLogo = {
            let iv = UIImageView()
            iv.backgroundColor = .white
            iv.layer.cornerRadius = 4
            iv.layer.borderColor = UIColor(white: 0.94, alpha: 1).cgColor
            iv.layer.borderWidth = 1
            iv.layer.masksToBounds = true
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            addSubview(iv)
            
            iv.widthAnchor.constraint(equalToConstant: 50).isActive = true
            iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
            iv.centerXAnchor.constraint(equalTo: qrCode.centerXAnchor).isActive = true
            iv.centerYAnchor.constraint(equalTo: qrCode.centerYAnchor).isActive = true
            
            return iv
        }()
        
        ticketType = {
            let label = UILabel()
            label.numberOfLines = 2
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 14)
            label.textColor = .gray
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.topAnchor.constraint(equalTo: qrCode.bottomAnchor, constant: 12).isActive = true
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -30).isActive = true
            
            return label
        }()
        
        customImage = {
            let iv = UIImageView(image: banner)
            
            iv.translatesAutoresizingMaskIntoConstraints = false
            addSubview(iv)
            
            iv.leftAnchor.constraint(equalTo: leftAnchor, constant: 40).isActive = true
            iv.rightAnchor.constraint(equalTo: rightAnchor, constant: -40).isActive = true
            iv.topAnchor.constraint(equalTo: qrCode.bottomAnchor, constant: 40).isActive = true
            
            let w = banner.size.width
            let h = banner.size.height

            iv.widthAnchor.constraint(equalTo: iv.heightAnchor, multiplier: w / h).isActive = true
            
            return iv
        }()
        
        redeemCode = {
            let label = UILabel()
            label.numberOfLines = 2
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 16, weight: .medium)
            label.textColor = .darkGray
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.topAnchor.constraint(equalTo: customImage.bottomAnchor, constant: 30).isActive = true
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -30).isActive = true
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -25).isActive = true
            
            return label
        }()
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


}
