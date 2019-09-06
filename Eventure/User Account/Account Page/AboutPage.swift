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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "About Eventure"
        view.backgroundColor = .white
        
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
            label.textColor = .darkGray
            label.font = .systemFont(ofSize: 20, weight: .medium)
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            label.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 20).isActive = true
            
            return label
        }()
        
        detailMessage = {
            let tv = UITextView()
            tv.delegate = self
            tv.isEditable = false
            tv.isScrollEnabled = false
            tv.attributedText = "Eventure is a mobile app developed by a group of students from UC Berkeley (**Calpha Dev**) as a platform dedicated to college students for on-campus event exploration and promotion.\n\n See our [privacy policy](https://eventure.calpha.dev/privacy) for details.".attributedText()
            tv.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(tv)
            
            tv.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
            tv.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -30).isActive = true
            tv.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
            tv.bottomAnchor.constraint(equalTo: canvas.bottomAnchor, constant: -30).isActive = true
            
            return tv
        }()
    }
    


}

extension AboutPage: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let vc = SFSafariViewController(url: URL)
        present(vc, animated: true)
        return false
    }
}
