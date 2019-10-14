//
//  TicketCodeView.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/30.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class TicketCodeView: UIView {

    private(set) var titleLabel: UILabel!
    private(set) var subtitleLabel: UILabel!
    private(set) var qrCode: UIImageView!
    private(set) var orgLogo: UIImageView!
    private(set) var ticketType: UILabel!
    private(set) var redeemCode: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        backgroundColor = AppColors.navbar
        
        titleLabel = {
            let label = UILabel()
            label.numberOfLines = 0
            label.textAlignment = .center
            label.textColor = AppColors.label
            label.font = .systemFont(ofSize: 24, weight: .semibold)
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 35).isActive = true
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -35).isActive = true
            label.topAnchor.constraint(equalTo: topAnchor, constant: 50).isActive = true
            
            return label
        }()
        
        subtitleLabel = {
            let label = UILabel()
            label.numberOfLines = 5
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 16)
            label.textColor = .gray
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -30).isActive = true
            
            return label
        }()
        
        qrCode = {
            let iv = UIImageView()
            iv.translatesAutoresizingMaskIntoConstraints = false
            addSubview(iv)
            
            iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
            iv.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            iv.widthAnchor.constraint(equalToConstant: 230).isActive = true
            iv.topAnchor.constraint(greaterThanOrEqualTo: subtitleLabel.bottomAnchor, constant: 40).isActive = true
            iv.leftAnchor.constraint(equalTo: leftAnchor, constant: 90).isActive = true
            iv.rightAnchor.constraint(equalTo: rightAnchor, constant: -90).isActive = true
            
            return iv
        }()
        
        orgLogo = {
            let iv = UIImageView()
            iv.backgroundColor = AppColors.navbar
            iv.layer.cornerRadius = 4
            iv.layer.borderColor = AppColors.canvas.cgColor
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
        
        redeemCode = {
            let label = UILabel()
            label.numberOfLines = 2
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 16, weight: .medium)
            label.textColor = AppColors.prompt
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.topAnchor.constraint(equalTo: ticketType.bottomAnchor, constant: 30).isActive = true
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
