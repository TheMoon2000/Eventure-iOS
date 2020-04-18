//
//  Highlights.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/3/12.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SwiftyJSON
import SafariServices
import MarqueeLabel

class Discover: UIViewController {
    
    private var updater: ((UITraitCollection) -> ())?
    private var bannerInfo = [BannerInfo]() {
        didSet {
            bannerPageControl?.numberOfPages = bannerInfo.count
        }
    }
    private var announcementInfo: Announcement? {
        didSet {
            announcementHeightConstraint.constant = announcementInfo == nil ? 0 : 40
            guard announcementInfo != nil else { return }
            announcementLabel.text = announcementInfo!.content.attributedText().string
        }
    }
    
    private var baseView: UIView!
    private var canvas: UIScrollView!
    private var bannerView: UICollectionView!
    private var bannerPageControl: UIPageControl!
    private var failPage: UIView!
    
    private var announcementContainer: UIView!
    private var announcementHeightConstraint: NSLayoutConstraint!
    private var senderLabel: UILabel!
    private var announcementLabel: MarqueeLabel!
    
    private var popularEventsBG: UIView!
    private var popularEventsHeading: UILabel!
    private var popularEventsController: PopularEventsPreview!
    private var popularEventsLabel: UILabel!
    private var popularEventsLoader: UIActivityIndicatorView!
    
    private var loadingBG: UIVisualEffectView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "Discover"
        view.backgroundColor = AppColors.darkerNavBar

        setup()
        
