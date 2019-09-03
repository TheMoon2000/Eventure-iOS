//
//  FilterPageViewController.swift
//  Eventure
//
//  Created by Xiang Li on 9/2/19.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class FilterPageViewController: UIPageViewController {
    
    static let backgroundColor: UIColor = .init(white: 0.94, alpha: 1)
    
    
    var edited = false
    
    var currentPage = -1 {
        didSet {
            navigationItem.title = [
                "1. When?",
                "2. Tags?"
                ][currentPage]
            
            let percentage = Float(currentPage + 1) / Float(pages.count)
            progressIndicator?.setProgress(percentage, animated: true)
            
            if currentPage + 1 < pages.count {
                navigationItem.rightBarButtonItem?.title = "Next"
            } else {
                navigationItem.rightBarButtonItem?.title = "Finish"
            }
        }
    }
    var pages = [UIViewController]()
    
    private var progressIndicator: UIProgressView!
    
    var saveHandler: ((UIAlertAction) -> Void)!
    
    /// Records the progress of the user's current swipe gesture. Negative values indicate a backward swipe.
    var transitionProgress: CGFloat = 0.0 {
        didSet {
            // Update bar percentage
            let barPercentage = (Float(currentPage + 1) + Float(transitionProgress)) / Float(pages.count)
            progressIndicator.setProgress(barPercentage, animated: true)
        }
    }
    
    required init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = FilterPageViewController.backgroundColor
        dataSource = self
        
        // Prepare for transition progress detection
        view.subviews.forEach { ($0 as? UIScrollView)?.delegate = self }
        
        navigationItem.leftBarButtonItem = .init(title: "Close", style: .plain, target: self, action: #selector(exitEditor))
        navigationItem.rightBarButtonItem = .init(title: "Next", style: .done, target: self, action: #selector(flipPage(_:)))
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        
        // Set up pages
        
        let tlPage = FilterDateTableViewController()
        tlPage.filterPage = self
        pages.append(tlPage)
        
        let otherPage = FilterTagViewController()
        otherPage.filterPage = self
        pages.append(otherPage)
        
        
        // Set up progress indicator in the navigation bar.
        progressIndicator = {
            let bar = UIProgressView(progressViewStyle: .bar)
            bar.trackTintColor = .init(white: 0.9, alpha: 1)
            bar.progressTintColor = MAIN_TINT
            bar.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(bar)
            bar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            bar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            bar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            
            return bar
        }()
        
        currentPage = 0
        setViewControllers([tlPage], direction: .forward, animated: false, completion: nil)
    }
    
    @objc func exitEditor() {
        
        self.view.endEditing(true)
        
        guard edited else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
    }
    
    @objc private func flipPage(_ sender: UIBarButtonItem) {
        if sender.title == "Next" {
            if currentPage + 1 < pages.count {
                setViewControllers([pages[currentPage + 1]], direction: .forward, animated: true, completion: nil)
            }
        } else {
            self.dismiss(animated: true, completion: nil)
            NotificationCenter.default.post(name: NSNotification.Name("filter"), object: nil)
            return
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}


// MARK: - Scrolling progress detection

extension FilterPageViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let point = scrollView.contentOffset
        let percentComplete = (point.x - view.frame.size.width) / view.frame.size.width
        transitionProgress = percentComplete
    }
}


// MARK: - Page View Datasource

extension FilterPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if currentPage + 1 == pages.count {
            return nil
        } else {
            return pages[currentPage + 1]
        }
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if currentPage == 0 {
            return nil
        } else {
            return pages[currentPage - 1]
        }
    }
}
