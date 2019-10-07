//
//  AccountViewController.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/2.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import SwiftyJSON
import UIKit
import TOCropViewController

class AccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UINavigationControllerDelegate, UIImagePickerControllerDelegate  {
    
    private(set) var myTableView: UITableView!
    
    private var currentImageView: UIImageView!
    private var profilePicture: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = AppColors.canvas
        title = User.waitingForSync ? "Syncing..." : "Me"

        //myTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        myTableView = UITableView(frame: .zero, style: .grouped)
        myTableView.dataSource = self
        myTableView.delegate = self
        myTableView.backgroundColor = .clear
        self.view.addSubview(myTableView)
        //set location constraints of the tableview
        myTableView.translatesAutoresizingMaskIntoConstraints = false
        myTableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        myTableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        myTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        myTableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(userUpdated), name: USER_SYNC_FAILED, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userUpdated), name: USER_SYNC_SUCCESS, object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.myTableView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// New user data was synced from the server. Make appropriate updates to the account page to reflect those changes.
    @objc private func userUpdated() {
        DispatchQueue.main.async {
            self.title = "Me"
            self.navigationController?.navigationBar.setNeedsDisplay()
            UIView.performWithoutAnimation {
                self.myTableView.reloadRows(at: [[0, 0], [1, 1], [2, 2]], with: .none)
            }
        }
    }
    
    //when table view is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section != 4 {
            guard User.current != nil else {
                popLoginReminder()
            return
            }
        }
        
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let alert = UIAlertController(title: "Update Profile Picture", message: nil, preferredStyle: .actionSheet)
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
                popoverController.permittedArrowDirections = .up
            }
            
            present(alert, animated: true)
            
        case (1, 0): // if the user tries to change account information
            let personalInfo = PersonalInfoPage()
            personalInfo.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(personalInfo, animated: true)
        case (1, 1):
            let profileInfo = ProfileInfoPage(profile: User.current)
            profileInfo.parentVC = self
            profileInfo.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(profileInfo, animated: true)
        case (2, 0):
            let scanVC = UserScanner()
            scanVC.accountVC = self
            scanVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(scanVC, animated: true)
        case (2, 1):
            let checkedInPage = CheckedInEvents()
            checkedInPage.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(checkedInPage, animated: true)
        case (2, 2):
            let ticketsPage = TicketsOverview()
            ticketsPage.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(ticketsPage, animated: true)
        case (3,0):
            let likeEventsPage = LikedEvents()
            likeEventsPage.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(likeEventsPage, animated: true)
        case (3,1):
            let interestedPage = InterestedEvents()
            interestedPage.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(interestedPage, animated: true)
        case (3, 2):
            //if user wants to change the tags
            let tagPicker = TagPickerView()
            tagPicker.customTitle = "What interests you?"
            tagPicker.customSubtitle = "Pick at least one. The more the better!"
            tagPicker.customButtonTitle = "Done"
            tagPicker.customContinueMethod = { tagPicker in
                
                tagPicker.loadingBG.isHidden = false
                
                User.current!.tags = tagPicker.selectedTags
                
                let url = URL(string: API_BASE_URL + "account/UpdateTags")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.addAuthHeader()
                
                var body = JSON()
                body.dictionaryObject?["uuid"] = User.current?.uuid
                let tagsArray = tagPicker.selectedTags.map { $0 }
                body.dictionaryObject?["tags"] = tagsArray
                request.httpBody = try? body.rawData()
                
                let task = CUSTOM_SESSION.dataTask(with: request) {
                    data, response, error in
                    
                    DispatchQueue.main.async {
                        tagPicker.loadingBG.isHidden = true
                    }
                    
                    guard error == nil else {
                        DispatchQueue.main.async {
                            internetUnavailableError(vc: self)
                        }
                        return
                    }
                    
                    let msg = String(data: data!, encoding: .ascii) ?? ""
                    switch msg {
                    case INTERNAL_ERROR:
                        DispatchQueue.main.async {
                            serverMaintenanceError(vc: self)
                        }
                    case "success":
                        User.current!.tags = Set(tagsArray)
                        DispatchQueue.main.async { self.navigationController?.popViewController(animated: true)
                        }
                    default:
                        DispatchQueue.main.async {
                            internetUnavailableError(vc: self)
                        }
                    }
                }
                
                task.resume()
            }
            
            tagPicker.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(tagPicker, animated: true)
            
            DispatchQueue.main.async {
                tagPicker.selectedTags = User.current!.tags
            }
        case (4, 0):
            let aboutPage = AboutPage()
            aboutPage.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(aboutPage, animated: true)
        case (4, 1): // if the log out/sign in button is clicked
            if (User.current == nil) {
                let login = LoginViewController()
                let nvc = InteractivePopNavigationController(rootViewController: login)
                nvc.isNavigationBarHidden = true
                login.navBar = nvc
                present(nvc, animated: true)
            } else {
                //pop out an alert window
                let alert = UIAlertController(title: "Do you want to log out?", message: "Changes you've made have been saved.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { action in
                    UserDefaults.standard.removeObject(forKey: KEY_ACCOUNT_TYPE)
                    User.current = nil
                    MainTabBarController.current.openScreen(page: 2)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                self.present(alert, animated: true)
            }
        default:
            break
        }
    }
    
    func openTickets() {
        let ticketsPage = TicketsOverview()
        ticketsPage.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(ticketsPage, animated: true)
    }
    
    //create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = SettingsItemCell()
        
        switch (indexPath.section, indexPath.row) {
            
        case (0, 0):
            let profileCell = ProfilePreviewCell()
            profileCell.icon.isUserInteractionEnabled = true
            profileCell.icon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped)))
            profileCell.titleLabel.text = User.current?.displayedName ?? "Not logged in"
            if profileCell.titleLabel.text!.isEmpty {
                profileCell.titleLabel.text = User.current!.email
            }
            if let count = User.current?.numberOfAttendedEvents {
                let noun = count == 1 ? "event" : "events"
                profileCell.subtitleLabel.text = "\(count) " + noun + " attended"
            } else {
                profileCell.subtitleLabel.text = "Log in to access more features."
            }
            if let image = User.current?.profilePicture {
                profileCell.icon.image = image
            } else {
                profileCell.icon.image = #imageLiteral(resourceName: "guest").withRenderingMode(.alwaysTemplate)
                User.current?.getProfilePicture { userWithProfile in
                    profileCell.icon.image = userWithProfile.profilePicture
                }
            }
            profileCell.icon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:))))
            return profileCell
        case (1, 0):
            cell.icon.image = #imageLiteral(resourceName: "default_user")
            cell.titleLabel.text = "Manage Account"
        case (1, 1):
            cell.icon.image = #imageLiteral(resourceName: "profile")
            cell.titleLabel.text = "Professional Profile"
            cell.valueLabel.text = User.current?.profileStatus
        case (2, 0):
            cell.icon.image = #imageLiteral(resourceName: "scan").withRenderingMode(.alwaysTemplate)
            cell.titleLabel.text = "Scan"
        case (2, 1):
            cell.icon.image = #imageLiteral(resourceName: "qr").withRenderingMode(.alwaysTemplate)
            cell.titleLabel.text = "Events I Checked in"
        case (2, 2):
            cell.icon.image = #imageLiteral(resourceName: "ticket").withRenderingMode(.alwaysTemplate)
            cell.titleLabel.text = "My Tickets"
            if User.current != nil {
                cell.valueLabel.text = String(Ticket.userTickets.count) + " Total"
            }
        case (3, 0):
            cell.icon.image = #imageLiteral(resourceName: "heart").withRenderingMode(.alwaysTemplate)
            cell.titleLabel.text = "Favorite Events"
        case (3, 1):
            cell.icon.image = #imageLiteral(resourceName: "star_filled").withRenderingMode(.alwaysTemplate)
            cell.icon.tintColor = AppColors.interest
            cell.titleLabel.text = "Interested Events"
        case (3, 2):
            cell.icon.image = #imageLiteral(resourceName: "tag").withRenderingMode(.alwaysTemplate)
            cell.icon.tintColor = AppColors.link
            cell.titleLabel.text = "My Tags"
        case (4, 0):
            let cell = UITableViewCell()
            let c = cell.heightAnchor.constraint(equalToConstant: 50)
            c.priority = .defaultHigh
            c.isActive = true
            
            let label = UILabel()
            label.text = "About Eventure"
            label.font = .systemFont(ofSize: 17)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            cell.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
            
            return cell
        case (4, 1):
            let cell = UITableViewCell()
            let c = cell.heightAnchor.constraint(equalToConstant: 50)
            c.priority = .defaultHigh
            c.isActive = true
            
            let label = UILabel()
            label.text = User.current != nil ? "Log Out" : "Log In"
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
        return 5
    }
    
    //section titles
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return [
            "",
            "Personal Information",
            "Event Check-in",
            "Personal Interests",
            nil
        ][section]
    }
    
    //rows in sections
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int {
        return [1, 2, 3, 3, 2][section]
    }
    
    //eliminate first section header
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return [0, 30, 30, 30, 30][section]
    }
    
    
    //full screen profile picture when tapped
    @objc private func imageTapped(_ sender: UITapGestureRecognizer) {
        if let profile = User.current?.profilePicture {
            let fullScreen = ImageFullScreenPage(image: profile)
            present(fullScreen, animated: false)
        }
    }
    
    //exit profile picture fullscreen
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        sender.view?.removeFromSuperview()
        currentImageView = nil
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return currentImageView
    }
    
    func popLoginReminder() {
        let alert = UIAlertController(title: "Do you want to log in?", message: "Log in to make changes to your account.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            let login = LoginViewController()
            let nvc = InteractivePopNavigationController(rootViewController: login)
            nvc.isNavigationBarHidden = true
            login.navBar = nvc
            self.present(nvc, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        self.present(alert, animated: true)
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

extension AccountViewController: TOCropViewControllerDelegate {
    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        
        User.current?.uploadProfilePicture(new: image) { success in
            if !success {
                let warning = UIAlertController(title: "Unable to Update Profile Picture", message: nil, preferredStyle: .alert)
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

