//
//  DescriptionEditPage.swift
//  Eventure
//
//  Created by Prince Wang on 2019/9/4.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class DescriptionEditPage: UIViewController {
    
    private var descriptionMaxLength = 500
    private var canvas: UIScrollView!
    private var titleText: UITextView!
    private var titlePlaceholder: UILabel!
    private var separatorLine: UIView!
    private var buttonStack: UIStackView!
    private var editButton: UIButton!
    private var previewButton: UIButton!
    private var descriptionText: UITextView!
    private var descriptionPlaceholder: UILabel!
    private var previewText: UITextView!
    private var charCount: UILabel!
    private var spinner: UIActivityIndicatorView!
    private var saveBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        view.tintColor = MAIN_TINT
        
        title = "Organization Description"
        
        // Check
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        canvas = {
            let sv = UIScrollView()
            sv.alwaysBounceVertical = true
            sv.addGestureRecognizer(tap)
            sv.contentInsetAdjustmentBehavior = .always
            sv.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(sv)
            
            sv.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            sv.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            sv.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            sv.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            return sv
        }()
        
        view.layoutIfNeeded()
        
        descriptionText = {
            let tv = UITextView()
            tv.backgroundColor = nil
            tv.isScrollEnabled = false
            tv.keyboardDismissMode = .onDrag
            tv.font = .systemFont(ofSize: 18)
            tv.textColor = .darkGray
            tv.allowsEditingTextAttributes = false
            
            let pStyle = NSMutableParagraphStyle()
            pStyle.lineSpacing = 2
            tv.typingAttributes[NSAttributedString.Key.paragraphStyle] = pStyle
            tv.insertText(Organization.current!.orgDescription)
            tv.delegate = self
            tv.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(tv)
            
            tv.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
            tv.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
            tv.topAnchor.constraint(equalTo: canvas.topAnchor, constant: 10).isActive = true
            tv.heightAnchor.constraint(greaterThanOrEqualToConstant: 200).isActive = true
            
            return tv
        }()
        
        charCount = {
            let label = UILabel()
            label.textColor = .gray
            label.font = .systemFont(ofSize: 15)
            label.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: canvas.leftAnchor, constant: 20).isActive = true
            label.topAnchor.constraint(equalTo: descriptionText.bottomAnchor, constant: 20).isActive = true
            label.bottomAnchor.constraint(equalTo: canvas.bottomAnchor, constant: -20).isActive = true
            
            return label
        }()
        
        descriptionPlaceholder = {
            let label = UILabel()
            label.numberOfLines = 0
            label.font = .systemFont(ofSize: 18, weight: .medium)
            label.textColor = .init(white: 0.8, alpha: 1)
            label.isHidden = true //Fix Me
            label.text = "Please give a brief description of your club within \(descriptionMaxLength) characters."
            label.translatesAutoresizingMaskIntoConstraints = false
            canvas.insertSubview(label, belowSubview: descriptionText)
            
            label.leftAnchor.constraint(equalTo: descriptionText.leftAnchor).isActive = true
            label.topAnchor.constraint(equalTo: descriptionText.topAnchor, constant: descriptionText.textContainerInset.top).isActive = true
            label.rightAnchor.constraint(equalTo: descriptionText.rightAnchor).isActive = true
            
            return label
        }()
        
        view.bringSubviewToFront(descriptionPlaceholder)
        
        saveBarButton = .init(title: "Save", style: .done, target: self, action: #selector(save))
        navigationItem.rightBarButtonItem = saveBarButton
        
        updateWordCount()
        
        
        spinner = UIActivityIndicatorView(style: .gray)
        spinner.startAnimating()
        
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//
//        if Organization.current!.orgDescription != descriptionText.text {
//            let alert = UIAlertController(title: "Caution", message: "You have unsaved changes", preferredStyle: .alert)
//        }
//    }
    
    @objc private func save(disappearing: Bool = false) {
        guard let org = Organization.current else {
            return
        }
        
        navigationItem.rightBarButtonItem = .init(customView: spinner)
        
        let url = URL.with(base: API_BASE_URL, API_Name: "account/UpdateOrgInfo", parameters: ["id": String(org.id)])!
        
        var request = URLRequest(url: url)
        request.addAuthHeader()
        request.httpMethod = "POST"
        
        var body = JSON()
        Organization.current!.orgDescription = descriptionText.text
        body.dictionaryObject?["Description"] = Organization.current!.orgDescription
        
        print(descriptionText.text)
        print(Organization.current!.orgDescription)
        
        request.httpBody = try? body.rawData()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            DispatchQueue.main.async {
                self.navigationItem.rightBarButtonItem = self.saveBarButton
            }
            
            guard error == nil else {
                if !disappearing {
                    DispatchQueue.main.async {
                        internetUnavailableError(vc: self)
                    }
                } else {
                    let alert = UIAlertController(title: "Changes could not uploaded", message: "It seems that some of your changes to your organization's settings could not be automatically uploaded due to lack of internet connection. These changes have been saved locally, but will be lost if you quit and reopen this app while being online, as they will be overwritten.", preferredStyle: .alert)
                    alert.addAction(.init(title: "I Understand", style: .cancel))
                    DispatchQueue.main.async {
                        self.parent?.present(alert, animated: true, completion: nil)
                    }
                }
                return
            }
            
            
            let msg = String(data: data!, encoding: .utf8)
            switch msg {
            case INTERNAL_ERROR:
                DispatchQueue.main.async {
                    serverMaintenanceError(vc: self)
                }
            case "success":
                print("success")
            default:
                print(msg!)
                print("place4")
            }
        }
        task.resume()
    }
        
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if Organization.needsUpload {
            save(disappearing: true)
        }
    }
    
}
    
    


extension DescriptionEditPage: UITextViewDelegate {
    
    private func updateWordCount() {
        descriptionText.textColor = descriptionText.text.count <= descriptionMaxLength ? .darkGray : .red
        charCount.text = "\(descriptionText.text.count) / \(descriptionMaxLength) characters"
    }
    
    //when your input text changed
    func textViewDidChange(_ textView: UITextView) {
        descriptionPlaceholder.isHidden = !textView.text.isEmpty
        updateWordCount()
        scrollToCursor()
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        scrollToCursor()

    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        scrollToCursor()
    }
    
    func scrollToCursor() {
        var range = NSRange()
        range.location = descriptionText.selectedRange.location
        range.length = descriptionText.text.count - descriptionText.selectedRange.location
        let front = NSString(string: descriptionText.text).replacingCharacters(in: range, with: "")
        let imaginary = UITextView(frame: descriptionText.bounds)
        imaginary.font = .systemFont(ofSize: 18)
        imaginary.text = front
        imaginary.textContainer.lineFragmentPadding = 0
        
        let required = descriptionText.frame.origin.y + imaginary.contentSize.height + 10
        let displayHeight = canvas.contentOffset.y + canvas.frame.height - canvas.contentInset.bottom
        if displayHeight < required {
            canvas.setContentOffset(CGPoint(x: 0, y: required - displayHeight + canvas.contentOffset.y), animated: true)
        }
    }
    
    
}
    
extension DescriptionEditPage {
    @objc private func keyboardDidShow(_ notification: Notification) {
        let kbSize = ((notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey]) as! CGRect).size
        canvas.contentInset.bottom = kbSize.height
        canvas.scrollIndicatorInsets.bottom = kbSize.height
    }
    
    @objc private func keyboardDidHide(_ notification: Notification) {
        canvas.contentInset = .zero
        canvas.scrollIndicatorInsets = .zero
    }
}
