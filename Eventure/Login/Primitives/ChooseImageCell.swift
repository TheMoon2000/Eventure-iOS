//
//  ChooseImageCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/3.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class ChooseImageCell: UITableViewCell, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private var parentVC: UIViewController!
    private var overlay: UIView!
    private var titleLabel: UILabel!
    private var logo: UIImageView!
    private var clearButton: UIButton!
    
    private var logoShadeColor = UIColor(white: 0.92, alpha: 1)

    init(vc: UIViewController) {
        super.init(style: .default, reuseIdentifier: nil)
        
        parentVC = vc
        
        selectionStyle = .none
        heightAnchor.constraint(equalToConstant: 65).isActive = true
        
        overlay = {
            let overlay = UIView()
            overlay.layer.cornerRadius = 12
            overlay.layer.borderColor = LINE_TINT.cgColor
            overlay.translatesAutoresizingMaskIntoConstraints = false
            addSubview(overlay)
            
            overlay.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
            overlay.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -30).isActive = true
            overlay.heightAnchor.constraint(equalToConstant: 60).isActive = true
            overlay.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            return overlay
        }()
        
        titleLabel = {
            let label = UILabel()
            label.text = "Logo (optional):"
            label.font = .systemFont(ofSize: 18, weight: .medium)
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: overlay.leftAnchor, constant: 12).isActive = true
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            return label
        }()
        
        clearButton = {
            let button = UIButton(type: .system)
            button.setTitle("Clear", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
            button.isHidden = true
            button.translatesAutoresizingMaskIntoConstraints = false
            addSubview(button)
            
            button.leftAnchor.constraint(equalTo: titleLabel.rightAnchor, constant: 10).isActive = true
            button.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            button.addTarget(self, action: #selector(clearImage), for: .touchUpInside)
            
            return button
        }()
        
        logo = {
            let logo = UIImageView()
            logo.contentMode = .scaleAspectFit
            logo.backgroundColor = logoShadeColor
            logo.layer.borderWidth = 1
            logo.layer.borderColor = UIColor(white: 0.8, alpha: 1).cgColor
            logo.layer.cornerRadius = 5
            logo.layer.masksToBounds = true
            logo.translatesAutoresizingMaskIntoConstraints = false
            addSubview(logo)
            
            logo.widthAnchor.constraint(equalToConstant: 45).isActive = true
            logo.heightAnchor.constraint(equalToConstant: 45).isActive = true
            logo.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            logo.rightAnchor.constraint(equalTo: overlay.rightAnchor, constant: -12).isActive = true
            
            return logo
        }()
    }
    
    func chooseImage() {
        guard UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) else {
            return
        }
        
        let picker = UIImagePickerController()
        picker.sourceType = .savedPhotosAlbum
        picker.allowsEditing = true
        picker.delegate = self
        parentVC.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print(info)
        logo.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        logo.backgroundColor = nil
        clearButton.isHidden = false
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc private func clearImage() {
        UIView.transition(
            with: self,
            duration: 0.2,
            options: .curveEaseOut,
            animations: {
                self.logo.backgroundColor = self.logoShadeColor
                self.logo.image = nil
                self.clearButton.isHidden = true
            },
            completion: nil)
        
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            overlay.layer.borderWidth = 1
            titleLabel.textColor = .init(white: 0.1, alpha: 1)
        } else {
            overlay.layer.borderWidth = 0
            titleLabel.textColor = .init(white: 0.3, alpha: 1)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
