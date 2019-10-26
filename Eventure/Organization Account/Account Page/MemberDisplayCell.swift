//
//  MemberDisplayCell.swift
//  Eventure
//
//  Created by Prince Wang on 2019/10/25.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//
import Foundation
import UIKit

class MemberDisplayCell: UITableViewCell {
    
    private var bgView: UIView!
    private(set) var profilePicture: UIImageView!
    private(set) var nameLabel: UILabel!
    private(set) var roleLabel: UILabel!
    private(set) var auxiliaryLabel: UILabel!
    private var member: Membership!
    private(set) var placeLabel: UILabel!

    init() {
        super.init(style: .default, reuseIdentifier: nil)

        backgroundColor = .clear
        selectionStyle = .none

        bgView = {
            let view = UIView()
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
            bgView.addSubview(iv)

            iv.widthAnchor.constraint(equalToConstant: 25).isActive = true
            iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
            iv.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 15).isActive = true
            iv.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

            return iv
        }()

        nameLabel = {
            let label = UILabel()
            label.numberOfLines = 2
            label.font = .systemFont(ofSize: 17, weight: .medium)
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)

            label.leftAnchor.constraint(equalTo: profilePicture.rightAnchor, constant: 12).isActive = true
            label.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -40).isActive = true
            label.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 10).isActive = true

            return label
        }()

        roleLabel = {
            let label = UILabel()
            label.numberOfLines = 3
            label.font = .systemFont(ofSize: 16)
            label.textColor = AppColors.prompt
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)

            label.leftAnchor.constraint(equalTo: nameLabel.leftAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: nameLabel.rightAnchor).isActive = true
            label.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5).isActive = true
            label.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -10).isActive = true

            return label
        }()

        auxiliaryLabel = {
            let label = UILabel()
            label.textAlignment = .right
            label.font = .systemFont(ofSize: 16)
            label.textColor = .gray
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)

            label.topAnchor.constraint(equalTo: roleLabel.topAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -15).isActive = true

            return label
        }()

        placeLabel = {
            let label = UILabel()
            label.textColor = .lightGray
            label.font = .systemFont(ofSize: 16)
            label.textAlignment = .right
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)

            label.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -18).isActive = true
            label.centerYAnchor.constraint(equalTo: bgView.centerYAnchor).isActive = true

            return label
        }()
    }


    func setup(member: Membership) {
        self.member = member
        nameLabel.text = member.name
        if nameLabel.text!.isEmpty { nameLabel.text = "No Name" }
        
        var role:String = member.role
        
        if role == "" {
            role = "No Specified Role"
        }
        
        
        if member.status == .pending {
            role = "Invitation Pending"
            bgView.subviews.forEach { $0.alpha = 0.3 }
        } else if member.status == .declined {
            role = "Invitation Declined"
            bgView.subviews.forEach { $0.alpha = 0.3 }
        }
        
        roleLabel.text = role
        bgView.backgroundColor = AppColors.subview
        
        if let pic = member.profilePicture {
            profilePicture.image = pic
        } else {
            member.getProfilePicture { img in
                self.profilePicture.image = img
            }
        }
        
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        if member.status == .active {
            bgView.backgroundColor = highlighted ? AppColors.selected : AppColors.subview
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}

