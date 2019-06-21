//
//  ButtonCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/6/20.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class ButtonCell: UITableViewCell {

    var button: UIButton!
    var altButton: UIButton!
    var primaryAction: (() -> ())?
    var secondaryAction: (() -> ())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(style: .default, reuseIdentifier: nil)
        
        self.selectionStyle = .none
        button = makeButton()
        altButton = makeAltButton()
    }

    private func makeButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.tintColor = .white
        button.backgroundColor = MAIN_TINT
        button.titleLabel?.font = .systemFont(ofSize: 18.5, weight: .semibold)
        button.layer.cornerRadius = 25
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)
        
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.widthAnchor.constraint(equalToConstant: 220).isActive = true
        button.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
        button.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        
        button.addTarget(self, action: #selector(primaryButtonTriggered), for: .touchUpInside)
        button.addTarget(self, action: #selector(primaryButtonPressed(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(primaryButtonLifted(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit])
        
        return button
    }
    
    private func makeAltButton() -> UIButton {
        let altButton = UIButton(type: .system)
        altButton.setTitle("I Have an Account", for: .normal)
        altButton.tintColor = .init(white: 0.7, alpha: 1)
        altButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        altButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(altButton)
        
        altButton.centerXAnchor.constraint(equalTo: self.button.centerXAnchor).isActive = true
        altButton.topAnchor.constraint(equalTo: self.button.bottomAnchor,
                                       constant: 16).isActive = true
        altButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor,
                                          constant: -40).isActive = true
        
        altButton.addTarget(self,
                            action: #selector(altButtonTriggered),
                            for: .touchUpInside)
        
        return altButton
    }
    
    @objc private func primaryButtonPressed(_ sender: UIButton) {
        let components = button.backgroundColor!.cgColor.components!
        let darker_r = max(0, components[0] - 0.02)
        let darker_g = max(0, components[1] - 0.02)
        let darker_b = max(0, components[2] - 0.02)
        sender.backgroundColor = UIColor(red: darker_r,
                                         green: darker_g,
                                         blue: darker_b,
                                         alpha: 1)
    }
    
    @objc private func primaryButtonLifted(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2) {
            sender.backgroundColor = MAIN_TINT
        }
    }
    
    @objc private func primaryButtonTriggered() {
        if let action = primaryAction {
            action()
        } else {
            print("primary action triggered")
        }
    }
    
    @objc private func altButtonTriggered() {
        if let action = secondaryAction {
            action()
        } else {
            print("secondary action triggered")
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
