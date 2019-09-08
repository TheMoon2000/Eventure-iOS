//
//  TagPickerView.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/7/31.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class TagPickerView: UIViewController {
    
    var loginVC: LoginViewController!
    
    private var topBanner: UIVisualEffectView!
    private var titleLabel: UILabel!
    private var subtitleLabel: UILabel!
    private var bottomBanner: UIVisualEffectView!
    private var continueButton: UIButton!
    
    var spinner: UIActivityIndicatorView!
    var spinnerLabel: UILabel!
    
    var customContinueMethod: ((TagPickerView) -> ())?
    var customTitle: String?
    var customSubtitle: String?
    var customButtonTitle: String?
    var minPicks = 1
    var maxPicks: Int?
    
    var tagPicker: UICollectionView!
    private var tags = [String]()
    var selectedTags = Set<String>() {
        didSet {
            if tags.isEmpty { return }
            updateUI()
        }
    }
    
    var errorHandler: (() -> ())?
    
    var customDisappearHandler: ((Set<String>) -> ())?
    
    private func updateUI() {
        if minPicks > selectedTags.count || maxPicks != nil && maxPicks! < selectedTags.count {
            continueButton.isUserInteractionEnabled = false
            UIView.animate(withDuration: 0.15) {
                self.continueButton.backgroundColor = MAIN_DISABLED
            }
        } else {
            continueButton.isUserInteractionEnabled = true
            UIView.animate(withDuration: 0.15) {
                self.continueButton.backgroundColor = MAIN_TINT
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.errorHandler = {
            self.dismiss(animated: true, completion: nil)
        }
        
        title = "Tag Picker"
        view.backgroundColor = .init(white: 0.95, alpha: 1)
        
        topBanner = {
            let banner = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
            banner.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(banner)
            
            banner.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            banner.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            banner.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            
            // Banner content
            
            titleLabel = {
                let label = UILabel()
                label.text = customTitle ?? "What Interests You?"
                label.textAlignment = .center
                label.numberOfLines = 0
                if customSubtitle == "" {
                    label.font = .systemFont(ofSize: 23, weight: .medium)
                } else {
                    label.font = .systemFont(ofSize: 25, weight: .semibold)
                }
                label.translatesAutoresizingMaskIntoConstraints = false
                banner.contentView.addSubview(label)
                
                label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
                label.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -30).isActive = true
                label.topAnchor.constraint(equalTo: banner.safeAreaLayoutGuide.topAnchor,
                                           constant: 30).isActive = true
                
                return label
            }()
            
            subtitleLabel = {
                let label = UILabel()
                label.text = customSubtitle ?? "Pick at least one. The more the better!"
                label.textAlignment = .center
                label.numberOfLines = 0
                label.font = .systemFont(ofSize: 16)
                label.translatesAutoresizingMaskIntoConstraints = false
                banner.contentView.addSubview(label)
                
                label.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
                label.leftAnchor.constraint(equalTo: titleLabel.leftAnchor).isActive = true
                label.rightAnchor.constraint(equalTo: titleLabel.rightAnchor).isActive = true
                
                if label.text!.isEmpty {
                    label.bottomAnchor.constraint(equalTo: banner.bottomAnchor, constant: -20).isActive = true
                } else {
                    label.bottomAnchor.constraint(equalTo: banner.bottomAnchor, constant: -30).isActive = true
                }
                
                return label
            }()
            
            banner.layoutIfNeeded()
            
            return banner
        }()
        

        tagPicker = {
            let picker = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
            picker.backgroundColor = .clear
            picker.register(TagCell.classForCoder(), forCellWithReuseIdentifier: "tag")
            picker.allowsMultipleSelection = true
            picker.contentInset.top = topBanner.frame.height
            picker.scrollIndicatorInsets.top = topBanner.frame.height
            picker.contentInset.bottom = 75 // The arbitrary height of bottom banner
            picker.scrollIndicatorInsets.bottom = 75
            picker.contentInsetAdjustmentBehavior = .always
            picker.delegate = self
            picker.dataSource = self
            picker.translatesAutoresizingMaskIntoConstraints = false
            view.insertSubview(picker, belowSubview: topBanner)
            
            picker.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
            picker.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
            picker.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            picker.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            return picker
        }()
        
        spinner = {
            let spinner = UIActivityIndicatorView(style: .whiteLarge)
            spinner.color = .lightGray
            spinner.hidesWhenStopped = true
            spinner.startAnimating()
            spinner.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(spinner)
            
            spinner.centerXAnchor.constraint(equalTo: tagPicker.centerXAnchor).isActive = true
            spinner.centerYAnchor.constraint(equalTo: tagPicker.centerYAnchor, constant: -5).isActive = true

            return spinner
        }()
        
        spinnerLabel = {
            let label = UILabel()
            label.text = "Fetching tags..."
            label.font = .systemFont(ofSize: 17, weight: .medium)
            label.textColor = .darkGray
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: spinner.centerXAnchor).isActive = true
            label.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 10).isActive = true
            
            return label
        }()
        
        bottomBanner = {
            let banner = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
            banner.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(banner)
            
            banner.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            banner.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            banner.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            banner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -75).isActive = true
            return banner
        }()
        
        continueButton = {
            let button = UIButton()
            button.setTitle(customButtonTitle ?? "Continue", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
            button.backgroundColor = MAIN_DISABLED
            button.isUserInteractionEnabled = false
            button.layer.cornerRadius = 25
            button.translatesAutoresizingMaskIntoConstraints = false
            bottomBanner.contentView.addSubview(button)
            
            button.widthAnchor.constraint(equalToConstant: 210).isActive = true
            button.heightAnchor.constraint(equalToConstant: 50).isActive = true
            button.centerXAnchor.constraint(equalTo: bottomBanner.centerXAnchor).isActive = true
            button.centerYAnchor.constraint(equalTo: bottomBanner.safeAreaLayoutGuide.centerYAnchor).isActive = true
            
            button.addTarget(self, action: #selector(completePickingTags), for: .touchUpInside)
            button.addTarget(self, action: #selector(buttonPressed), for: .touchDown)
            button.addTarget(self, action: #selector(buttonReleased), for: [
                .touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit
            ])
            
            return button
        }()
        
        loadTags()
    }

    private func loadTags() {
        
        self.continueButton.backgroundColor = MAIN_DISABLED
        self.continueButton.isUserInteractionEnabled = false
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/Tags",
                           parameters: ["withDefault": "1"])!
        
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                DispatchQueue.main.async {
                    internetUnavailableError(vc: self) {
                        self.errorHandler?()
                    }
                }
                return
            }
            
            if let json = try? JSON(data: data!).dictionary {
                if json?["status"]!.stringValue == INTERNAL_ERROR {
                    serverMaintenanceError(vc: self) {
                        self.errorHandler?()
                    }
                } else {
                    self.tags = json?["tags"]!.arrayObject as! [String]
                    DispatchQueue.main.async {
                        self.spinner.stopAnimating()
                        self.spinnerLabel.isHidden = true
                        self.tagPicker.reloadSections(IndexSet(arrayLiteral: 0))
                        self.updateUI()
                    }
                }
            }
        }
        
        task.resume()
    }
    
    @objc private func buttonPressed() {
        UIView.transition(with: continueButton,
                          duration: 0.2,
                          options: .curveEaseInOut,
                          animations: {
                              self.continueButton.backgroundColor = MAIN_TINT_DARK
                          },
                          completion: nil)
    }
    
    @objc private func buttonReleased() {
        UIView.transition(with: continueButton,
                          duration: 0.2,
                          options: .curveEaseInOut,
                          animations: {
                              self.continueButton.backgroundColor = MAIN_TINT
                          },
                          completion: nil)
    }
    
    @objc func completePickingTags() {
        if customContinueMethod != nil {
            customContinueMethod?(self)
            return
        }
        
        let url = URL(string: API_BASE_URL + "account/UpdateTags")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addAuthHeader()
        
        var body = JSON()
        body.dictionaryObject?["uuid"] = User.current?.uuid
        let tagsArray = selectedTags.map { $0 }
        body.dictionaryObject?["tags"] = tagsArray
        request.httpBody = try? body.rawData()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                print(error!)
                return
            }
            
            let msg = String(data: data!, encoding: .ascii) ?? ""
            switch msg {
            case INTERNAL_ERROR:
                serverMaintenanceError(vc: self)
            case "success":
                print("successfully updated tags")
                User.current!.tags = Set(tagsArray)
                DispatchQueue.main.async {
                    MainTabBarController.current.openScreen()
                }
            default:
                break
            }
        }
        
        task.resume()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        customDisappearHandler?(selectedTags)
    }

}

