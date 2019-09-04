//
//  OrgInfoPage.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/17.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class OrgInfoPage: UIViewController {
    
    var detailPage: OrgDetailPage!
    var organization: Organization!
    
    private var altLogoStack: UIStackView!
    
    private var logoImage: UIImageView!
    private var titleLabel: UILabel!
    private var canvas: UIScrollView!
    private var line: UIView!
    private var tabStrip: ButtonBarPagerTabStripViewController!
    private var lineTopConstraint: NSLayoutConstraint!
    
    private var currentImageView: UIImageView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.layoutIfNeeded()
        
        canvas = {
            let sv = UIScrollView()
            sv.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(sv)
            
            sv.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            sv.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            sv.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            sv.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            return sv
        }()
        
        logoImage = {
            let iv = UIImageView(image: organization.logoImage)
            if iv.image == nil {
                iv.image = #imageLiteral(resourceName: "unknown").withRenderingMode(.alwaysTemplate)
            }
            iv.tintColor = MAIN_DISABLED
            iv.contentMode = .scaleAspectFit
            iv.layer.cornerRadius = 5
            iv.isHidden = UIScreen.main.bounds.width > UIScreen.main.bounds.height
            iv.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(iv)
            
            iv.centerXAnchor.constraint(equalTo: canvas.centerXAnchor).isActive = true
            iv.topAnchor.constraint(equalTo: canvas.topAnchor, constant: 10).isActive = true
            iv.widthAnchor.constraint(equalToConstant: 90).isActive = true
            iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
            
            iv.isUserInteractionEnabled = true
            iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped)))
            
            return iv
        }()
        
        titleLabel = {
            let label = UILabel()
            label.numberOfLines = 3
            label.textAlignment = .center
            label.text = organization.title
            label.textColor = .init(white: 0.1, alpha: 1)
            label.font = .systemFont(ofSize: 21, weight: .semibold)
            label.isHidden = UIScreen.main.bounds.width > UIScreen.main.bounds.height
            label.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: canvas.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
            label.rightAnchor.constraint(equalTo: canvas.safeAreaLayoutGuide.rightAnchor, constant: -30).isActive = true
            label.topAnchor.constraint(equalTo: logoImage.bottomAnchor, constant: 20).isActive = true
            
            return label
        }()
        
        altLogoStack = {
            let iv = UIImageView(image: organization.logoImage)
            iv.translatesAutoresizingMaskIntoConstraints = false
            iv.widthAnchor.constraint(equalToConstant: 75).isActive = true
            iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
            
            let label = UILabel()
            label.text = organization.title
            label.textColor = .init(white: 0.1, alpha: 1)
            label.font = .systemFont(ofSize: 21, weight: .semibold)
            label.translatesAutoresizingMaskIntoConstraints = false
            
            let stack = UIStackView(arrangedSubviews: [iv, label])
            stack.isHidden = view.frame.height >= 500
            stack.spacing = 20
            stack.alignment = .center
            stack.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(stack)
            
            stack.leftAnchor.constraint(greaterThanOrEqualTo: canvas.leftAnchor, constant: 20).isActive = true
            stack.rightAnchor.constraint(lessThanOrEqualTo: canvas.rightAnchor, constant: -20).isActive = true
            stack.centerXAnchor.constraint(equalTo: canvas.centerXAnchor, constant: -1).isActive = true
            stack.topAnchor.constraint(equalTo: canvas.topAnchor, constant: 20).isActive = true
            
            return stack
        }()
        
        line = {
            let line = UIView()
            line.backgroundColor = .init(white: 0.93, alpha: 1)
            line.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(line)
            
            line.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            line.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            line.heightAnchor.constraint(equalToConstant: 1).isActive = true
            
            if logoImage.isHidden {
                lineTopConstraint = line.topAnchor.constraint(equalTo: altLogoStack.bottomAnchor, constant: 30)
            } else {
                lineTopConstraint = line.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30)
            }
            lineTopConstraint.isActive = true
            
            return line
        }()
        
        
        tabStrip = {
            let tabStrip = OrgInfoTabStrip(organization: organization)
            tabStrip.view.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(tabStrip.view)
            
            tabStrip.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            tabStrip.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            tabStrip.view.topAnchor.constraint(equalTo: line.bottomAnchor).isActive = true
            tabStrip.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            addChild(tabStrip)
            tabStrip.didMove(toParent: self)
            
            return tabStrip
        }()
    }
    
    @objc private func imageTapped() {
        if let logo = organization.logoImage {
            let fullScreen = ImageFullScreenPage(image: logo)
            present(fullScreen, animated: false, completion: nil)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { context in
            self.view.removeConstraint(self.lineTopConstraint)
            if size.height < 500 {
                self.altLogoStack.isHidden = false
                self.logoImage.isHidden = true
                self.titleLabel.isHidden = true
                self.lineTopConstraint = self.line.topAnchor.constraint(equalTo: self.altLogoStack.bottomAnchor, constant: 20)
            } else {
                self.altLogoStack.isHidden = true
                self.logoImage.isHidden = false
                self.titleLabel.isHidden = false
                self.lineTopConstraint = self.line.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 30)
            }
            self.lineTopConstraint.isActive = true
        }, completion: nil)
    }
}
