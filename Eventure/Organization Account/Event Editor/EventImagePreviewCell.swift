//
//  EventImagePreviewCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/27.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class EventImagePreviewCell: UITableViewCell, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private(set) var parentVC: UIViewController!
    
    private var bgView: UIView!
    private(set) var previewImage: UIImageView!
    private var captionLabel: UILabel!
    private(set) var chooseImageLabel: UILabel!
    
    var updateImageHandler: ((UIImage?) -> ())?
    
    init(parentVC: UIViewController) {
        super.init(style: .default, reuseIdentifier: nil)
        
        self.parentVC = parentVC
        
        selectionStyle = .none
        backgroundColor = .clear
        
        bgView = {
            let view = UIView()
            view.backgroundColor = .white
            view.layer.cornerRadius = 7
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            
            view.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
            view.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
            view.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
            
            let bottomConstraint = view.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8)
            bottomConstraint.priority = .defaultHigh
            bottomConstraint.isActive = true
            
            return view
        }()
        
        captionLabel = {
            let label = UILabel()
            label.textAlignment = .center
            label.numberOfLines = 0
            label.text = "Cover image are rendered in a container with 3:2 width-to-height radio. Additional content is clipped."
            label.font = .systemFont(ofSize: 14)
            label.textColor = .gray
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 15).isActive = true
            label.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -15).isActive = true
            label.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -20).isActive = true
            
            return label
        }()
        
        previewImage = {
            let iv = UIImageView()
            iv.layer.borderWidth = 1
            iv.layer.borderColor = LINE_TINT.cgColor
            iv.backgroundColor = .init(white: 0.96, alpha: 1)
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            iv.isUserInteractionEnabled = true
            iv.translatesAutoresizingMaskIntoConstraints = false
            addSubview(iv)
            
            iv.leftAnchor.constraint(greaterThanOrEqualTo: bgView.leftAnchor, constant: 15).isActive = true
            
            iv.rightAnchor.constraint(lessThanOrEqualTo: bgView.rightAnchor, constant: -15).isActive = true
            
            let left = iv.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 15)
            left.priority = .defaultHigh
            left.isActive = true
            
            let right = iv.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -15)
            right.priority = .defaultHigh
            right.isActive = true
            
            iv.centerXAnchor.constraint(equalTo: bgView.centerXAnchor).isActive = true
            iv.widthAnchor.constraint(lessThanOrEqualToConstant: 500).isActive = true
            iv.widthAnchor.constraint(equalTo: iv.heightAnchor, multiplier: 1.5).isActive = true
            iv.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 15).isActive = true
            iv.bottomAnchor.constraint(equalTo: captionLabel.topAnchor, constant: -12).isActive = true
            
            iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(chooseImage)))
            
            return iv
        }()
        
        chooseImageLabel = {
            let label = UILabel()
            label.text = "Choose Image"
            label.font = .systemFont(ofSize: 17)
            label.textColor = .darkGray
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: previewImage.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: previewImage.centerYAnchor).isActive = true
            
            return label
        }()
        
    }
    
    @objc private func chooseImage() {
        let picker = UIImagePickerController()
        picker.sourceType = .savedPhotosAlbum
        picker.delegate = self
        parentVC.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        previewImage.image = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage)?.sizeDown()
        previewImage.backgroundColor = nil
        chooseImageLabel.isHidden = true
        updateImageHandler?(previewImage.image)
        picker.dismiss(animated: true, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}