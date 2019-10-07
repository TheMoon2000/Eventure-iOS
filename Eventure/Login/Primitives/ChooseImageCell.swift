//
//  ChooseImageCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/3.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import TOCropViewController

class ChooseImageCell: UITableViewCell, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private var parentVC: UIViewController!
    private var overlay: UIView!
    private var titleLabel: UILabel!
    private var logo: UIImageView!
    private var clearButton: UIButton!
    
    private var logoShadeColor = UIColor(white: 0.92, alpha: 1)
    
    var chooseImageHandler: ((UIImage?) -> ())?

    init(parentVC: UIViewController, sideInset: CGFloat = 30) {
        super.init(style: .default, reuseIdentifier: nil)
        
        self.parentVC = parentVC
        
        selectionStyle = .none
        heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        overlay = {
            let overlay = UIView()
            overlay.layer.cornerRadius = 7
            overlay.layer.borderColor = AppColors.line.cgColor
            overlay.translatesAutoresizingMaskIntoConstraints = false
            addSubview(overlay)
            
            overlay.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: sideInset).isActive = true
            overlay.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -sideInset).isActive = true
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
        picker.sourceType = .photoLibrary
        picker.delegate = self
        parentVC.present(picker, animated: true, completion: nil)
    }
    
    /*
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        logo.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        logo.backgroundColor = nil
        clearButton.isHidden = false
        logo.layer.borderWidth = 0
        chooseImageHandler?(logo.image?.fixedOrientation())
        picker.dismiss(animated: true, completion: nil)
    }*/
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        let cropper = TOCropViewController(image: image)
        cropper.rotateButtonsHidden = true
        cropper.resetButtonHidden = true
        cropper.aspectRatioPreset = .presetSquare
        cropper.aspectRatioLockEnabled = true
        cropper.allowedAspectRatios = [TOCropViewControllerAspectRatioPreset.presetSquare.rawValue as NSNumber]
        cropper.delegate = self
        picker.present(cropper, animated: true)
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
                self.logo.layer.borderWidth = 1
            },
            completion: nil)
        
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            overlay.layer.borderWidth = 1
            titleLabel.textColor = AppColors.label
        } else {
            overlay.layer.borderWidth = 0
            titleLabel.textColor = .init(white: 0.3, alpha: 1)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}


extension ChooseImageCell: TOCropViewControllerDelegate {
    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        
        logo.image = image.fixedOrientation()
        logo.backgroundColor = nil
        clearButton.isHidden = false
        logo.layer.borderWidth = 0
        
        chooseImageHandler?(logo.image!)
        parentVC.dismiss(animated: true, completion: nil)
    }
}
