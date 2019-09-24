//
//  AboutViewController.swift
//  Eventure
//
//  Created by appa on 8/23/19.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SafariServices

class AboutViewController: UIViewController, IndicatorInfoProvider {

    var event: Event!
    var detailPage: EventDetailPage!
    private(set) var textView: UITextView!
    
    required init(detailPage: EventDetailPage) {
        super.init(nibName: nil, bundle: nil)
        
        self.event = detailPage.event
        self.detailPage = detailPage
        view.backgroundColor = detailPage.view.backgroundColor
        
        textView = {
            let tv = UITextView()
            tv.attributedText = event.eventDescription.attributedText()
            tv.contentInset.top = 20
            tv.contentInset.bottom = 20
            tv.delegate = self
            tv.scrollIndicatorInsets = .init(top: 20, left: 0, bottom: 20, right: 0)
            tv.backgroundColor = .clear
            tv.dataDetectorTypes = [.link, .phoneNumber]
            tv.linkTextAttributes[.foregroundColor] = LINK_COLOR
            tv.isEditable = false
            tv.isScrollEnabled = false
            tv.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(tv)
            
            tv.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            tv.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
            tv.topAnchor.constraint(equalTo: view.topAnchor, constant: 12).isActive = true
            
            tv.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            
            return tv
        }()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        textView.attributedText = event.eventDescription.attributedText()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        detailPage.invisible.textView.attributedText = textView.attributedText
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "About")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension AboutViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if (URL.absoluteString.hasPrefix("http://") || URL.absoluteString.hasPrefix("https://")) && interaction == .invokeDefaultAction {
            let vc = SFSafariViewController(url: URL)
            self.present(vc, animated: true)
            return false
        }
        
        return true
    }
}
