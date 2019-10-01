//
//  TransferHistoryUser.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/29.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class TransferHistoryUser: UITableViewCell {
    
    private var profilePicture: UIImageView!
    private var ring: UIView!
    private var userName: UILabel!
    private var userEmail: UILabel!
    private var lockStatus: UIImageView!
    
    private var upperStem: UIView!
    private var lowerStem: UIView!
    
    var hasUserAbove = false {
        didSet {
            upperStem.isHidden = !hasUserAbove
        }
    }
    var hasUserBelow = false {
        didSet {
            lowerStem.isHidden = !hasUserBelow
            lockStatus.isHidden = hasUserBelow
            let alpha: CGFloat = hasUserBelow ? 0.3 : 1.0
            for v in [userName, userEmail, ring, profilePicture] {
                v?.alpha = alpha
            }
        }
    }
    
    var isLocked = true {
        didSet {
            if isLocked {
                lockStatus.image = #imageLiteral(resourceName: "locked").withRenderingMode(.alwaysTemplate)
            } else {
                lockStatus.image = #imageLiteral(resourceName: "unlocked").withRenderingMode(.alwaysTemplate)
            }
        }
    }
    
    var toggleTransferable: ((Bool) -> ())?
    
    private var lineColor = UIColor(white: 0.88, alpha: 1)

    required init(user: User) {
        super.init(style: .default, reuseIdentifier: nil)
        
        separatorInset.left = 75
        selectionStyle = .none
        
        profilePicture = {
            let iv = UIImageView(image: #imageLiteral(resourceName: "guest").withRenderingMode(.alwaysTemplate))
            if user.profilePicture != nil {
                iv.image = user.profilePicture
            } else {
                user.getProfilePicture { newUser in
                    iv.image = newUser.profilePicture
                }
            }
            iv.tintColor = MAIN_DISABLED
            iv.layer.cornerRadius = 5
            iv.layer.masksToBounds = true
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            addSubview(iv)
            
            iv.widthAnchor.constraint(equalToConstant: 28).isActive = true
            iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
            iv.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            return iv
        }()
        
        ring = {
            let view = UIView()
            view.layer.borderWidth = 2
            view.layer.cornerRadius = 25
            view.layer.borderColor = lineColor.cgColor
            view.translatesAutoresizingMaskIntoConstraints = false
            insertSubview(view, belowSubview: profilePicture)
            
            view.widthAnchor.constraint(equalToConstant: 50).isActive = true
            view.heightAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            view.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 15).isActive = true
            view.centerXAnchor.constraint(equalTo: profilePicture.centerXAnchor).isActive = true
            view.centerYAnchor.constraint(equalTo: profilePicture.centerYAnchor).isActive = true
            
            return view
        }()
        
        upperStem = {
            let view = UIView()
            view.isHidden = true
            view.alpha = 0.3
            view.backgroundColor = lineColor
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            
            view.widthAnchor.constraint(equalToConstant: 2).isActive = true
            view.topAnchor.constraint(equalTo: topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: ring.topAnchor).isActive = true
            view.centerXAnchor.constraint(equalTo: profilePicture.centerXAnchor).isActive = true
            
            return view
        }()
        
        lowerStem = {
            let view = UIView()
            view.isHidden = true
            view.alpha = 0.3
            view.backgroundColor = lineColor
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            
            view.widthAnchor.constraint(equalTo: upperStem.widthAnchor).isActive = true
            view.topAnchor.constraint(equalTo: ring.bottomAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            view.centerXAnchor.constraint(equalTo: upperStem.centerXAnchor).isActive = true
            
            return view
        }()
        
        lockStatus = {
            let iv = UIImageView(image: #imageLiteral(resourceName: "locked").withRenderingMode(.alwaysTemplate))
            iv.tintColor = .lightGray
            iv.contentMode = .scaleAspectFit
            iv.isUserInteractionEnabled = true
            iv.translatesAutoresizingMaskIntoConstraints = false
            addSubview(iv)
            
            iv.widthAnchor.constraint(equalToConstant: 28).isActive = true
            iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
            iv.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            iv.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -15).isActive = true
            
            iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleLock)))
            
            return iv
        }()
        
        userName = {
            let label = UILabel()
            label.text = user.username
            label.font = .systemFont(ofSize: 18, weight: .medium)
            label.textColor = .init(white: 0.1, alpha: 1)
            label.numberOfLines = 5
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: ring.rightAnchor, constant: 12).isActive = true
            if isLocked {
                label.rightAnchor.constraint(equalTo: lockStatus.leftAnchor, constant: -15).isActive = true
            } else {
                label.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
            }
            label.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
            
            return label
        }()
        
        userEmail = {
            let label = UILabel()
            label.text = user.email
            label.font = .systemFont(ofSize: 16)
            label.textColor = .gray
            label.numberOfLines = 2
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: userName.leftAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: userName.rightAnchor).isActive = true
            label.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 5).isActive = true
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
            
            return label
        }()
    }
    
    @objc private func toggleLock() {
        UISelectionFeedbackGenerator().selectionChanged()
        toggleTransferable?(isLocked)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
