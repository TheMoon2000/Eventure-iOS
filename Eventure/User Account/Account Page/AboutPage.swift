//
//  AboutPage.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/3.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SafariServices

class AboutPage: UIViewController {

    private var canvas: UIScrollView!
    private var logo: UIImageView!
    private var titleLabel: UILabel!
    private var detailMessage: UITextView!
    
    var aboutText = "Eventure is a mobile app developed by a group of students from UC Berkeley (**Calpha Dev**) as a platform dedicated to college students for on-campus event exploration and promotion. See our [privacy policy](https://eventure.calpha.dev/privacy) for details.\n\n If you have any questions or concerns, please email us at support@eventure-app.com."
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "About Eventure"
        view.backgroundColor = AppColors.navbar
        
        canvas = {
            let canvas = UIScrollView()
            canvas.alwaysBounceVertical = true
            canvas.contentInsetAdjustmentBehavior = .always
            canvas.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(canvas)
            
            canvas.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            canvas.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            canvas.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            canvas.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            return canvas
        }()
        
        logo = {
            let iv = UIImageView(image: #imageLiteral(resourceName: "user_default"))
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(iv)
            
            iv.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            iv.widthAnchor.constraint(equalToConstant: 90).isActive = true
            iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
            iv.topAnchor.constraint(equalTo: canvas.topAnchor, constant: 50).isActive = true
            
            return iv
        }()
        
        titleLabel = {
            let label = UILabel()
            let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
            label.text = "Eventure " + appVersion
            label.textColor = AppColors.label
            label.font = .systemFont(ofSize: 20, weight: .medium)
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            label.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 20).isActive = true
            
            return label
        }()
        
        detailMessage = {
            let tv = UITextView()
            tv.backgroundColor = .clear
            tv.delegate = self
            tv.isEditable = false
            tv.isScrollEnabled = false
            tv.attributedText = aboutText.attributedText()
            if #available(iOS 12.0, *) {
                if traitCollection.userInterfaceStyle == .dark {
                    tv.attributedText = aboutText.attributedText(style: PLAIN_DARK)
                }
            }
            tv.dataDetectorTypes = [.link]
            tv.linkTextAttributes[.foregroundColor] = AppColors.link
            tv.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(tv)
            
            tv.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
            tv.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -30).isActive = true
            tv.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
            tv.bottomAnchor.constraint(equalTo: canvas.bottomAnchor, constant: -30).isActive = true
            
            return tv
        }()
    }
    

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard UIApplication.shared.applicationState != .background else { return }
        
        
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .dark {
                detailMessage.attributedText = aboutText.attributedText(style: PLAIN_DARK)
            } else {
                detailMessage.attributedText = aboutText.attributedText()
            }
        }
    }

}

extension AboutPage: UITextViewDelegate {
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
