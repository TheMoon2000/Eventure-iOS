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
    
    private var descriptionMaxLength = 1000
    private var canvas: UIScrollView!
    private var buttonStack: UIStackView!
    private var editButton: UIButton!
    private var previewButton: UIButton!
    private var descriptionText: UITextView!
    private var descriptionPlaceholder: UILabel!
    private var previewText: UITextView!
    private var charCount: UILabel!
    private var spinner: UIActivityIndicatorView!
    private var spinnerBarItem: UIBarButtonItem!
    private var saveBarButton: UIBarButtonItem!
    
    var edited = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = AppColors.background
        view.tintColor = AppColors.main
        
        title = "Organization Description"
        
        saveBarButton = .init(title: "Save", style: .done, target: self, action: #selector(save))
        navigationItem.rightBarButtonItem = saveBarButton
        
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = .init(title: "Back", style: .plain, target: self, action: #selector(closeEditor))
        
        // Check
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        canvas = {
            let sv = UIScrollView()
            sv.alwaysBounceVertical = true
            sv.addGestureRecognizer(tap)
            sv.keyboardDismissMode = .interactive
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
        
        editButton = {
            let button = UIButton(type: .system)
            button.setTitleColor(AppColors.main, for: .normal)
            button.setTitle("Edit", for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            
            button.addTarget(self, action: #selector(editButtonPressed), for: .touchUpInside)
            
            return button
        }()
        
        previewButton = {
            let button = UIButton(type: .system)
            button.setTitleColor(AppColors.control, for: .normal)
            button.setTitle("Preview", for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            
            button.addTarget(self, action: #selector(previewButtonPressed), for: .touchUpInside)
            
            return button
        }()
        
        buttonStack = {
            let verticalLine = UIView()
            verticalLine.backgroundColor = AppColors.line
            verticalLine.translatesAutoresizingMaskIntoConstraints = false
            verticalLine.widthAnchor.constraint(equalToConstant: 1).isActive = true
            verticalLine.heightAnchor.constraint(equalToConstant: 20).isActive = true
            
            let stack = UIStackView(arrangedSubviews: [editButton, verticalLine, previewButton])
            stack.spacing = 20
            stack.alignment = .center
            stack.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(stack)
            
            stack.centerXAnchor.constraint(equalTo: canvas.centerXAnchor).isActive = true
            stack.topAnchor.constraint(equalTo: canvas.topAnchor, constant: 15).isActive = true
            stack.heightAnchor.constraint(equalToConstant: 40).isActive = true
            
            return stack
        }()
        
        descriptionText = {
            let tv = UITextView()
            tv.isScrollEnabled = false
            tv.textColor = AppColors.plainText
            
            textViewFormatter(tv: tv)
            
            tv.insertText(Organization.current!.orgDescription)
            tv.delegate = self
            tv.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(tv)
            
            tv.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            tv.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
            tv.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 10).isActive = true
            tv.heightAnchor.constraint(greaterThanOrEqualToConstant: 200).isActive = true
            
            return tv
        }()
        
        descriptionPlaceholder = {
            let label = UILabel()
            label.numberOfLines = 0
            label.font = .systemFont(ofSize: 18, weight: .medium)
            label.textColor = AppColors.placeholder
            label.isHidden = !Organization.current!.orgDescription.isEmpty //Fix Me
            label.text = "Please give a brief description of your club within \(descriptionMaxLength) characters."
            label.translatesAutoresizingMaskIntoConstraints = false
            canvas.insertSubview(label, belowSubview: descriptionText)
            
            label.leftAnchor.constraint(equalTo: descriptionText.leftAnchor, constant: 5).isActive = true
            label.topAnchor.constraint(equalTo: descriptionText.topAnchor, constant: descriptionText.textContainerInset.top).isActive = true
            label.rightAnchor.constraint(equalTo: descriptionText.rightAnchor).isActive = true
            
            return label
        }()
        
        charCount = {
            let label = UILabel()
            label.textColor = .gray
            label.font = .systemFont(ofSize: 15)
            label.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: canvas.leftAnchor, constant: 20).isActive = true
            label.topAnchor.constraint(equalTo: descriptionText.bottomAnchor, constant: 20).isActive = true
            label.bottomAnchor.constraint(equalTo: canvas.bottomAnchor, constant: -25).isActive = true
            
            return label
        }()
        
        previewText = {
            let tv = UITextView()
            tv.isHidden = true
            tv.backgroundColor = nil
            tv.isEditable = false
            tv.isScrollEnabled = false
            tv.textColor = AppColors.plainText
            tv.font = .systemFont(ofSize: 17)
            tv.dataDetectorTypes = [.link, .phoneNumber]
            tv.linkTextAttributes[.foregroundColor] = AppColors.link
            tv.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(tv)
            
            tv.leftAnchor.constraint(equalTo: descriptionText.leftAnchor).isActive = true
            tv.rightAnchor.constraint(equalTo: descriptionText.rightAnchor).isActive = true
            tv.topAnchor.constraint(equalTo: descriptionText.topAnchor).isActive = true
            tv.bottomAnchor.constraint(equalTo: canvas.bottomAnchor, constant: -30).isActive = true
            tv.bottomAnchor.constraint(lessThanOrEqualTo: canvas.bottomAnchor, constant: -30).isActive = true
            
            return tv
        }()
        
        editButtonPressed()
        updateWordCount()
        
        spinner = UIActivityIndicatorView(style: .gray)
        spinner.startAnimating()
        spinnerBarItem = .init(customView: spinner)
    }
    
    func textViewFormatter(tv: UITextView) {
        tv.backgroundColor = nil
        tv.font = .systemFont(ofSize: 18)
        tv.allowsEditingTextAttributes = false
        
        let pStyle = NSMutableParagraphStyle()
        pStyle.lineSpacing = 2
        tv.typingAttributes[NSAttributedString.Key.paragraphStyle] = pStyle
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func closeEditor() {
        view.endEditing(true)
        if edited {
            let alert = UIAlertController(title: "Caution", message: "You have unsaved changes", preferredStyle: .alert)
            alert.addAction(.init(title: "Save", style: .default, handler: { _ in
                self.saveWithHandler {
                    self.navigationController?.popViewController(animated: true)
                }
            }))
            alert.addAction(.init(title: "Discard", style: .destructive, handler: {
                _ in
                self.navigationController?.popViewController(animated: true)
            }))
            alert.addAction(.init(title: "Cancel", style: .cancel))
            self.present(alert, animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//
//        if Organization.current!.orgDescription != descriptionText.text {
//            let alert = UIAlertController(title: "Caution", message: "You have unsaved changes", preferredStyle: .alert)
//        }
//    }
    
    @objc private func editButtonPressed() {
        editButton.setTitleColor(AppColors.main, for: .normal)
        editButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        previewButton.setTitleColor(AppColors.control, for: .normal)
        previewButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        previewText.isHidden = true
        descriptionText.isHidden = false
        charCount.isHidden = false
    }
    
    @objc private func previewButtonPressed() {
        
        view.endEditing(true)
        charCount.isHidden = true
        
        if descriptionText.text.isEmpty {
            previewText.text = "No content."
        } else if #available(iOS 12.0, *), traitCollection.userInterfaceStyle == .dark {
            previewText.attributedText = descriptionText.text.attributedText(style: PLAIN_DARK)
        } else {
            previewText.attributedText = descriptionText.text.attributedText()
        }
        
        editButton.setTitleColor(AppColors.control, for: .normal)
        editButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        previewButton.setTitleColor(AppColors.main, for: .normal)
        previewButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        descriptionText.isHidden = true
        previewText.isHidden = false
        descriptionPlaceholder.isHidden = true
    }
    
    @objc private func saveWithHandler(_ handler: (() -> ())?) {
        guard let org = Organization.current else {
            return
        }
        
        org.orgDescription = descriptionText.text
        navigationItem.rightBarButtonItem = spinnerBarItem
            
        org.pushSettings(.orgDescription) { success in
            self.edited = false
            self.navigationItem.rightBarButtonItem = self.saveBarButton
            if !success {
                let alert = UIAlertController(title: "Changes could not uploaded", message: "It seems that some of your changes to your organization's settings could not be automatically, either due to poor internet connection or an unknown server error. These changes have been saved locally, but will be lost if you quit and reopen this app while being online, as they will be overwritten. If this is a recurring problem, please email us at support@eventure-app.com.", preferredStyle: .alert)
                alert.addAction(.init(title: "I Understand", style: .cancel))
                self.present(alert, animated: true, completion: nil)
            } else {
                handler?()
            }
        }
    }
    
    @objc private func save() {
        saveWithHandler(nil)
    }
}
    
    


extension DescriptionEditPage: UITextViewDelegate {
    
    private func updateWordCount() {
        descriptionText.textColor = descriptionText.text.count <= descriptionMaxLength ? AppColors.plainText : .red
        charCount.text = "\(descriptionText.text.count) / \(descriptionMaxLength) characters"
    }
    
    //when your input text changed
    func textViewDidChange(_ textView: UITextView) {
        descriptionPlaceholder.isHidden = !textView.text.isEmpty
        updateWordCount()
        scrollToCursor()
        edited = true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        DispatchQueue.main.async {
            self.scrollToCursor()
        }
    }
    
    func scrollToCursor() {
        var range = NSRange()
        range.location = descriptionText.selectedRange.location
        range.length = descriptionText.text.count -  descriptionText.selectedRange.upperBound
        let front = NSString(string: descriptionText.text).replacingCharacters(in: range, with: "")
        let imaginary = UITextView(frame: descriptionText.bounds)
        textViewFormatter(tv: imaginary)
        imaginary.attributedText = NSAttributedString(string: front, attributes: imaginary.typingAttributes)
        
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
