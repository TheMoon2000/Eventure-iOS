//
//  OrgAccountPageController.swift
//  Eventure
//
//  Created by Prince Wang on 2019/8/31.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//
import TOCropViewController
import UIKit

class OrgAccountPageController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    private var myTableView: UITableView!
    
    
    private var currentImageView: UIImageView!
    private var profilePicture: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        //Do any additional setup after loading the view.
        title = Organization.waitingForSync ? "Syncing..." : "Dashboard"
        view.backgroundColor = .init(white: 0.92, alpha: 1)
        
        myTableView = UITableView(frame: .zero, style: .grouped)
        myTableView.dataSource = self
        myTableView.delegate = self
        myTableView.backgroundColor = UIColor.init(white: 0.95, alpha: 1)
        self.view.addSubview(myTableView)
        
        
        //set location constraints of the tableview
        myTableView.translatesAutoresizingMaskIntoConstraints = false
        myTableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        myTableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        myTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        myTableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(orgUpdated), name: ORG_SYNC_SUCCESS, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(orgUpdated), name: ORG_SYNC_FAILED, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.myTableView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// New account data has been synced from the server and are reflected in the new `Organization.current` instance. Make appropriate changes to the dashboard page accordingly, e.g. reload certain row cells.
    @objc private func orgUpdated() {
        DispatchQueue.main.async {
            self.navigationItem.title = "Dashboard"
            self.myTableView.reloadData()
            UIView.performWithoutAnimation {
                self.myTableView.reloadRows(at: [[1, 1]], with: .none)
            }
        }
    }
    
    //when table view is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        //Write for cases for all cells on the page
        switch (indexPath.section, indexPath.row) {
            
        case (0, 0):
            let alert = UIAlertController(title: "Update Organization Logo", message: nil, preferredStyle: .actionSheet)
            alert.addAction(.init(title: "Cancel", style: .cancel))
            alert.addAction(.init(title: "Photo Library", style: .default, handler: { _ in
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.sourceType = .photoLibrary
                self.present(picker, animated: true)
            }))
            alert.addAction(.init(title: "Camera", style: .default, handler: { _ in
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.sourceType = .camera
                self.present(picker, animated: true)
            }))
            
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = tableView
                let cellRect = tableView.rectForRow(at: indexPath)
                popoverController.sourceRect = CGRect(x: cellRect.midX, y: cellRect.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = [.left, .up]
            }
            
            present(alert, animated: true)
            
        case (1,0): //if the user tries to change account information
            let orgInfo = OrgSettingInfoPage()
            orgInfo.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(orgInfo, animated: true)
        case (1,1):
            let orgProfile = OrgProfilePage()
            orgProfile.parentVC = self
            orgProfile.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(orgProfile, animated: true)
        case (2, 0):
            let alert = UIAlertController(title: "Feature unavailable", message: "We are still working on this feature. Please wait a few weeks for our next release.", preferredStyle: .alert)
            alert.addAction(.init(title: "OK", style: .cancel))
            present(alert, animated: true)
        case (2, 1):
            let subscriber = SubscriberListPage()
            subscriber.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(subscriber, animated:true)
        case (3, 0):
            let aboutPage = AboutPage()
            aboutPage.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(aboutPage, animated: true)
        case (3, 1):
            //if the log out/sign in button is clicked
            //Note: Do not need to imeplement the case where Organization.current == nil
            //because we have already logged in for Org
            let alert = UIAlertController(title: "Do you want to log out?", message: "Changes you've made have been saved.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { action in
                UserDefaults.standard.removeObject(forKey: KEY_ACCOUNT_TYPE)
                Organization.current = nil
                MainTabBarController.current.openScreen()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            self.present(alert, animated: true)
        default:
            break
        }
        
    }

    
    //create a cell for each table view row
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = SettingsItemCell()
        
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let profileCell = ProfilePreviewCell()
            profileCell.icon.isUserInteractionEnabled = true
            profileCell.icon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped)))
            profileCell.titleLabel.text = Organization.current!.title
            if let logo = Organization.current?.logoImage {
                profileCell.icon.image = logo
            } else {
                profileCell.icon.image = #imageLiteral(resourceName: "group").withRenderingMode(.alwaysTemplate)
                Organization.current?.getLogoImage { orgWithImage in
                    profileCell.icon.image = orgWithImage.logoImage
                }
            }
            let noun = Organization.current!.numberOfEvents == 1 ? "event" : "events"
            profileCell.subtitleLabel.text = "\(Organization.current!.numberOfEvents) " + noun
            
            return profileCell
        case (1, 0):
            cell.icon.image = UIImage(named: "profile")
            cell.titleLabel.text = "Manage Account"
        case (1, 1):
            cell.icon.image = UIImage(named: "organization_profile")
            cell.titleLabel.text = "Organization Profile"
            cell.valueLabel.text = Organization.current?.profileStatus
        case (2, 0):
            cell.icon.image = #imageLiteral(resourceName: "stats")
            cell.titleLabel.text = "Event Statistics"
        case (2, 1):
            cell.icon.image = #imageLiteral(resourceName: "heart").withRenderingMode(.alwaysTemplate)
            cell.titleLabel.text = "Subscribers"
            cell.valueLabel.text = "\(Organization.current!.subscribers.count)"
        case(3, 0):
            let cell = UITableViewCell()
            let h = cell.heightAnchor.constraint(equalToConstant: 50)
            h.priority = .defaultHigh
            h.isActive = true
            
            let label = UILabel()
            label.text = "About Eventure"
            label.font = .systemFont(ofSize: 17)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            cell.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
            
            return cell
            
        case (3, 1):
            let cell = UITableViewCell()
            cell.heightAnchor.constraint(equalToConstant: 50).isActive = true

            let label = UILabel()
            label.text = "Log Out"
            label.font = .systemFont(ofSize: 17)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            cell.addSubview(label)

            label.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true

            return cell

        default:
            break
        }
        
        return cell
    }
        
    //number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    //section titles
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return [
            "",
            "Organization Information",
            "Events and Subscriptions",
            nil
            ][section]
    }
    
    //rows in sections
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [1, 2, 2, 2][section]
    }
    
    //eliminate first section header
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return [0, 30, 30, 30, 30][section]
    }
    
    //full screen profile picture when tapped
    
    @objc private func imageTapped(_ sender: UITapGestureRecognizer) {
        if let logo = Organization.current?.logoImage {
            let fullScreen = ImageFullScreenPage(image: logo)
            present(fullScreen, animated: false)
        }
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        sender.view?.removeFromSuperview()
        currentImageView = nil
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return currentImageView
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        guard let original = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        let cropper = TOCropViewController(image: original)
        cropper.rotateButtonsHidden = true
        cropper.resetButtonHidden = true
        cropper.aspectRatioPickerButtonHidden = true
        cropper.aspectRatioPreset = .presetSquare
        cropper.aspectRatioLockEnabled = true
        cropper.allowedAspectRatios = [TOCropViewControllerAspectRatioPreset.presetSquare.rawValue as NSNumber]
        cropper.delegate = self
        picker.present(cropper, animated: true)
    }
    
    
}

extension OrgAccountPageController: TOCropViewControllerDelegate {
    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        
        Organization.current?.uploadLogo(new: image) { success in
            if !success {
                let warning = UIAlertController(title: "Unable to update logo", message: nil, preferredStyle: .alert)
                warning.addAction(.init(title: "Dismiss", style: .cancel))
                self.present(warning, animated: true, completion: nil)
            }
            self.myTableView.reloadRows(at: [[0, 0]], with: .none)
        }
        
        self.myTableView.reloadRows(at: [[0, 0]], with: .none)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        self.dismiss(animated: true, completion: nil)
    }
}
