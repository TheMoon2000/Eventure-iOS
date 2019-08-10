//
//  DetailViewController.swift
//  Eventure
//
//  Created by appa on 8/9/19.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var event: Event!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        var vals = ["title": event.title, "time": event.time, "location": event.location, "hostTitle": event.host.title]
        let textViews = ["title":UITextView(), "time": UITextView(), "location": UITextView(), "hostTitle": UITextView()]
        for v in textViews {
            v.value.allowsEditingTextAttributes = false
            v.value.isEditable = false
            v.value.translatesAutoresizingMaskIntoConstraints = false
            v.value.text = v.key + ": " + vals[v.key]!
            v.value.font = UIFont.preferredFont(forTextStyle: .subheadline)
            v.value.doInset()
            v.value.textColor = .black
            self.view.addSubview(v.value)
            v.value.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
            v.value.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
            v.value.heightAnchor.constraint(equalToConstant: 30).isActive = true
        }
        textViews["title"]!.centerYAnchor.constraint(equalTo: self.view.topAnchor, constant: 120).isActive = true
        textViews["time"]!.topAnchor.constraint(equalTo: textViews["title"]!.bottomAnchor).isActive = true
        textViews["location"]!.topAnchor.constraint(equalTo: textViews["time"]!.bottomAnchor).isActive = true
        textViews["hostTitle"]!.topAnchor.constraint(equalTo: textViews["location"]!.bottomAnchor).isActive = true
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: self.view.frame.width / 3, height: 60)
        button.center = CGPoint(x: self.view.center.x, y: self.view.frame.height - 120)
        button.setTitle("Dismiss", for: UIControl.State.normal)
        button.setTitleColor(UIColor.black, for: UIControl.State.normal)
        button.backgroundColor = UIColor.darkGray
        button.addTarget(self, action: #selector(action), for: UIControl.Event.touchUpInside)
        self.view.addSubview(button)
        // Do any additional setup after loading the view.
    }
    
    @objc func action(sender:UIButton!) {
        self.dismiss(animated: false, completion: nil)
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
