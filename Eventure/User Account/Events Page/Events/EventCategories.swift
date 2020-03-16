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
    private var categoryView: UICollectionView!
    private var emptyLabel: UILabel!
    private var loadingBG: UIVisualEffectView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = AppColors.canvas

        // Do any additional setup after loading the view.
        setup()
        loadTags()
    }
    
    private func setup() {
        categoryView = {
            let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
            cv.backgroundColor = .clear
            cv.register(CategoryCell.classForCoder(), forCellWithReuseIdentifier: "category")
            cv.contentInset.bottom = MainTabBarController.current.tabBar.bounds.height
            cv.scrollIndicatorInsets.bottom = cv.contentInset.bottom
            cv.refreshControl = UIRefreshControl()
            cv.refreshControl?.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
            cv.delegate = self
            cv.dataSource = self
            cv.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(cv)
            
            cv.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
            cv.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
            cv.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            cv.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            return cv
        }()
        
        emptyLabel = {
            let label = UILabel()
            label.textColor = .gray
            label.font = .appFontRegular(17)
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
            
            return label
        }()
        
        loadingBG = view.addLoader()
        loadingBG.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        loadingBG.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
    }
    
    
    @objc private func pullToRefresh() {
        loadTags(true)
    }
    
    private func loadTags(_ pulled: Bool = false) {
        
        // By default, we can directly use the cache.
        if !pulled && !LocalStorage.tags.isEmpty {
            self.tags = LocalStorage.tags.values.sorted { $0.name < $1.name }
            self.categoryView.reloadSections(IndexSet(arrayLiteral: 0))
            print("Loaded \(tags.count) tags from cache")
        } else {
            loadingBG.isHidden = false
            
            LocalStorage.updateTags { status in
                self.loadingBG.isHidden = true
                self.categoryView.refreshControl?.endRefreshing()
                
                if status == 0 {
                    self.tags = LocalStorage.tags.values.sorted { $0.name < $1.name }
                    self.categoryView.reloadSections(IndexSet(arrayLiteral: 0))
                } else if status == -1 {
                    internetUnavailableError(vc: self) {
                        self.emptyLabel.text = CONNECTION_ERROR
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
        
        categoryView.collectionViewLayout.invalidateLayout()
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
        
        cell.prepareForReuse()
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
        navigationController?.pushViewController(EventsInCategory(category: tags[indexPath.row]),
                                                 animated: true)
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
        return UIEdgeInsets(top: equalSpacing,
                            left: equalSpacing,
                            bottom: equalSpacing,
                            right: equalSpacing)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { context in
            self.categoryView.collectionViewLayout.invalidateLayout()
        }, completion: nil)
    }
    
}
