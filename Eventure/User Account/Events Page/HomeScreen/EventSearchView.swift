//
//  EventSearchView.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/3/12.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import UIKit

class EventSearchView: UIViewController {
    
    private var emptyLabel: UILabel!
    private var loadingBG: UIView!
    private var searchBar: UISearchBar!
    private var cancelButton: UIButton!
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        transitioningDelegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Search"
        
        view.backgroundColor = AppColors.tableBG

        loadingBG = view.addLoader()
        loadingBG.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        loadingBG.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        emptyLabel = {
            let label = UILabel()
            label.textColor = .gray
            label.text = "TODO: Set up search controller"
            label.font = .appFontRegular(17)
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
            
            return label
        }()
        
        cancelButton = {
            let button = UIButton(type: .system)
            button.setTitle("Cancel", for: .normal)
            button.titleLabel?.font = .appFontMedium(17)
            button.tintColor = AppColors.main
            button.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(button)
            
            button.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -15).isActive = true
            
            button.addTarget(self, action: #selector(cancelSearch), for: .touchUpInside)
            
            return button
        }()

        searchBar = {
            let sb = UISearchBar()
            sb.placeholder = "Search Events..."
            sb.backgroundImage = UIImage()
            sb.autocorrectionType = .no
            sb.tintColor = AppColors.main
            sb.backgroundColor = .clear
            sb.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(sb)
            
            sb.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 5).isActive = true
            sb.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
            sb.centerYAnchor.constraint(equalTo: cancelButton.centerYAnchor).isActive = true
            sb.heightAnchor.constraint(equalToConstant: 36).isActive = true
            sb.rightAnchor.constraint(equalTo: cancelButton.leftAnchor, constant: -5).isActive = true
            
            return sb
        }()
        
        searchBar.becomeFirstResponder()
    }
    
    @objc private func cancelSearch() {
        dismiss(animated: true)
    }
    
    // MARK - Animations.
    // Details: https://developer.apple.com/library/archive/featuredarticles/ViewControllerPGforiPhoneOS/CustomizingtheTransitionAnimations.html
    
    class PresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
        
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return 0.35
        }
        
        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            let container = transitionContext.containerView
            let toView = transitionContext.view(forKey: .to)!
            
            let finalFrame = transitionContext.finalFrame(for: transitionContext.viewController(forKey: .to)!)
            
            toView.layer.cornerRadius = 30
            toView.frame.size.height = 70
            toView.layer.opacity = 0.2
            
            container.addSubview(toView)
            
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut, animations: {
                toView.layer.cornerRadius = 0
                toView.frame.size.height = finalFrame.height
                toView.layer.opacity = 1.0
            }, completion: { _ in
                transitionContext.completeTransition(true)
            })
        }
    }
    
    class DismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
        
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return 0.35
        }
        
        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            let container = transitionContext.containerView
            let fromView = transitionContext.view(forKey: .from)!
                        
            fromView.layer.cornerRadius = 0
            fromView.layer.opacity = 1.0
            fromView.endEditing(true)
            (transitionContext.viewController(forKey: .from) as? EventSearchView)?.emptyLabel.isHidden = true
            
            container.addSubview(fromView)
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                fromView.layer.cornerRadius = 30
                fromView.frame.size.height = 70
                fromView.layer.opacity = 0.0
            }, completion: { _ in
                transitionContext.completeTransition(true)
            })
        }
    }
    
}

extension EventSearchView: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentAnimator()
        
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
}
