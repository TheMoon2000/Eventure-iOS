//
//  DraftDescriptionPage.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/23.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SafariServices

class DraftDescriptionPage: UIViewController {
    
    var draftPage: EventDraft!
    
    private var descriptionMaxLength = 3000
    
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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        view.tintColor = MAIN_TINT
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        // Setup keyboard show/hide observers
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
        
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
        
        titleText = {
            let tv = UITextView()
            tv.backgroundColor = nil
            tv.isScrollEnabled = false
            tv.autocapitalizationType = .words
            tv.keyboardDismissMode = .onDrag
            tv.returnKeyType = .next
            tv.textContainerInset.top = 12
            tv.textContainerInset.bottom = 12
            tv.textContainer.lineFragmentPadding = 5
            tv.font = .systemFont(ofSize: 24, weight: .semibold)
            tv.allowsEditingTextAttributes = false
            tv.insertText(draftPage.draft.title)
            tv.delegate = self
            tv.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(tv)
            
            tv.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 15).isActive = true
            tv.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -15).isActive = true
            tv.topAnchor.constraint(equalTo: canvas.topAnchor, constant: 22).isActive = true
            tv.heightAnchor.constraint(greaterThanOrEqualToConstant: 30).isActive = true
            
            
            return tv
        }()
        
        titlePlaceholder = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 24, weight: .medium)
            label.textColor = .init(white: 0.8, alpha: 1)
            label.isHidden = !draftPage.draft.title.isEmpty
            label.text = "My Event Title"
            label.translatesAutoresizingMaskIntoConstraints = false
            canvas.insertSubview(label, belowSubview: titleText)
            
            label.leftAnchor.constraint(equalTo: titleText.leftAnchor, constant: 5).isActive = true
            label.centerYAnchor.constraint(equalTo: titleText.centerYAnchor).isActive = true
            
            return label
        }()
        
        
        separatorLine = {
            let line = UIView()
            line.backgroundColor = LINE_TINT
            line.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(line)
            
            line.heightAnchor.constraint(equalToConstant: 1).isActive = true
            line.widthAnchor.constraint(equalToConstant: 80).isActive = true
            line.leftAnchor.constraint(equalTo: titleText.leftAnchor, constant: 5).isActive = true
            line.topAnchor.constraint(equalTo: titleText.bottomAnchor, constant: 3).isActive = true
            
            return line
        }()
        
        editButton = {
            let button = UIButton(type: .system)
            button.setTitleColor(MAIN_TINT, for: .normal)
            button.setTitle("Edit", for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            
            button.addTarget(self, action: #selector(editButtonPressed), for: .touchUpInside)
            
            return button
        }()
        
        previewButton = {
            let button = UIButton(type: .system)
            button.setTitleColor(.darkGray, for: .normal)
            button.setTitle("Preview", for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            
            button.addTarget(self, action: #selector(previewButtonPressed), for: .touchUpInside)
            
            return button
        }()
        
        buttonStack = {
            
            let verticalLine = UIView()
            verticalLine.backgroundColor = LINE_TINT
            verticalLine.translatesAutoresizingMaskIntoConstraints = false
            verticalLine.widthAnchor.constraint(equalToConstant: 1).isActive = true
            verticalLine.heightAnchor.constraint(equalToConstant: 20).isActive = true
            
            let stack = UIStackView(arrangedSubviews: [editButton, verticalLine, previewButton])
            stack.spacing = 20
            stack.alignment = .center
            stack.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(stack)
            
            stack.centerXAnchor.constraint(equalTo: canvas.centerXAnchor).isActive = true
            stack.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: 10).isActive = true
            stack.heightAnchor.constraint(equalToConstant: 40).isActive = true
            
            return stack
        }()
        
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
            tv.insertText(draftPage.draft.eventDescription)
            tv.delegate = self
            tv.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(tv)
            
            tv.leftAnchor.constraint(equalTo: titleText.leftAnchor).isActive = true
            tv.rightAnchor.constraint(equalTo: titleText.rightAnchor).isActive = true
            tv.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 10).isActive = true
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
            label.isHidden = !draftPage.draft.eventDescription.isEmpty
            label.text = "Here, describe your event within \(descriptionMaxLength) characters. Markdown is supported!"
            label.translatesAutoresizingMaskIntoConstraints = false
            canvas.insertSubview(label, belowSubview: descriptionText)
            
            label.leftAnchor.constraint(equalTo: descriptionText.leftAnchor, constant: 5).isActive = true
            label.topAnchor.constraint(equalTo: descriptionText.topAnchor, constant: descriptionText.textContainerInset.top).isActive = true
            label.rightAnchor.constraint(equalTo: descriptionText.rightAnchor).isActive = true
            
            return label
        }()
        
        previewText = {
            let tv = UITextView()
            tv.isHidden = true
            tv.backgroundColor = nil
            tv.isEditable = false
            tv.delegate = self
            tv.isScrollEnabled = false
            tv.textColor = .gray
            tv.font = .systemFont(ofSize: 17)
            tv.dataDetectorTypes = [.link, .phoneNumber]
            tv.linkTextAttributes[.foregroundColor] = LINK_COLOR
            tv.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(tv)
            
            tv.leftAnchor.constraint(equalTo: descriptionText.leftAnchor).isActive = true
            tv.rightAnchor.constraint(equalTo: descriptionText.rightAnchor).isActive = true
            tv.topAnchor.constraint(equalTo: descriptionText.topAnchor).isActive = true
            tv.bottomAnchor.constraint(equalTo: canvas.bottomAnchor, constant: -30).isActive = true
            tv.bottomAnchor.constraint(lessThanOrEqualTo: canvas.bottomAnchor, constant: -30).isActive = true
            
            return tv
        }()
        
        
        if titleText.text.isEmpty {
            titleText.becomeFirstResponder()
        } else if descriptionText.text.isEmpty {
            descriptionText.becomeFirstResponder()
        }
        
        updateWordCount()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        draftPage.currentPage = 0
        
    }
    
    @objc private func editButtonPressed() {
        editButton.setTitleColor(MAIN_TINT, for: .normal)
        previewButton.setTitleColor(.darkGray, for: .normal)
        previewText.isHidden = true
        descriptionText.isHidden = false
        textViewDidChange(descriptionText)
        charCount.isHidden = false
    }
    
    @objc private func previewButtonPressed() {
        
        view.endEditing(true)
        charCount.isHidden = true
        
        if descriptionText.text.isEmpty {
            previewText.text = "No content."
        } else {
            previewText.attributedText = descriptionText.text.attributedText()
        }
        
        editButton.setTitleColor(.darkGray, for: .normal)
        previewButton.setTitleColor(MAIN_TINT, for: .normal)
        descriptionText.isHidden = true
        previewText.isHidden = false
        descriptionPlaceholder.isHidden = true
    }

}

extension DraftDescriptionPage: UITextViewDelegate {
    
    private func updateWordCount() {
        descriptionText.textColor = descriptionText.text.count <= descriptionMaxLength ? .darkGray : .red
        
        charCount.text = "\(descriptionText.text.count) / \(descriptionMaxLength) characters"
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == titleText {
            titlePlaceholder.isHidden = !textView.text.isEmpty
            draftPage.draft.title = textView.text
            draftPage.edited = true
        } else if textView == descriptionText {
            descriptionPlaceholder.isHidden = !textView.text.isEmpty
            draftPage.draft.eventDescription = textView.text
            draftPage.edited = true
            
            updateWordCount()
            scrollToCursor()
        }
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if textView == descriptionText {
            scrollToCursor()
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == descriptionText {
            scrollToCursor()
        }
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
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (textView == titleText && text == "\n") {
            descriptionText.becomeFirstResponder()
            return false
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let vc = SFSafariViewController(url: URL)
        draftPage.present(vc, animated: true)
        return false
    }

}


extension DraftDescriptionPage {
    
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
