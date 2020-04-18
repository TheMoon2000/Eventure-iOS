//
//  BannerArticleContent.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/4/8.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import UIKit
import SafariServices

class BannerArticleContent: UIViewController {
    
    private var bannerInfo: BannerInfo!
    
    private var canvas: UIScrollView!
    private var border: UIView!
    private var titleText: UILabel!
    private var separatorLine: UIView!
    private var bodyText: UITextView!
    private var timeInfo: UILabel!
    
    private let padding: CGFloat = 18.0
    
    required init(info: BannerInfo) {
        super.init(nibName: nil, bundle: nil)
        
        bannerInfo = info
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = AppColors.background
        
        if bannerInfo.link != nil {
            navigationItem.rightBarButtonItem = .init(image: #imageLiteral(resourceName: "more"), style: .plain, target: self, action: #selector(more))
        }
        
        canvas = {
            let sv = UIScrollView()
            sv.backgroundColor = .clear
            sv.alwaysBounceVertical = true
            sv.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(sv)
            
            sv.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            sv.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            sv.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            sv.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            return sv
        }()
        
        border = {
            let border = UIView()
            border.layer.borderWidth = 1
            border.layer.cornerRadius = 7
            border.layer.shadowOpacity = 0.06
            border.layer.shadowOffset.height = 2
            border.layer.shadowRadius = 5
            border.layer.borderColor = AppColors.lineLight.cgColor
            border.backgroundColor = AppColors.background
            border.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(border)
            
            border.leftAnchor.constraint(equalTo: canvas.safeAreaLayoutGuide.leftAnchor, constant: padding).isActive = true
            border.rightAnchor.constraint(equalTo: canvas.safeAreaLayoutGuide.rightAnchor, constant: -padding).isActive = true
            border.topAnchor.constraint(equalTo: canvas.topAnchor, constant: padding).isActive = true
            border.bottomAnchor.constraint(equalTo: canvas.bottomAnchor, constant: -padding).isActive = true
            
            return border
        }()
        
        titleText = {
            let label = UILabel()
            label.font = .appFontSemibold(24)
            label.textColor = AppColors.label
            label.numberOfLines = 10
            label.text = bannerInfo.title
            label.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: border.leftAnchor, constant: 20).isActive = true
            label.rightAnchor.constraint(equalTo: border.rightAnchor, constant: -20).isActive = true
            label.topAnchor.constraint(equalTo: border.topAnchor, constant: 20).isActive = true
            
            return label
        }()
        
        
        separatorLine = {
            let line = UIView()
            line.backgroundColor = AppColors.line
            line.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(line)
            
            line.heightAnchor.constraint(equalToConstant: 1).isActive = true
            line.leftAnchor.constraint(equalTo: titleText.leftAnchor).isActive = true
            line.rightAnchor.constraint(equalTo: titleText.rightAnchor).isActive = true
            line.topAnchor.constraint(equalTo: titleText.bottomAnchor, constant: 12).isActive = true
            
            return line
        }()
        
        bodyText = {
            let tv = UITextView()
            
            if #available(iOS 12.0, *), traitCollection.userInterfaceStyle == .dark {
                tv.attributedText = bannerInfo.message!.attributedText(style: PLAIN_DARK)
            } else {
                tv.attributedText = bannerInfo.message!.attributedText()
            }
            
            tv.isScrollEnabled = false
            tv.backgroundColor = .clear
            tv.delegate = self
            tv.isEditable = false
            tv.textContainerInset.top = 12
            tv.textContainerInset.bottom = 12
            tv.textContainer.lineFragmentPadding = .zero
            tv.linkTextAttributes[.foregroundColor] = AppColors.link
            tv.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(tv)
            
            tv.leftAnchor.constraint(equalTo: titleText.leftAnchor).isActive = true
            tv.rightAnchor.constraint(equalTo: titleText.rightAnchor).isActive = true
            tv.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: 15).isActive = true
            
            return tv
        }()
        
        timeInfo = {
            let label = UILabel()
            label.font = .appFontRegular(15)
            label.textColor = AppColors.lightTitle
            label.numberOfLines = 3
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: titleText.leftAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: titleText.rightAnchor).isActive = true
            label.topAnchor.constraint(equalTo: bodyText.bottomAnchor, constant: 25).isActive = true
            label.bottomAnchor.constraint(equalTo: border.bottomAnchor, constant: -20).isActive = true
            
            return label
        }()
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.timeInfo.text = self.bannerInfo.publishedDate.elapsedTimeDescription
        } .fire()
    }
    
    @objc private func more() {
        let alert = UIAlertController(title: "This article is associated with \(bannerInfo.link!.absoluteString).", message: nil, preferredStyle: .actionSheet)
        alert.addAction(.init(title: "Visit Link", style: .default, handler: { _ in
            let vc = SFSafariViewController(url: self.bannerInfo.link!)
            vc.preferredControlTintColor = AppColors.main
            self.present(vc, animated: true)
        }))
        alert.addAction(.init(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        DispatchQueue.main.async {
        
            if #available(iOS 12.0, *), self.traitCollection.userInterfaceStyle == .dark {
                self.bodyText.attributedText = self.bannerInfo.message!.attributedText(style: PLAIN_DARK)
            } else {
                self.bodyText.attributedText = self.bannerInfo.message!.attributedText()
            }
            
            self.border.layer.borderColor = AppColors.lineLight.cgColor
        }
    }
}


extension BannerArticleContent: UITextViewDelegate {
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