        getAllInfo()
    }
    
    func setup() {
        baseView = {
            let v = UIView()
            v.backgroundColor = AppColors.background
            v.clipsToBounds = true
            v.layer.cornerRadius = 15
            v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            v.layer.shadowOpacity = 0.04
            v.layer.shadowOffset.height = -0.5
            v.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(v)
            
            v.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            v.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            v.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            v.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            return v
        }()
        
        canvas = {
            let sv = UIScrollView()
            sv.contentInset.bottom = MainTabBarController.current.tabBar.bounds.height
            sv.isHidden = true
            sv.alwaysBounceVertical = true
            sv.backgroundColor = AppColors.background
            sv.translatesAutoresizingMaskIntoConstraints = false
            baseView.addSubview(sv)
            
            sv.leftAnchor.constraint(equalTo: baseView.leftAnchor).isActive = true
            sv.rightAnchor.constraint(equalTo: baseView.rightAnchor).isActive = true
            sv.topAnchor.constraint(equalTo: baseView.topAnchor, constant: 8).isActive = true
            sv.bottomAnchor.constraint(equalTo: baseView.bottomAnchor).isActive = true
            
            return sv
        }()
        
        bannerView = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
            cv.backgroundColor = .clear
            cv.showsHorizontalScrollIndicator = false
            cv.register(DiscoverBannerCell.classForCoder(), forCellWithReuseIdentifier: "banner")
            cv.isPagingEnabled = true
            cv.dataSource = self
            cv.delegate = self
            cv.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(cv)
            
            cv.leftAnchor.constraint(equalTo: baseView.leftAnchor).isActive = true
            cv.rightAnchor.constraint(equalTo: baseView.rightAnchor).isActive = true
            cv.topAnchor.constraint(equalTo: canvas.topAnchor, constant: 5).isActive = true
            
            let h = cv.heightAnchor.constraint(equalTo: cv.widthAnchor, multiplier: 0.5)
            h.priority = .defaultHigh
            h.isActive = true
            
            cv.heightAnchor.constraint(lessThanOrEqualToConstant: 220).isActive = true
            
            return cv
        }()
        
        bannerPageControl = {
            let pc = UIPageControl()
            pc.hidesForSinglePage = true
            pc.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(pc)
            
            pc.centerXAnchor.constraint(equalTo: baseView.safeAreaLayoutGuide.centerXAnchor).isActive = true
            pc.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor, constant: -10).isActive = true
            pc.heightAnchor.constraint(equalToConstant: 30).isActive = true
            
            pc.addTarget(self, action: #selector(updatePage), for: .valueChanged)
            
            return pc
        }()
        
        updatePageControlScheme(dark: false)
        
        (failPage, updater) = baseView.addConnectionNotice {
            self.getAllInfo()
            self.popularEventsController.getPopularEvents()
            self.popularEventsLabel.text = ""
            self.popularEventsLoader.startAnimating()
        }
        failPage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        failPage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -MainTabBarController.current.tabBar.bounds.height / 2).isActive = true
        
        
        announcementContainer = {
            let v = UIView()
            v.layer.cornerRadius = 20
            v.clipsToBounds = true
            v.backgroundColor = AppColors.disabled.withAlphaComponent(0.6)
            v.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(v)
            
            v.leftAnchor.constraint(equalTo: baseView.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            v.rightAnchor.constraint(equalTo: baseView.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
            v.topAnchor.constraint(equalTo: bannerView.bottomAnchor, constant: 10).isActive = true
            
            let h = v.heightAnchor.constraint(equalToConstant: 38)
            h.isActive = true
            announcementHeightConstraint = h
            
            v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openAnnouncement)))
            
            return v
        }()
        
        senderLabel = {
            let label = UILabel()
            label.text = " "
            label.font = .appFontMedium(15)
            label.textColor = AppColors.emphasis
            label.translatesAutoresizingMaskIntoConstraints = false
            announcementContainer.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: announcementContainer.leftAnchor, constant: 15).isActive = true
            label.centerYAnchor.constraint(equalTo: announcementContainer.centerYAnchor).isActive = true
            
            return label
        }()
        
        announcementLabel = {
            let label = MarqueeLabel()
            label.fadeLength = 7
            label.animationDelay = 2.0
            label.speed = .rate(40.0)
            label.font = .appFontRegular(15)
            label.isUserInteractionEnabled = false
            label.textColor = AppColors.label
            
            label.translatesAutoresizingMaskIntoConstraints = false
            announcementContainer.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: senderLabel.rightAnchor, constant: 6).isActive = true
            label.rightAnchor.constraint(equalTo: announcementContainer.rightAnchor, constant: -15).isActive = true
            label.centerYAnchor.constraint(equalTo: announcementContainer.centerYAnchor).isActive = true
            
            return label
        }()
        
        popularEventsBG = {
            let bg = UIView()
            bg.backgroundColor = AppColors.tableBG.withAlphaComponent(0.8)
            bg.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(bg)
            
            bg.leftAnchor.constraint(equalTo: baseView.leftAnchor).isActive = true
            bg.rightAnchor.constraint(equalTo: baseView.rightAnchor).isActive = true
            bg.topAnchor.constraint(equalTo: announcementContainer.bottomAnchor, constant: 30).isActive = true
            bg.bottomAnchor.constraint(lessThanOrEqualTo: canvas.bottomAnchor, constant: -20).isActive = true
            
            let topLine = UIView()
            topLine.backgroundColor = AppColors.line
            topLine.translatesAutoresizingMaskIntoConstraints = false
            bg.addSubview(topLine)
            
            topLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
            topLine.leftAnchor.constraint(equalTo: bg.leftAnchor).isActive = true
            topLine.rightAnchor.constraint(equalTo: bg.rightAnchor).isActive = true
            topLine.topAnchor.constraint(equalTo: bg.topAnchor).isActive = true
            
            let bottomLine = UIView()
            bottomLine.backgroundColor = AppColors.line
            bottomLine.translatesAutoresizingMaskIntoConstraints = false
            bg.addSubview(bottomLine)
            
            bottomLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
            bottomLine.leftAnchor.constraint(equalTo: bg.leftAnchor).isActive = true
            bottomLine.rightAnchor.constraint(equalTo: bg.rightAnchor).isActive = true
            bottomLine.bottomAnchor.constraint(equalTo: bg.bottomAnchor).isActive = true
            
            return bg
        }()
        
        popularEventsHeading = {
            let label = UILabel()
            label.text = "Popular Events"
            label.font = .appFontSemibold(20)
            label.textColor = AppColors.label
            label.translatesAutoresizingMaskIntoConstraints = false
            popularEventsBG.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: announcementContainer.leftAnchor).isActive = true
            label.topAnchor.constraint(equalTo: popularEventsBG.topAnchor, constant: 20).isActive = true
            
            return label
        }()
        
        popularEventsController = {
            let cvc = PopularEventsPreview()
            let cv = cvc.collectionView!
            
            cvc.finishedLoadingHandler = { status in
                self.popularEventsLoader.stopAnimating()
                if status == .nothing {
                    self.popularEventsLabel.text = "Oops, you came at an unfortunate time."
                } else if status == .error {
                    self.popularEventsLabel.text = CONNECTION_ERROR
                } else if status == .success {
                    self.popularEventsLabel.text = ""
                }
            }
            
            cv.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(cv)
            
            cv.leftAnchor.constraint(equalTo: baseView.leftAnchor).isActive = true
            cv.rightAnchor.constraint(equalTo: baseView.rightAnchor).isActive = true
            cv.topAnchor.constraint(equalTo: popularEventsHeading.bottomAnchor, constant: 5).isActive = true
            cv.heightAnchor.constraint(equalToConstant: 145).isActive = true
            cv.bottomAnchor.constraint(equalTo: popularEventsBG.bottomAnchor, constant: -20).isActive = true
            
            addChild(cvc)
            cvc.didMove(toParent: self)
            
            return cvc
        }()
        
        popularEventsLoader = {
            let loader = UIActivityIndicatorView()
            loader.hidesWhenStopped = true
            loader.startAnimating()
            loader.color = AppColors.lightControl
            loader.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(loader)
            
            loader.centerXAnchor.constraint(equalTo: popularEventsController.collectionView.centerXAnchor).isActive = true
            loader.centerYAnchor.constraint(equalTo: popularEventsController.collectionView.centerYAnchor).isActive = true
            
            return loader
        }()
        
        popularEventsLabel = {
            let label = UILabel()
            label.textColor = AppColors.prompt
            label.numberOfLines = 5
            label.textAlignment = .center
            label.font = .appFontRegular(16)
            label.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: popularEventsBG.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            label.rightAnchor.constraint(equalTo: popularEventsBG.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive =  true
            label.centerYAnchor.constraint(equalTo: popularEventsController.collectionView.centerYAnchor).isActive = true
            
            return label
        }()
        
        loadingBG = view.addLoader()
    }
    
    func displayErrorScreen() {
        canvas.isHidden = true
        failPage.isHidden = false
        loadingBG.isHidden = true
    }
    
    func updatePageControlScheme(dark: Bool) {
        if dark {
            bannerPageControl.currentPageIndicatorTintColor = UIColor.white.withAlphaComponent(0.8)
            bannerPageControl.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.4)
        } else {
            bannerPageControl.pageIndicatorTintColor = AppColors.control.withAlphaComponent(0.2)
            bannerPageControl.currentPageIndicatorTintColor = AppColors.control.withAlphaComponent(0.6)
        }
    }
    
    private func getAllInfo() {
        
        loadingBG.isHidden = false
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/GetDiscoverInfo",
                           parameters: [:])!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                DispatchQueue.main.async {
                    self.displayErrorScreen()
                }
                return
            }
            
            if let json = try? JSON(data: data!).dictionaryValue {
                DispatchQueue.main.async {
                    self.parseDiscoverInfo(json) // Moved to a separate function because it's too long.
                    self.canvas.isHidden = false
                }
            } else {
                print("WARNING: Malformatted banner info!")
            }
        }
        
        task.resume()
    }
    
    @objc private func openAnnouncement() {
        if let info = announcementInfo {
            let vc = AnnouncementContent(info)
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    /// Read the information returned from the server and update the relevant UI components.
    private func parseDiscoverInfo(_ info: [String: JSON]) {
        if let infoArray = info["Banners"]?.array {
            var tmp = [BannerInfo]()
            for i in infoArray {
                tmp.append(BannerInfo(json: i))
            }
                            
            bannerInfo = tmp
            loadingBG.isHidden = true
            bannerView.reloadData()
        }
        
        if let announcement = info["Announcement"] {
            announcementInfo = Announcement(json: announcement)
            senderLabel.text = self.announcementInfo!.sender + ":"
        }
    }
    
    @objc private func updatePage() {
        bannerView.scrollToItem(at: [0, bannerPageControl.currentPage], at: .centeredHorizontally, animated: true)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            self.bannerView.collectionViewLayout.invalidateLayout()
        })
    }

}


