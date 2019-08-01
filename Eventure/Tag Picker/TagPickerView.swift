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
    
    private var titleLabel: UILabel!
    private var subtitleLabel: UILabel!
    private var spinner: UIActivityIndicatorView!
    private var spinnerLabel: UILabel!
    private var bottomBanner: UIVisualEffectView!
    private var continueButton: UIButton!
    
    var tagPicker: UICollectionView!
    var tags = [String]()
    var selectedTags = Set<String>() {
        didSet {
            if selectedTags.isEmpty {
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
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        titleLabel = {
            let label = UILabel()
            label.text = "What Interests You?"
            label.font = .systemFont(ofSize: 26, weight: .semibold)
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
            
            return label
        }()
        
        subtitleLabel = {
            let label = UILabel()
            label.text = "Pick at least one. The more the better!"
            label.font = .systemFont(ofSize: 16)
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
            label.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor).isActive = true
            
            return label
        }()
        

        tagPicker = {
            let picker = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
            picker.backgroundColor = .init(white: 0.95, alpha: 1)
            picker.register(TagCell.classForCoder(), forCellWithReuseIdentifier: "tag")
            picker.allowsMultipleSelection = true
            picker.contentInset.bottom = 75
            picker.contentInsetAdjustmentBehavior = .always
            picker.delegate = self
            picker.dataSource = self
            picker.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(picker)
            
            picker.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            picker.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            picker.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 30).isActive = true
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
            button.setTitle("Continue", for: .normal)
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
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/tags",
                           parameters: ["withDefault": "1"])!
        
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                print(error!)
                return
            }
            
            if let json = try? JSON(data: data!).dictionary {
                if json["status"]!.stringValue == INTERNAL_ERROR {
                    serverMaintenanceError(vc: self) {
                        self.dismiss(animated: true, completion: nil)
                    }
                } else {
                    self.tags = json["tags"]!.arrayObject as! [String]
                    DispatchQueue.main.async {
                        self.spinner.stopAnimating()
                        self.spinnerLabel.isHidden = true
                        self.tagPicker.reloadSections(IndexSet(arrayLiteral: 0))
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
    
    @objc private func completePickingTags() {
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
                User.current!.tags = tagsArray
            default:
                break
            }
        }
        
        task.resume()
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
            self.tagPicker.collectionViewLayout.invalidateLayout()
        }, completion: nil)
    }
}
