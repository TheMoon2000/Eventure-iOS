//
//  GenderSelectionCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/6/20.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class GenderSelectionCell: UITableViewCell {
    
    
    var gender: User.Gender = .unspecified {
        didSet {
            switch gender {
            case .male:
                genderIcon.image = #imageLiteral(resourceName: "male")
            case .female:
                genderIcon.image = #imageLiteral(resourceName: "female")
            case .non_binary:
                genderIcon.image = #imageLiteral(resourceName: "non-binary")
            case .unspecified:
                genderIcon.image = #imageLiteral(resourceName: "unknown")
            }
        }
    }
    private var genderIcon: UIImageView!
    private var disclosure: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    init() {
        super.init(style: .default, reuseIdentifier: nil)
        
        selectionStyle = .none
        makeLabel()
        disclosure = makeDisclosure()
        genderIcon = makeGenderIcon()
    }
    
    private func makeLabel() {
        let label = UILabel()
        label.text = "Gender"
        label.textColor = AppColors.label
        label.font = .systemFont(ofSize: 18.2, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        label.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor,
                                   constant: 15).isActive = true
        label.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor,
                                      constant: -12).isActive = true
        label.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor,
                                    constant: 36).isActive = true
    }
    
    private func makeDisclosure() -> UIImageView {
        let disclosure = UIImageView(image: #imageLiteral(resourceName: "disclosure"))
        disclosure.contentMode = .scaleAspectFit
        disclosure.translatesAutoresizingMaskIntoConstraints = false
        addSubview(disclosure)
        
        disclosure.widthAnchor.constraint(equalToConstant: 22).isActive = true
        disclosure.heightAnchor.constraint(equalToConstant: 26).isActive = true
        disclosure.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor).isActive = true
        disclosure.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -36).isActive = true
        
        return disclosure
    }
    
    private func makeGenderIcon() -> UIImageView {
        let icon = UIImageView(image: #imageLiteral(resourceName: "unknown"))
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        addSubview(icon)
        
        icon.widthAnchor.constraint(equalToConstant: 28).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 27).isActive = true
        icon.centerYAnchor.constraint(equalTo: disclosure.centerYAnchor).isActive = true
        icon.rightAnchor.constraint(equalTo: disclosure.rightAnchor, constant: -28).isActive = true
        
        return icon
    }
    
    func collapseDisclosure(animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.disclosure.transform = CGAffineTransform(rotationAngle: 0)
            }
        } else {
            self.disclosure.transform = CGAffineTransform(rotationAngle: 0)
        }
    }
    
    func expandDisclosure(animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.disclosure.transform = CGAffineTransform(rotationAngle: .pi / 2)
            }
        } else {
            self.disclosure.transform = CGAffineTransform(rotationAngle: .pi / 2)
        }
    }

}
