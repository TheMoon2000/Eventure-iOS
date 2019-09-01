//
//  TextFieldCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/31.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SafariServices

class TextFieldCell: UITableViewCell, UITextFieldDelegate {

    private var parentVC: UIViewController!
    
    var icon: UIImageView!
    var linkButton: UIButton!
    var textfield: UITextField!
    private var currentLink: String? {
        didSet {
            linkButton.isEnabled = currentLink != nil
        }
    }
    
    var endEditingHandler: ((UITextField) -> ())?
    var returnHandler: ((UITextField) -> ())?
    
    var linkDetectionEnabled = false {
        didSet {
            linkButtonWidth.constant = linkDetectionEnabled ? 40 : 0
        }
    }
    private var linkButtonWidth: NSLayoutConstraint!
    
    required init(parentVC: UIViewController) {
        super.init(style: .default, reuseIdentifier: nil)
        
        self.parentVC = parentVC
        
        self.selectionStyle = .none
        
        let h = heightAnchor.constraint(equalToConstant: 55)
        h.priority = .defaultHigh
        h.isActive = true
        
        icon = {
            let iv = UIImageView(image: #imageLiteral(resourceName: "comments"))
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            addSubview(iv)
            
            iv.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 18).isActive = true
            iv.widthAnchor.constraint(equalToConstant: 25).isActive = true
            iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
            iv.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            return iv
        }()
        
        linkButton = {
            let button = UIButton(type: .system)
            button.imageView?.contentMode = .scaleAspectFit
            button.setImage(#imageLiteral(resourceName: "link").withRenderingMode(.alwaysTemplate), for: .normal)
            button.isEnabled = false
            button.imageEdgeInsets.left = 8
            button.imageEdgeInsets.right = 8
            button.translatesAutoresizingMaskIntoConstraints = false
            addSubview(button)
            
            linkButtonWidth = button.widthAnchor.constraint(equalToConstant: 0)
            linkButtonWidth.isActive = true
            button.heightAnchor.constraint(equalTo: button.widthAnchor).isActive = true
            button.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            button.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
            button.addTarget(self, action: #selector(openLink), for: .touchUpInside)
            
            return button
        }()
        
        textfield = {
            let tf = UITextField()
            tf.delegate = self
            tf.clearButtonMode = .whileEditing
            tf.returnKeyType = .next
            tf.autocorrectionType = .no
            tf.translatesAutoresizingMaskIntoConstraints = false
            addSubview(tf)
            
            tf.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 15).isActive = true
            tf.rightAnchor.constraint(equalTo: linkButton.leftAnchor, constant: 0).isActive = true
            tf.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            tf.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
            tf.addTarget(self, action: #selector(textChanged), for: .editingChanged)
            
            return tf
        }()
    }
    
    @objc func textChanged() {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: textfield.text!, options: [], range: NSMakeRange(0, textfield.text!.count))
                
        guard let first = matches.first else {
            currentLink = nil
            return
        }
        
        if first.resultType == .link, let url = first.url {
            var modified = url.absoluteString
            if !modified.hasPrefix("http://") && !modified.hasPrefix("https://") {
                modified = "https://" + modified
            }
            currentLink = modified
        } else {
            currentLink = nil
        }
    }
    
    @objc private func openLink() {
        guard currentLink != nil else { return }
        if let url = URL(string: currentLink!) {
            let vc = SFSafariViewController(url: url)
            parentVC.present(vc, animated: true, completion: nil)
        } else {
            print(currentLink! + " cannot be opened")
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        endEditingHandler?(textfield)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        returnHandler?(textField)
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
