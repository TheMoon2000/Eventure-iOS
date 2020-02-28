//
//  ChooseTagCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/4.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class ChooseTagCell: UITableViewCell {

    private(set) var parentVC: UIViewController!
    var maxPicks: Int? = 3
    
    var status: Status = .none {
        didSet {
            switch status {
            case .none:
                statusIcon.image = #imageLiteral(resourceName: "disclosure_indicator").withRenderingMode(.alwaysTemplate)
                rightLabel.text = "Choose"

            case .done:
                statusIcon.image = #imageLiteral(resourceName: "check")
                rightLabel.text = ""
            case .fail:
                statusIcon.image = #imageLiteral(resourceName: "cross")
                rightLabel.text = "Choose"
            }
        }
    }
    
    private var loginStyle = false
    
    private(set) var overlay: UIView!
    private var leftLabel: UILabel!
    private(set) var rightLabel: UILabel!
    private var statusIcon: UIImageView!
    private var disclosure: UIImageView!

    required init(parentVC: UIViewController, sideInset: CGFloat = 30, loginStyle: Bool = false) {
        super.init(style: .default, reuseIdentifier: nil)
        
        self.parentVC = parentVC
        
        backgroundColor = .clear
        selectionStyle = .none
        let h = heightAnchor.constraint(equalToConstant: 70)
        h.priority = .defaultHigh
        h.isActive = true
        
        overlay = {
            let overlay = UIView()
            overlay.layer.cornerRadius = 7
            overlay.layer.borderColor = AppColors.line.cgColor
            overlay.backgroundColor = AppColors.subview
            if !loginStyle {
                overlay.applyMildShadow()
            }
            overlay.translatesAutoresizingMaskIntoConstraints = false
            addSubview(overlay)
            
            overlay.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: sideInset).isActive = true
            overlay.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -sideInset).isActive = true
            overlay.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
            overlay.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
            
            return overlay
        }()
        
        leftLabel = {
            let label = UILabel()
            label.text = "Pick Tags..."
            label.textColor = AppColors.label
            label.font = .appFontMedium(18)
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: overlay.leftAnchor, constant: 15).isActive = true
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            return label
        }()
        
        statusIcon = {
            let icon = UIImageView(image: #imageLiteral(resourceName: "disclosure_indicator").withRenderingMode(.alwaysTemplate))
            icon.contentMode = .scaleAspectFit
            icon.tintColor = AppColors.prompt
            icon.translatesAutoresizingMaskIntoConstraints = false
            addSubview(icon)
            
            icon.widthAnchor.constraint(equalToConstant: 22).isActive = true
            icon.heightAnchor.constraint(equalToConstant: 22).isActive = true
            icon.rightAnchor.constraint(equalTo: overlay.rightAnchor, constant: -10).isActive = true
            icon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            return icon
        }()
        
        rightLabel = {
            let label = UILabel()
            label.textColor = .lightGray
            label.text = "Choose"
            label.font = .appFontSemibold(17)
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.rightAnchor.constraint(equalTo: statusIcon.leftAnchor, constant: -8).isActive = true
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            return label
        }()
        
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if loginStyle {
            if highlighted {
                overlay.layer.borderWidth = 1
                leftLabel.textColor = AppColors.label
            } else {
                overlay.layer.borderWidth = 0
                leftLabel.textColor = AppColors.value
            }
        } else {
            if highlighted {
                overlay.backgroundColor = AppColors.selected
            } else {
                overlay.backgroundColor = AppColors.subview
            }
        }
    }
    
    func reloadTagPrompt(tags: Set<Int>) {
        if tags.count >= 1 && (maxPicks == nil || tags.count <= maxPicks!) {
            status = .done
            let tagword = tags.count == 1 ? "tag" : "tags"
            rightLabel.text = "\(tags.count) \(tagword) selected"
        } else if tags.isEmpty {
            status = .none
            rightLabel.text = "Choose"
        } else {
            status = .fail
            rightLabel.text = "Too many tags"
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension ChooseTagCell {
    enum Status {
        case done, fail, none
    }
}
