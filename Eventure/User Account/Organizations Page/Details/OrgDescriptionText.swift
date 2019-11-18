//
//  OrgDescriptionText.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/17.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SafariServices

class OrgDescriptionText: UIViewController, IndicatorInfoProvider {
    
    var markdownRaw: String = ""
    var textView: UITextView!
    
    required init(text: String) {
        super.init(nibName: nil, bundle: nil)
        
        markdownRaw = text
        view.backgroundColor = AppColors.canvas
        
        textView = {
            let tv = UITextView()
            if #available(iOS 12.0, *), traitCollection.userInterfaceStyle == .dark {
                tv.attributedText = text.attributedText(style: PLAIN_DARK)
            } else {
                tv.attributedText = text.attributedText()
            }
            tv.textContainerInset = .init(top: 30, left: 30, bottom: 40, right: 30)
            tv.backgroundColor = .clear
            tv.dataDetectorTypes = [.link, .phoneNumber]
            tv.linkTextAttributes[.foregroundColor] = AppColors.link
            tv.isEditable = false
            tv.delegate = self
            tv.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(tv)
            
            tv.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
            tv.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
            tv.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            
            let bottomConstraint = tv.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            bottomConstraint.priority = .defaultHigh
            bottomConstraint.isActive = true
            
            return tv
        }()
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "About")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard UIApplication.shared.applicationState != .background else { return }
        
        if #available(iOS 12.0, *), traitCollection.userInterfaceStyle == .dark {
            textView.attributedText = markdownRaw.attributedText(style: PLAIN_DARK)
        } else {
            textView.attributedText = markdownRaw.attributedText()
        }
    }
    

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension OrgDescriptionText: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if (URL.absoluteString.hasPrefix("http://") || URL.absoluteString.hasPrefix("https://")) && interaction == .invokeDefaultAction {
            let vc = SFSafariViewController(url: URL)
            vc.preferredControlTintColor = AppColors.main
            self.present(vc, animated: true)
            return false
        }
        
        return true
    }
}

