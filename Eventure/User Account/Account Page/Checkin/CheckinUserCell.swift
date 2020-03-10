//
//  CheckinUserCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/2.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class CheckinUserCell: UITableViewCell {
    
    private var bgView: UIView!
    private(set) var profilePicture: UIImageView!
    private(set) var nameLabel: UILabel!
    private(set) var majorLabel: UILabel!
    private(set) var auxiliaryLabel: UILabel!
    private var registrant: Registrant?
    private(set) var placeLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        
        bgView = {
            let view = UIView()
            view.layer.cornerRadius = 8
            view.applyMildShadow()
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            
            view.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
            view.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
            view.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 6).isActive = true
            
            let bottomConstraint = view.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -6)
            bottomConstraint.priority = .defaultHigh
            bottomConstraint.isActive = true
            
            return view
        }()
        
        profilePicture = {
            let iv = UIImageView(image: #imageLiteral(resourceName: "guest").withRenderingMode(.alwaysTemplate))
            iv.tintColor = AppColors.mainDisabled
            iv.layer.cornerRadius = 2
            iv.layer.masksToBounds = true
            iv.translatesAutoresizingMaskIntoConstraints = false
            addSubview(iv)
            
            iv.widthAnchor.constraint(equalToConstant: 25).isActive = true
            iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
            iv.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 15).isActive = true
            iv.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            return iv
        }()
        
        nameLabel = {
            let label = UILabel()
            label.numberOfLines = 2
            label.lineBreakMode = .byWordWrapping
            label.font = .appFontMedium(17)
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: profilePicture.rightAnchor, constant: 12).isActive = true
            label.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -40).isActive = true
            label.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 10).isActive = true
            
            return label
        }()
        
        majorLabel = {
            let label = UILabel()
            label.numberOfLines = 3
            label.font = .appFontRegular(16)
            label.textColor = AppColors.prompt
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: nameLabel.leftAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: nameLabel.rightAnchor).isActive = true
            label.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5).isActive = true
            label.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -10).isActive = true
            
            return label
        }()
        
        auxiliaryLabel = {
            let label = UILabel()
            label.textAlignment = .right
            label.font = .appFontRegular(16)
            label.textColor = .gray
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.topAnchor.constraint(equalTo: majorLabel.topAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -15).isActive = true
            
            return label
        }()
        
        placeLabel = {
            let label = UILabel()
            label.textColor = .lightGray
            label.font = .appFontRegular(16)
            label.textAlignment = .right
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -18).isActive = true
            label.centerYAnchor.constraint(equalTo: bgView.centerYAnchor).isActive = true
            
            return label
        }()
    }
    
    
    func setup(registrant: Registrant) {
        self.registrant = registrant
        nameLabel.text = registrant.name
        if nameLabel.text!.isEmpty { nameLabel.text = registrant.displayedName }
        if nameLabel.text!.isEmpty { nameLabel.text = "Incognito" }
        if let order = registrant.order {
            self.placeLabel.text = String(order)
        } else {
            self.placeLabel.text = "?"
        }
        if let code = registrant.currentCode {
            majorLabel.text = "Check-in code: \(code)"
            bgView.backgroundColor = AppColors.pending
        } else if registrant.userID != -1 {
            majorLabel.text = registrant.majorDescription
            bgView.backgroundColor = AppColors.background
        } else {
            majorLabel.text = registrant.email
            bgView.backgroundColor = AppColors.background
        }
        majorLabel.attributedText = majorLabel.text?.attributedText(style: COMPACT_STYLE)
        majorLabel.textColor = AppColors.prompt
        if registrant.profilePicture != nil {
            profilePicture.image = registrant.profilePicture
        } else {
            profilePicture.image = #imageLiteral(resourceName: "guest").withRenderingMode(.alwaysTemplate)
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if registrant?.currentCode != nil {
            bgView.backgroundColor = AppColors.pending
        } else {
            bgView.backgroundColor = highlighted ? AppColors.selected : AppColors.subview
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
