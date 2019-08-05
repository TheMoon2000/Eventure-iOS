//
//  ChooseTagCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/4.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class ChooseTagCell: UITableViewCell {
    
    private var parentVC: RegisterOrganization!
    private(set) var selectedTags = Set<String>() {
        didSet {
            parentVC.registrationData.tags = selectedTags.description
            print(parentVC.registrationData)
        }
    }
    
    var status: Status = .none {
        didSet {
            switch status {
            case .none:
                statusIcon.image = #imageLiteral(resourceName: "disclosure")
                rightLabel.isHidden = false
            case .done:
                statusIcon.image = #imageLiteral(resourceName: "check")
                rightLabel.isHidden = true
            case .fail:
                statusIcon.image = #imageLiteral(resourceName: "cross")
                rightLabel.isHidden = true
            }
        }
    }
    
    private var overlay: UIView!
    private var leftLabel: UILabel!
    private var rightLabel: UILabel!
    private var statusIcon: UIImageView!
    private var disclosure: UIImageView!

    required init(vc: RegisterOrganization) {
        super.init(style: .default, reuseIdentifier: nil)
        
        parentVC = vc
        selectionStyle = .none
        heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        overlay = {
            let overlay = UIView()
            overlay.layer.cornerRadius = 10
            overlay.layer.borderColor = LINE_TINT.cgColor
            overlay.translatesAutoresizingMaskIntoConstraints = false
            addSubview(overlay)
            
            overlay.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
            overlay.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -30).isActive = true
            overlay.heightAnchor.constraint(equalToConstant: 50).isActive = true
            overlay.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            return overlay
        }()
        
        leftLabel = {
            let label = UILabel()
            label.text = "Pick Tags..."
            label.textColor = .darkGray
            label.font = .systemFont(ofSize: 17, weight: .semibold)
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: overlay.leftAnchor, constant: 12).isActive = true
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            return label
        }()
        
        statusIcon = {
            let icon = UIImageView(image: #imageLiteral(resourceName: "disclosure"))
            icon.translatesAutoresizingMaskIntoConstraints = false
            addSubview(icon)
            
            icon.widthAnchor.constraint(equalToConstant: 25).isActive = true
            icon.heightAnchor.constraint(equalToConstant: 25).isActive = true
            icon.rightAnchor.constraint(equalTo: overlay.rightAnchor, constant: -15).isActive = true
            icon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            return icon
        }()
        
        rightLabel = {
            let label = UILabel()
            label.textColor = .lightGray
            label.text = "Choose"
            label.font = .systemFont(ofSize: 16, weight: .medium)
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.rightAnchor.constraint(equalTo: statusIcon.leftAnchor, constant: -10).isActive = true
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            return label
        }()
        
    }
    
    func pickTags() {
        let tagPicker = TagPickerView()
        tagPicker.customTitle = "Pick 1 ~ 3 tags that best describe your organization!"
        tagPicker.customSubtitle = ""
        tagPicker.maxPicks = 3
        tagPicker.customButtonTitle = "Done"
        tagPicker.customContinueMethod = { tagPicker in
            self.selectedTags = tagPicker.selectedTags
            self.parentVC.navigationController?.popToViewController(self.parentVC, animated: true)
            self.status = .done
        }
        parentVC.navigationController?.pushViewController(tagPicker, animated: true)
        DispatchQueue.main.async {
            tagPicker.selectedTags = self.selectedTags
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            overlay.layer.borderWidth = 1
            leftLabel.textColor = .init(white: 0.1, alpha: 1)
            rightLabel.textColor = .lightGray
            if status == .none {
                statusIcon.image = #imageLiteral(resourceName: "disclosure_pressed")
            }
        } else {
            overlay.layer.borderWidth = 0
            leftLabel.textColor = .init(white: 0.3, alpha: 1)
            rightLabel.textColor = .init(white: 0.75, alpha: 1)
            if status == .none {
                statusIcon.image = #imageLiteral(resourceName: "disclosure")
            }
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
