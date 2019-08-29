//
//  ImageFullScreenPage.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/28.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class ImageFullScreenPage: UIViewController {
    
    private var canvas: UIScrollView!
    private var imageView: UIImageView!
    
    required init(image: UIImage) {
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = .white
        
        canvas = {
            let sv = UIScrollView()
            sv.minimumZoomScale = 1.0
            sv.maximumZoomScale = 3.2
            sv.delegate = self
            sv.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(sv)
            
            sv.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            sv.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            sv.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            sv.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            sv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(canvasTapped)))
            
            return sv
        }()
        
        canvas.layoutIfNeeded()
        
        imageView = {
            let iv = UIImageView(image: image)
            iv.frame.size.width = min(canvas.frame.width, canvas.frame.height)
            iv.frame.size.height = iv.frame.size.width
            iv.contentMode = .scaleAspectFit
            iv.center = canvas.center
            canvas.addSubview(iv)
            
            return iv
        }()
        
        scrollViewDidZoom(canvas)
    }
    
    @objc private func canvasTapped() {
        self.dismiss(animated: false, completion: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { context in
            self.scrollViewDidZoom(self.canvas)
        }, completion: nil)
    }

}


extension ImageFullScreenPage: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = max((scrollView.frame.width - scrollView.contentSize.width) / 2, 0)
        let offsetY = max((scrollView.frame.height - scrollView.contentSize.height) / 2, 0)
        // adjust the center of image view
        imageView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
    }
}
