//
//  EventCodeView.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/12.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class EventCodeView: UIView {

    private(set) var titleLabel: UILabel!
    private(set) var subtitleLabel: UILabel!
    private(set) var qrCode: UIImageView!
    private(set) var orgLogo: UIImageView!
    private(set) var orgTitle: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
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
            iv.widthAnchor.constraint(equalToConstant: 220).isActive = true
            iv.topAnchor.constraint(greaterThanOrEqualTo: subtitleLabel.bottomAnchor, constant: 45).isActive = true
            iv.leftAnchor.constraint(equalTo: leftAnchor, constant: 90).isActive = true
            iv.rightAnchor.constraint(equalTo: rightAnchor, constant: -90).isActive = true
            
            return iv
        }()
        
        orgLogo = {
            let iv = UIImageView(image: #imageLiteral(resourceName: "group").withRenderingMode(.alwaysTemplate))
            iv.layer.cornerRadius = 4
            iv.tintColor = AppColors.mainDisabled
            iv.layer.masksToBounds = true
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            addSubview(iv)
            
            iv.widthAnchor.constraint(equalToConstant: 32).isActive = true
            iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
            iv.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: 30).isActive = true
            iv.topAnchor.constraint(equalTo: qrCode.bottomAnchor, constant: 40).isActive = true
            
            return iv
        }()
        
        orgTitle = {
            let label = UILabel()
            label.numberOfLines = 5
            label.font = .systemFont(ofSize: 17.5, weight: .medium)
            label.textColor = .init(white: 0.15, alpha: 1)
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: orgLogo.rightAnchor, constant: 12).isActive = true
            label.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -30).isActive = true
            label.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 21).isActive = true
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40).isActive = true
            label.centerYAnchor.constraint(equalTo: orgLogo.centerYAnchor).isActive = true
            
            return label
        }()
        
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
