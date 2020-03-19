//
//  Highlights.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/3/12.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import UIKit

class FloatingBannerUITest: UIViewController {
    
    private var canvas: UIScrollView!
    private var topView: UIView!
    private var circle: UIView!
    private var banner: UIView!
    private var placeholder: UIScrollView!
    private var randomStuff: UIScrollView!
        
    private var pulled = false
    private var isSet = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "Floating banner UI test"
        view.backgroundColor = AppColors.background
        
        canvas = {
            let sv = UIScrollView()
            sv.backgroundColor = AppColors.canvas
            sv.delegate = self
            sv.contentInset.top = -150
            sv.alwaysBounceVertical = true
            sv.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(sv)
            
            sv.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            sv.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            sv.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            sv.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            return sv
        }()
        
        topView = {
            let v = UIView()
            v.backgroundColor = AppColors.lightGray
            v.clipsToBounds = true
            v.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(v)
            
            v.leftAnchor.constraint(equalTo: canvas.leftAnchor).isActive = true
            v.rightAnchor.constraint(equalTo: canvas.rightAnchor).isActive = true
            v.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            v.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            let b = v.bottomAnchor.constraint(equalTo: canvas.topAnchor, constant: 150)
            b.priority = .defaultHigh
            b.isActive = true
            
            return v
        }()
        
        circle = {
            let v = UIView()
            v.backgroundColor = AppColors.emphasis
            v.translatesAutoresizingMaskIntoConstraints = false
            topView.addSubview(v)
            
            v.widthAnchor.constraint(equalTo: topView.heightAnchor, multiplier: 0.4).isActive = true
            
            v.heightAnchor.constraint(equalTo: v.widthAnchor).isActive = true
            
            let x = v.centerXAnchor.constraint(equalTo: topView.centerXAnchor)
//            circleConstraints.append(x)
            x.isActive = true
            
            let y = v.centerYAnchor.constraint(equalTo: topView.centerYAnchor)
//            circleConstraints.append(y)
            y.isActive = true
            
            return v
        }()
        
        placeholder = {
            let tv = UITextView()
            tv.attributedText = SAMPLE_TEXT.attributedText()
            tv.isScrollEnabled = false
            tv.contentInset.top = 20
            tv.contentInset.bottom = 20
            tv.backgroundColor = AppColors.background
            tv.isEditable = false
            tv.textContainerInset = .init(top: 20, left: 20, bottom: 20, right: 20)
            tv.linkTextAttributes[.foregroundColor] = AppColors.link
            tv.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(tv)
            
            tv.leftAnchor.constraint(equalTo: canvas.safeAreaLayoutGuide.leftAnchor).isActive = true
            tv.rightAnchor.constraint(equalTo: canvas.safeAreaLayoutGuide.rightAnchor).isActive = true
            tv.topAnchor.constraint(equalTo: canvas.topAnchor, constant: 150).isActive = true
            
            return tv
        }()
        
        banner = {
            let b = UIView()
            b.backgroundColor = .lightGray
            b.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(b)
            
            b.leftAnchor.constraint(equalTo: canvas.leftAnchor).isActive = true
            b.rightAnchor.constraint(equalTo: canvas.rightAnchor).isActive = true
            b.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            b.topAnchor.constraint(greaterThanOrEqualTo: placeholder.bottomAnchor).isActive = true
            b.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor).isActive = true
            b.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            return b
        }()
        
        let label = UILabel()
        label.text = "Floating Banner"
        label.translatesAutoresizingMaskIntoConstraints = false
        banner.addSubview(label)
        
        label.centerXAnchor.constraint(equalTo: banner.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: banner.centerYAnchor).isActive = true
        
        
        randomStuff = {
            let tv = UITextView()
            tv.attributedText = SAMPLE_TEXT.attributedText()
            tv.isScrollEnabled = false
            tv.contentInset.top = 20
            tv.contentInset.bottom = 20
            tv.textContainerInset = .init(top: 20, left: 20, bottom: 20, right: 20)
            tv.backgroundColor = AppColors.background
            tv.isEditable = false
            tv.linkTextAttributes[.foregroundColor] = AppColors.link
            tv.translatesAutoresizingMaskIntoConstraints = false
            canvas.insertSubview(tv, belowSubview: banner)
            
            tv.leftAnchor.constraint(equalTo: canvas.safeAreaLayoutGuide.leftAnchor).isActive = true
            tv.rightAnchor.constraint(equalTo: canvas.safeAreaLayoutGuide.rightAnchor).isActive = true
            tv.topAnchor.constraint(equalTo: placeholder.bottomAnchor, constant: 50).isActive = true
            tv.bottomAnchor.constraint(equalTo: canvas.bottomAnchor).isActive = true
            
            return tv
        }()
        
        canvas.layoutIfNeeded()
        circle.layer.cornerRadius = circle.bounds.width / 2
    }

}

extension FloatingBannerUITest: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard circle != nil else { return }
                        
        if scrollView.contentOffset.y <= 15 {
            if !pulled {
                pulled = true
                isSet = false
                UISelectionFeedbackGenerator().selectionChanged()
                
                let scale = self.topView.frame.width / self.circle.frame.width * 1.8
                
                UIView.transition(with: self.circle, duration: 0.25, options: .curveEaseOut, animations: {
                    self.circle.transform = CGAffineTransform(scaleX: scale, y: scale)
                })
                                
            }
        } else {
            
            if pulled {
                pulled = false
                isSet = false
            }
            
            UIView.transition(with: self.circle, duration: 0.2, options: .curveEaseOut, animations: {
                self.circle.transform = .identity
            })
            
            circle.layer.cornerRadius = circle.bounds.width / 2
        }
        
        /*
        if scrollView.contentOffset.y < 0 {
            scrollView.contentOffset.y = 0
        }*/
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if topView.frame.height < 135 && !isSet {
            pulled = false
            
            if topView.frame.height > 0 {
                scrollView.setContentOffset(CGPoint(x: 0, y: 150), animated: true)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                scrollView.contentInset.top = -150
            }

        } else if !isSet && topView.frame.height >= 135 {
            pulled = true
            UIView.transition(with: scrollView, duration: 0.2, options: .curveEaseOut, animations: {
                scrollView.contentInset.top = 0
            })
        }
    }
}
