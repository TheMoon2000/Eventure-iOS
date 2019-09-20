//
//  EmailCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/29.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class EmailCell: UITableViewCell, UITextFieldDelegate {
    
    private var parentVC: UIViewController!
    
    private let RADIUS: CGFloat = 26
    private var overlay: UIView!
    private var addressButton: UIButton!
    
    var email: String {
        return textField.text! + addressButton.title(for: .normal)!
    }
    
    private var textField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.returnKeyType = .next
        field.placeholder = "Email"
        field.autocorrectionType = .no
        field.adjustsFontSizeToFitWidth = true
        field.minimumFontSize = 9
        return field
    }()
    
    var returnHandler: (() -> ())?
    var completionHandler: ((EmailCell) -> ())?
    var changeHandler: ((EmailCell) -> ())?
    
    var status: Status = .none {
        didSet {
            switch status {
            case .none:
                overlay.layer.borderColor = LINE_TINT.cgColor
            case .fail:
                overlay.layer.borderColor = FATAL_COLOR.cgColor
            case .disconnected:
                overlay.layer.borderColor = WARNING_COLOR.cgColor
            case .tick:
                overlay.layer.borderColor = PASSED_COLOR.cgColor
            }
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        
        textField.becomeFirstResponder()
        return true
    }
    
    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        
        textField.resignFirstResponder()
        return true
    }
    
    required init(parentVC: UIViewController) {
        super.init(style: .default, reuseIdentifier: nil)
        
        self.parentVC = parentVC
        selectionStyle = .none
        
        overlay = {
            let view = UIView()
            view.backgroundColor = .init(white: 0.94, alpha: 1)
            view.layer.cornerRadius = RADIUS
            view.layer.borderWidth = 1
            view.layer.borderColor = LINE_TINT.cgColor
            view.layer.masksToBounds = true
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            
            view.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor,
                                       constant: 30).isActive = true
            view.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor,
                                        constant: -30).isActive = true
            view.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor,
                                      constant: 10).isActive = true
            view.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor,
                                         constant: -10).isActive = true
            
            view.heightAnchor.constraint(equalToConstant: RADIUS * 2).isActive = true
            
            return view
        }()
        
        configureTextfield()
        
        
        addressButton = {
            let button = UIButton()
            button.setTitleColor(MAIN_TINT, for: .normal)
            button.layer.borderColor = overlay.layer.borderColor
            button.layer.borderWidth = 1
            button.titleEdgeInsets.right = 10
            button.titleLabel?.font = .systemFont(ofSize: 16.5)
            button.setTitle("@berkeley.edu", for: .normal)
            button.backgroundColor = .init(white: 0.98, alpha: 1)
            button.translatesAutoresizingMaskIntoConstraints = false
            overlay.addSubview(button)
            
            button.heightAnchor.constraint(equalTo: overlay.heightAnchor).isActive = true
            button.rightAnchor.constraint(equalTo: overlay.rightAnchor).isActive = true
            button.centerYAnchor.constraint(equalTo: overlay.centerYAnchor).isActive = true
            button.leftAnchor.constraint(equalTo: textField.rightAnchor, constant: 10).isActive = true
            let c = button.widthAnchor.constraint(equalToConstant: button.intrinsicContentSize.width + 35)
            c.priority = .defaultHigh
            c.isActive = true
            
            button.addTarget(self, action: #selector(buttonPressed), for: .touchDown)
            button.addTarget(self, action: #selector(buttonLifted), for: [.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit])
            button.addTarget(self, action: #selector(chooseCampus), for: .touchUpInside)
            
            return button
        }()
        
    }
    
    private func configureTextfield() {
        textField.delegate = self
        textField.addTarget(self,
                            action: #selector(textDidChange),
                            for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textField)
        
        textField.leftAnchor.constraint(equalTo: overlay.leftAnchor,
                                        constant: RADIUS).isActive = true
        textField.topAnchor.constraint(equalTo: topAnchor, constant: 1).isActive = true
        textField.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        textField.widthAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            textField.becomeFirstResponder()
        }
    }
    
    @objc private func buttonPressed() {
        addressButton.backgroundColor = .init(white: 0.96, alpha: 1)
    }
    
    @objc private func buttonLifted() {
        UIView.transition(
            with: addressButton,
            duration: 0.1,
            options: .curveEaseOut,
            animations: {
                self.addressButton.backgroundColor = .init(white: 0.98, alpha: 1)
            },
            completion: nil)
    }
    
    @objc private func chooseCampus() {
        let alert = UIAlertController(title: "Since Eventure is dedicated to campus communities, we require that your account's email address is associated with your university.", message: "Please select from one of our supported campuses.", preferredStyle: .actionSheet)
        
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        
        if Campus.supported.isEmpty {
            alert.message = "Our list of supported campus email providers is not yet loaded. Please come back later!"
        }
        
        
        let chooseAction: ((UIAlertAction) -> ()) = { action in
            self.addressButton.setTitle(
                "@" + Campus.supported[action.title!]!.emailSuffix,
                for: .normal)
        }
        
        for campus in Campus.supported {
            alert.addAction(.init(title: campus.key, style: .default, handler: chooseAction))
        }
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = addressButton
            popoverController.sourceRect = CGRect(x: addressButton.bounds.midX, y: addressButton.bounds.midY, width: 0, height: 0)
        }
        
        parentVC.present(alert, animated: true, completion: nil)
    }
    
    // Textfield delegate
    
    var originalText = ""
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        originalText = textField.text!
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        completionHandler?(self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        returnHandler?()
        return true
    }
    
    @objc private func textDidChange() {
        changeHandler?(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

extension EmailCell {
    enum Status {
        case none, tick, fail, disconnected
    }
}
