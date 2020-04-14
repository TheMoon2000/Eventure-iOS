//
//  EventCategories.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/3/15.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class EventCategories: UIViewController {
    
    private var tags = [Tag]()
    private var canvas: UIView!
    private var fadingContainer: UIView!
    private var categoryView: UICollectionView!
    private var emptyLabel: UILabel!
    private var loadingBG: UIVisualEffectView!
    private var fallback: UIView!
    private var updater: ((UITraitCollection) -> ())?
    
    private var popularEventsHeading: UILabel!
    private var popularEventsView: PopularEventsPreview!
    
    private var gradientLayer: CAGradientLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = AppColors.darkerNavBar

        // Do any additional setup after loading the view.
        setup()
        loadTags()
    }
    
    private func setup() {
        
        canvas = {
            let canvas = UIView()
            canvas.backgroundColor = AppColors.background
            canvas.clipsToBounds = true
            canvas.layer.cornerRadius = 15
            canvas.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            canvas.layer.shadowOpacity = 0.04
            canvas.layer.shadowOffset.height = -0.5
            
            canvas.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(canvas)
            
            canvas.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            canvas.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            canvas.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            canvas.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            return canvas
        }()
        
        (fallback, updater) = canvas.addConnectionNotice {
            self.loadTags(true)
        }
        fallback.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        fallback.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -MainTabBarController.current.tabBar.bounds.height / 2).isActive = true
                
        fadingContainer = {
            let v = UIView()
            v.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(v)
            
            v.leftAnchor.constraint(equalTo: canvas.safeAreaLayoutGuide.leftAnchor).isActive = true
            v.rightAnchor.constraint(equalTo: canvas.safeAreaLayoutGuide.rightAnchor).isActive = true
            v.topAnchor.constraint(equalTo: canvas.topAnchor).isActive = true
            v.bottomAnchor.constraint(equalTo: canvas.bottomAnchor).isActive = true
            
            return v
        }()
        
        categoryView = {
            let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
            cv.backgroundColor = .clear
            cv.register(CategoryCell.classForCoder(), forCellWithReuseIdentifier: "category")
            cv.scrollIndicatorInsets.bottom = cv.contentInset.bottom
            cv.contentInset.top = 8
            cv.contentInset.bottom = MainTabBarController.current.tabBar.bounds.height
            cv.scrollIndicatorInsets.top = 8
            cv.refreshControl = UIRefreshControl()
            cv.refreshControl?.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
            cv.delegate = self
            cv.dataSource = self
            cv.translatesAutoresizingMaskIntoConstraints = false
            fadingContainer.addSubview(cv)
            
            cv.leftAnchor.constraint(equalTo: fadingContainer.safeAreaLayoutGuide.leftAnchor).isActive = true
            cv.rightAnchor.constraint(equalTo: fadingContainer.safeAreaLayoutGuide.rightAnchor).isActive = true
            cv.topAnchor.constraint(equalTo: fadingContainer.topAnchor).isActive = true
            cv.bottomAnchor.constraint(equalTo: fadingContainer.bottomAnchor).isActive = true
            
            return cv
        }()
        
        gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor, AppColors.background.cgColor, AppColors.background.cgColor]
        gradientLayer.needsDisplayOnBoundsChange = true
        fadingContainer.layer.mask = gradientLayer
        
        DispatchQueue.main.async {
            self.gradientLayer.frame = self.categoryView.frame
            self.gradientLayer.locations = [
                NSNumber(value: Double(1.0 / self.fadingContainer.frame.height)),
                NSNumber(value: Double(5.0 / self.fadingContainer.frame.height)),
                1.0]
        }
        
        emptyLabel = {
            let label = UILabel()
            label.textColor = .gray
            label.font = .appFontRegular(17)
            label.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
            
            return label
        }()
        
        loadingBG = canvas.addLoader()
        loadingBG.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        loadingBG.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        updater?(traitCollection)
    }
    
    
    @objc private func pullToRefresh() {
        loadTags(true)
    }
    
    private func loadTags(_ pulled: Bool = false) {
                
        // By default, we can directly use the cache.
        if !pulled && !LocalStorage.tags.isEmpty {
            self.tags = LocalStorage.tags.values.sorted { $0.name < $1.name }
            self.categoryView.reloadSections(IndexSet(arrayLiteral: 0))
        } else {
            loadingBG.isHidden = false
            
            LocalStorage.updateTags { status in
                self.loadingBG.isHidden = true
                self.categoryView.refreshControl?.endRefreshing()
                self.categoryView.isHidden = false

                if status == 0 {
                    self.tags = LocalStorage.tags.values.sorted { $0.name < $1.name }
                    self.categoryView.reloadSections(IndexSet(arrayLiteral: 0))
                } else if status == -1 {
                    self.fallback.isHidden = false
                    self.emptyLabel.text = ""
                    if pulled {
                        LocalStorage.tags.removeAll()
                        self.categoryView.isHidden = true
                    }
                } else if status == -2 {
                    serverMaintenanceError(vc: self) {
                        self.emptyLabel.text = SERVER_ERROR
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async {
            self.categoryView.collectionViewLayout.invalidateLayout()
        }
    }
}

extension EventCategories: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return .init(title: "Categories")
    }
}


// MARK: - Collection view data source

extension EventCategories: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "category", for: indexPath) as! CategoryCell
        
        cell.initTime = Date()
        cell.logoImage = nil
        
        let tag = tags[indexPath.row]
        cell.categoryLabel.text = tag.name
        cell.updateLogo(tag: tag)
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

// MARK: - Collection view delegate

extension EventCategories: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = EventsInCategory(category: tags[indexPath.row])
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension EventCategories: UICollectionViewDelegateFlowLayout {
    
    var usableWidth: CGFloat {
        return categoryView.safeAreaLayoutGuide.layoutFrame.width
    }
    
    var tagWidth: CGFloat {
        if usableWidth < 145 {
            return usableWidth - 20
        } else {
            let numFit = floor(usableWidth / 145)
            return ((usableWidth - 10) / numFit) - 10
        }
    }
    
    var equalSpacing: CGFloat {
        let rowCount = floor(usableWidth / tagWidth)
        let extraSpace = usableWidth - rowCount * tagWidth
        
        return (extraSpace - 1) / (rowCount + 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: tagWidth, height: tagWidth)
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return equalSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return equalSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: max(0, equalSpacing - 8),
                            left: equalSpacing,
                            bottom: equalSpacing,
                            right: equalSpacing)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { context in
            self.categoryView.collectionViewLayout.invalidateLayout()
            self.gradientLayer.frame = self.categoryView.frame
        }, completion: nil)
    }
    
}
