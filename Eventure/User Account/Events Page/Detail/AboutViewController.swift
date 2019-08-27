//
//  AboutViewController.swift
//  Eventure
//
//  Created by appa on 8/23/19.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class AboutViewController: UIViewController, IndicatorInfoProvider {

    private var event: Event!
    var textView: UITextView!
    
    required init(event: Event) {
        super.init(nibName: nil, bundle: nil)
        
        self.event = event
        view.backgroundColor = .init(white: 0.92, alpha: 1)
        
        textView = {
            let tv = UITextView()
            tv.attributedText = event.eventDescription.attributedText()
            tv.backgroundColor = .clear
            tv.dataDetectorTypes = [.link, .phoneNumber]
            tv.linkTextAttributes[.foregroundColor] = LINK_COLOR
            tv.isEditable = false
            tv.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(tv)
            
            tv.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            tv.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
            tv.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
            
            let bottomConstraint = tv.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
            bottomConstraint.priority = .defaultHigh
            bottomConstraint.isActive = true
            
            return tv
        }()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        textView.attributedText = event.eventDescription.attributedText()
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
