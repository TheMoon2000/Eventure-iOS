//
//  DiscoverBannerCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/4/8.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import UIKit

class DiscoverBannerCell: UICollectionViewCell {
    
    private(set) var bannerImage: UIImageView!
    private(set) var errorIcon: UIImageView!
    private(set) var spinner: UIActivityIndicatorView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        bannerImage = {
            let iv = UIImageView()
            iv.backgroundColor = AppColors.disabled.withAlphaComponent(0.5)
            iv.contentMode = .scaleAspectFill
            iv.layer.cornerRadius = 8
            iv.clipsToBounds = true
            iv.translatesAutoresizingMaskIntoConstraints = false
            addSubview(iv)
            
            iv.widthAnchor.constraint(equalTo: iv.heightAnchor, multiplier: 2).isActive = true
            iv.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            iv.topAnchor.constraint(greaterThanOrEqualTo: topAnchor).isActive = true
            iv.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor).isActive = true
            
            let l = iv.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 20)
            l.priority = .defaultHigh
            l.isActive = true
            
            let r = iv.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -20)
            r.priority = .defaultHigh
            r.isActive = true
            
            iv.leftAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.leftAnchor, constant: 25).isActive = true
            iv.rightAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.rightAnchor, constant: -25).isActive = true
            iv.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true

            iv.widthAnchor.constraint(lessThanOrEqualToConstant: 400).isActive = true
            
            return iv
        }()
        
        spinner = {
            let spinner = UIActivityIndicatorView()
            spinner.color = AppColors.lightControl
            spinner.translatesAutoresizingMaskIntoConstraints = false
            addSubview(spinner)
            
            spinner.centerXAnchor.constraint(equalTo: bannerImage.centerXAnchor).isActive = true
            spinner.centerYAnchor.constraint(equalTo: bannerImage.centerYAnchor).isActive = true
            
            return spinner
        }()
        
        errorIcon = {
            let icon = UIImageView(image: #imageLiteral(resourceName: "error"))
            icon.isHidden = true
            icon.contentMode = .scaleAspectFit
            icon.translatesAutoresizingMaskIntoConstraints = false
            addSubview(icon)
            
            icon.centerXAnchor.constraint(equalTo: bannerImage.centerXAnchor).isActive = true
            icon.centerYAnchor.constraint(equalTo: bannerImage.centerYAnchor).isActive = true
            icon.widthAnchor.constraint(equalToConstant: 36).isActive = true
            icon.heightAnchor.constraint(equalToConstant: 36).isActive = true
            
            return icon
        }()
    }
    
    func reset() {
        bannerImage.image = nil
        errorIcon.isHidden = true
        spinner.stopAnimating()
        bannerImage.backgroundColor = AppColors.disabled.withAlphaComponent(0.5)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