// MARK: - Collection view data source

extension TagPickerView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let tagCell = collectionView.dequeueReusableCell(withReuseIdentifier: "tag", for: indexPath) as! TagCell
        tagCell.tagLabel.text = tags[indexPath.row]
        tagCell.isSelected = selectedTags.contains(tags[indexPath.row])
        if tagCell.isSelected {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .init())
        }
        return tagCell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

// MARK: - Collection view delegate

extension TagPickerView: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedTags.insert(tags[indexPath.row])
    }

    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        selectedTags.remove(tags[indexPath.row])
    }
}

extension TagPickerView: UICollectionViewDelegateFlowLayout {
    
    static let width: CGFloat = 120
    
    var usableWidth: CGFloat {
        return tagPicker.safeAreaLayoutGuide.layoutFrame.width
    }
    
    var equalSpacing: CGFloat {
        let rowCount = floor(usableWidth / TagPickerView.width)
        let extraSpace = usableWidth - rowCount * TagPickerView.width
        return extraSpace / (rowCount + 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: TagPickerView.width, height: TagPickerView.width)
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
        coordinator.animate(alongsideTransition: { context in
            self.topBanner.layoutIfNeeded()
            self.tagPicker.contentInset.top = self.topBanner.frame.height
            self.tagPicker.scrollIndicatorInsets.top = self.topBanner.frame.height
            self.tagPicker.collectionViewLayout.invalidateLayout()
        }, completion: nil)
    }
}
