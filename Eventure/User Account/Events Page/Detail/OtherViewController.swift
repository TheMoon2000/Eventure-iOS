//
//  OtherViewController.swift
//  Eventure
//
//  Created by appa on 8/23/19.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class OtherViewController: UIViewController, IndicatorInfoProvider {
    
    var event: Event!
    var detailPage: EventDetailPage!
    private var textView: UITextView!

    required init(detailPage: EventDetailPage) {
        super.init(nibName: nil, bundle: nil)
        
        self.event = detailPage.event
        self.detailPage = detailPage
        view.backgroundColor = detailPage.view.backgroundColor
        
        textView = {
            let tv = UITextView()
            tv.attributedText = "Event details".attributedText()
            tv.textContainerInset = .init(top: 30, left: 30, bottom: 40, right: 30)
            tv.backgroundColor = .clear
            tv.dataDetectorTypes = [.link, .phoneNumber]
            tv.linkTextAttributes[.foregroundColor] = LINK_COLOR
            tv.isEditable = false
            tv.isScrollEnabled = false
            tv.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(tv)
            
            tv.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
            tv.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
            tv.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
            
            let bottomConstraint = tv.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
            bottomConstraint.priority = .defaultHigh
            bottomConstraint.isActive = true
            
            return tv
        }()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        detailPage.invisible.textView.attributedText = textView.attributedText
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Other")
    }
    
}
