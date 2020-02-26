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
    var primaryAction: (() -> ())?
    var spinner: UIActivityIndicatorView!
    let width: CGFloat
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }
    
    required init(width: CGFloat) {
        self.width = width
        super.init(style: .default, reuseIdentifier: nil)
        
        selectionStyle = .none
        backgroundColor = .clear
        button = makeButton()
        spinner = makeSpinner()
    }

    private func makeButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.tintColor = .white
        button.backgroundColor = AppColors.main
        button.titleLabel?.font = .appFontSemibold(18.5)
        button.layer.cornerRadius = 26
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)
        
        button.heightAnchor.constraint(equalToConstant: 52).isActive = true
        button.widthAnchor.constraint(equalToConstant: width).isActive = true
        button.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
        button.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40).isActive = true
        
        button.addTarget(self, action: #selector(primaryButtonTriggered), for: .touchUpInside)
        button.addTarget(self, action: #selector(primaryButtonPressed(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(primaryButtonLifted(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit])
        
        return button
    }
    
    private func makeSpinner() -> UIActivityIndicatorView {
        let spinner = UIActivityIndicatorView(style: .white)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.alpha = 0.8
        addSubview(spinner)
        
        spinner.centerXAnchor.constraint(equalTo: button.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
        
        return spinner
    }
    
    
    // Button events
    
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
            sender.backgroundColor = AppColors.main
        }
    }
    
    @objc private func primaryButtonTriggered() {
        if let action = primaryAction {
            action()
        } else {
            print("primary action triggered")
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