extension Discover: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return .init(title: "Discover")
    }
}

// MARK: - Collection view data source & delegate

extension Discover: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bannerInfo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "banner", for: indexPath) as! DiscoverBannerCell
        
        cell.reset()
        let banner = bannerInfo[indexPath.row]
                
        if let img = banner.image {
            cell.bannerImage.backgroundColor = .clear
            cell.bannerImage.image = img
        } else if banner.loadError {
            cell.errorIcon.isHidden = false
        } else if banner.hasImage == true {
            cell.spinner.startAnimating()
            banner.imageFetchedHandler = { [weak cell] ok in
                cell?.spinner.stopAnimating()
                if ok {
                    cell?.bannerImage.backgroundColor = .clear
                    cell?.bannerImage.image = banner.image
                } else {
                    cell?.errorIcon.isHidden = false
                }
                self.scrollViewDidScroll(self.bannerView)
            }
            banner.fetchImage()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let banner = bannerInfo[indexPath.row]
        let cell = collectionView.cellForItem(at: indexPath) as! DiscoverBannerCell
        
        if banner.isFetching { return }
        
        if banner.loadError {
            cell.reset()
            cell.spinner.startAnimating()
            banner.fetchImage()
        } else if banner.message != nil {
            let vc = BannerArticleContent(info: banner)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        } else if banner.link != nil {
            let vc = SFSafariViewController(url: banner.link!)
            vc.preferredControlTintColor = AppColors.main
            present(vc, animated: true)
        }
    }
    
}

// MARK: - Collection view flow layout delegate

extension Discover: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width,
                      height: min(200, (min(400, view.frame.width - 40) * 0.5)) + 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - Scroll view delegate

extension Discover: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        bannerPageControl.currentPage = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        
        let banner = bannerInfo[bannerPageControl.currentPage]
        if banner.loadError || banner.isFetching {
            updatePageControlScheme(dark: false)
        } else {
            updatePageControlScheme(dark: banner.usesDarkImage)
        }
    }
}
