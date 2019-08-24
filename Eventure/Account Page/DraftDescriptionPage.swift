//
//  DraftDescriptionPage.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/23.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class DraftDescriptionPage: UIViewController, UITextViewDelegate {
    
    var draftPage: EventDraft!
    
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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
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
            tv.textContainer.lineFragmentPadding = 1
            tv.font = .systemFont(ofSize: 24, weight: .semibold)
            tv.allowsEditingTextAttributes = false
            tv.insertText(draftPage.draft.title)
            tv.delegate = self
            tv.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(tv)
            
            tv.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            tv.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
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
            
            label.leftAnchor.constraint(equalTo: titleText.leftAnchor).isActive = true
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
            line.leftAnchor.constraint(equalTo: titleText.leftAnchor).isActive = true
            line.topAnchor.constraint(equalTo: titleText.bottomAnchor, constant: 5).isActive = true
            
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
            tv.textContainer.lineFragmentPadding = .zero
            tv.font = .systemFont(ofSize: 18)
            tv.textColor = .darkGray
            tv.allowsEditingTextAttributes = false
            tv.insertText(draftPage.draft.eventDescription)
            tv.delegate = self
            tv.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(tv)
            
            tv.leftAnchor.constraint(equalTo: titleText.leftAnchor).isActive = true
            tv.rightAnchor.constraint(equalTo: titleText.rightAnchor).isActive = true
            tv.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 15).isActive = true
            tv.heightAnchor.constraint(greaterThanOrEqualToConstant: 80).isActive = true
            
            return tv
        }()
        
        descriptionPlaceholder = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 18, weight: .medium)
            label.textColor = .init(white: 0.8, alpha: 1)
            label.isHidden = !draftPage.draft.eventDescription.isEmpty
            label.text = "Describe your event here..."
            label.translatesAutoresizingMaskIntoConstraints = false
            canvas.insertSubview(label, belowSubview: descriptionText)
            
            label.leftAnchor.constraint(equalTo: descriptionText.leftAnchor).isActive = true
            label.topAnchor.constraint(equalTo: descriptionText.topAnchor, constant: 8).isActive = true
            
            return label
        }()
        
        previewText = {
            let tv = UITextView()
            tv.isHidden = true
            tv.backgroundColor = nil
            tv.isEditable = false
            tv.isScrollEnabled = false
            tv.textContainerInset = .zero
            tv.textContainer.lineFragmentPadding = 0
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
            
            return tv
        }()
        
        
        if titleText.text.isEmpty {
            titleText.becomeFirstResponder()
        } else if descriptionText.text.isEmpty {
            descriptionText.becomeFirstResponder()
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        draftPage.currentPage = 0
        
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == titleText {
            titlePlaceholder.isHidden = !textView.text.isEmpty
            draftPage.draft.title = textView.text
        } else if textView == descriptionText {
            descriptionPlaceholder.isHidden = !textView.text.isEmpty
            draftPage.draft.eventDescription = textView.text
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (textView == titleText && text == "\n") {
            descriptionText.becomeFirstResponder()
            return false
        }
        return true
    }
    
    @objc private func editButtonPressed() {
        editButton.setTitleColor(MAIN_TINT, for: .normal)
        previewButton.setTitleColor(.darkGray, for: .normal)
        previewText.isHidden = true
        descriptionText.isHidden = false
        textViewDidChange(descriptionText)
    }
    
    @objc private func previewButtonPressed() {
        
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
