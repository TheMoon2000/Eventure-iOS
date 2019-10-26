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
    
    private var logoImage: UIImageView!
    private var titleLabel: UILabel!
    private var altLogo: UIImageView!
    private var altTitle: UILabel!
    
    private var canvas: UIScrollView!
    private var line: UIView!
    private var tabStrip: ButtonBarPagerTabStripViewController!
    private var lineTopConstraint: NSLayoutConstraint!
    
    private var currentImageView: UIImageView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = AppColors.navbar
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
                iv.image = #imageLiteral(resourceName: "group").withRenderingMode(.alwaysTemplate)
            }
            iv.tintColor = AppColors.mainDisabled
            iv.contentMode = .scaleAspectFit
            iv.layer.cornerRadius = 5
            iv.clipsToBounds = true
            iv.isHidden = view.frame.height <= 500
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
            label.numberOfLines = 5
            label.textAlignment = .center
            label.text = organization.title
            label.textColor = AppColors.label
            label.font = .systemFont(ofSize: 21, weight: .semibold)
            label.isHidden = view.frame.height < 500
            label.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
            label.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -30).isActive = true
            label.topAnchor.constraint(equalTo: logoImage.bottomAnchor, constant: 20).isActive = true
            
            return label
        }()
        
        altTitle = {
            let label = UILabel()
            label.isHidden = true
            label.numberOfLines = 3
            label.text = organization.title
            label.textColor = AppColors.label
            label.font = .systemFont(ofSize: 21, weight: .semibold)
            label.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 55).isActive = true
            label.rightAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: -30).isActive = true
            
            return label
        }()
        
        altLogo = {
            let iv = UIImageView(image: organization.logoImage ?? #imageLiteral(resourceName: "group").withRenderingMode(.alwaysTemplate))
            iv.isHidden = true
            iv.contentMode = .scaleAspectFit
            iv.tintColor = AppColors.mainDisabled
            iv.translatesAutoresizingMaskIntoConstraints = false
            iv.widthAnchor.constraint(equalToConstant: 75).isActive = true
            iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
            canvas.addSubview(iv)
            
            iv.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
            iv.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
            iv.rightAnchor.constraint(equalTo: altTitle.leftAnchor, constant: -20).isActive = true
            iv.centerYAnchor.constraint(equalTo: altTitle.centerYAnchor).isActive = true
            
            return iv
        }()
        
        
        line = {
            let line = UIView()
            if #available(iOS 12.0, *), traitCollection.userInterfaceStyle == .dark {
                line.alpha = 0.0
            } else {
                line.alpha = 0.8
            }
            line.backgroundColor = AppColors.line
            line.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(line)
            
            line.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            line.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            line.heightAnchor.constraint(equalToConstant: 1).isActive = true
            
            if logoImage.isHidden {
                lineTopConstraint = line.topAnchor.constraint(equalTo: altLogo.bottomAnchor, constant: 30)
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 12.0, *), traitCollection.userInterfaceStyle == .dark {
            line?.alpha = 0.0
        } else {
            line?.alpha = 0.8
        }
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
                self.altLogo.isHidden = false
                self.altTitle.isHidden = false
                self.logoImage.isHidden = true
                self.titleLabel.isHidden = true
                self.lineTopConstraint = self.line.topAnchor.constraint(equalTo: self.altLogo.bottomAnchor, constant: 20)
            } else {
                self.altLogo.isHidden = true
                self.altTitle.isHidden = true
                self.logoImage.isHidden = false
                self.titleLabel.isHidden = false
                self.lineTopConstraint = self.line.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 30)
            }
            self.lineTopConstraint.isActive = true
        }, completion: nil)
    }
}
