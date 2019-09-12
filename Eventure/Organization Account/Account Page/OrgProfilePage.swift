//
//  OrgProfilePage.swift
//  Eventure
//
//  Created by Prince Wang on 2019/9/1.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class OrgProfilePage: UITableViewController, EditableInfoProvider {
    
    var parentVC: OrgAccountPageController?
    
    private var contentCells = [[UITableViewCell]]()
    private var saveBarButton: UIBarButtonItem!
    private var spinner: UIActivityIndicatorView!
    
    var cellsEditable: Bool { return true }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Organization Profile"
        
        navigationItem.backBarButtonItem = .init(title: "Back", style: .plain, target: nil, action: nil)
        
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInset.top = 5
        tableView.contentInset.bottom = 10
        tableView.keyboardDismissMode = .interactive
        tableView.tableFooterView = UIView()
        
        let section0: [UITableViewCell] = {
            var section = [UITableViewCell]()
            
            let websiteCell = TextFieldCell(parentVC: self)
            websiteCell.textfield.placeholder = "Link to website"
            websiteCell.icon.image = #imageLiteral(resourceName: "browser")
            websiteCell.linkDetectionEnabled = true
            websiteCell.textfield.keyboardType = .URL
            websiteCell.textfield.autocapitalizationType = .none
            websiteCell.textfield.enablesReturnKeyAutomatically = true
            websiteCell.textfield.text = Organization.current?.website
            websiteCell.textChanged()
            
            websiteCell.changeHandler = { textfield in
                Organization.current?.saveEnabled = false
                Organization.current?.website = textfield.text!
                Organization.current?.saveEnabled = true
            }
            
            websiteCell.endEditingHandler = { textfield in
                Organization.current?.website = textfield.text!
            }
            
            websiteCell.returnHandler = { textfield in
                (self.contentCells[1][0] as! TextFieldCell).textfield.becomeFirstResponder()
            }
            //FIXME:闪退
            
            section.append(websiteCell)
            
            if let website = Organization.current?.website {
                websiteCell.textfield.text = website
            }
            
            return section
            
            }()
        
        contentCells.append(section0)
        
        let section1: [UITableViewCell] = {
            var section = [UITableViewCell]()
            
            let emailCell = TextFieldCell(parentVC: self)
            emailCell.textfield.placeholder = "Contact Email"
            emailCell.icon.image = UIImage(named: "email")
            emailCell.textfield.keyboardType = .emailAddress
            emailCell.textfield.autocapitalizationType = .none
            emailCell.textfield.enablesReturnKeyAutomatically = true
            emailCell.textfield.text = Organization.current?.contactEmail
            emailCell.textChanged()
            
            emailCell.changeHandler = { textfield in
                Organization.current?.saveEnabled = false
                Organization.current?.contactEmail = textfield.text!
                Organization.current?.saveEnabled = true
            }
            
            emailCell.endEditingHandler = { textfield in
                Organization.current?.contactEmail = textfield.text!
            }
            
            emailCell.returnHandler = { textfield in
                (self.contentCells[2][0] as! TextFieldCell).textfield.becomeFirstResponder()
            }
            
            section.append(emailCell)
            
            if let email = Organization.current?.contactEmail {
                emailCell.textfield.text = email
            }
            
            return section
            
        }()
        
        contentCells.append(section1)
        
        //Tag Area
        let section2: [UITableViewCell] = {
            var section = [UITableViewCell]()
            let tagCell = SettingsItemCell()
            tagCell.icon.image = UIImage(named: "tag")
            tagCell.titleLabel.text = "Manage Tags"
            
            section.append(tagCell)
            
            return section
        }()
        
        contentCells.append(section2)
        
        let section3: [UITableViewCell] = {
            var section = [UITableViewCell]()
            let descriptionCell = SettingsItemCell()
            descriptionCell.icon.image = #imageLiteral(resourceName: "edit").withRenderingMode(.alwaysTemplate)
            descriptionCell.titleLabel.text = "Organization Description"
            
            section.append(descriptionCell)
            
            return section
        }()
        
        contentCells.append(section3)
        
        spinner = UIActivityIndicatorView(style: .gray)
        spinner.startAnimating()
        
        saveBarButton = .init(title: "Save", style: .done, target: self, action: #selector(save))
        navigationItem.rightBarButtonItem = saveBarButton
            
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return [
            "Organization Website",
            "Contact Email",
            "Organization Tags",
            "Organization Description",
            nil
            ][section]
    }
    
    @objc private func save(disappearing: Bool = false) {
        print("saving")
        guard let org = Organization.current else {
            print("place -1")
            return
        }
        
        guard Organization.needsUpload else {
            print("place 0")
            return
        }
        
        navigationItem.rightBarButtonItem = .init(customView: spinner)
        
        //Calling the API to save data
        
        let url = URL.with(base: API_BASE_URL, API_Name: "account/UpdateOrgInfo", parameters: ["id": String(org.id)])!
        
        print("place1")
        
        var request = URLRequest(url: url)
        request.addAuthHeader()
        request.httpMethod = "POST"
        
        
        //This part indicates what data are we saving
        //Assuming we already have org's instance variables updated
        var body = JSON()
        body.dictionaryObject?["Tags"] = org.tags.description //Serialize Tags
        body.dictionaryObject?["Email"] = org.contactEmail
        body.dictionaryObject?["Description"] = org.orgDescription
        body.dictionaryObject?["Website"] = org.website
        
        request.httpBody = try? body.rawData()
        
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            DispatchQueue.main.async {
                self.navigationItem.rightBarButtonItem = self.saveBarButton
            }

        
        
            guard error == nil else {
            if !disappearing {
                DispatchQueue.main.async {
                    internetUnavailableError(vc: self)
                    print("place2")
                }
            } else {
                let alert = UIAlertController(title: "Changes could not uploaded", message: "It seems that some of your changes to your organization's settings could not be automatically uploaded due to lack of internet connection. These changes have been saved locally, but will be lost if you quit and reopen this app while being online, as they will be overwritten.", preferredStyle: .alert)
                alert.addAction(.init(title: "I Understand", style: .cancel))
                print("place3")
                DispatchQueue.main.async {
                    self.parentVC?.present(alert, animated: true, completion: nil)
                }
            }
            return
        }
            
            let msg = String(data: data!, encoding: .utf8)
            
            switch msg {
            case INTERNAL_ERROR:
                DispatchQueue.main.async {
                    serverMaintenanceError(vc: self)
                    print("Error")
                }
            case "success":
                Organization.needsUpload = false
                print("success")
            default:
                print(msg!)
                print("place4")
            }
            
        }
        task.resume()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if Organization.needsUpload {
            save(disappearing: true)
        }
    }
    
    //Add header
    //FIXME: how to make this compatible
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//
//        if section != 0 { return nil }
//
//        let header = UIView()
//
//        let title = UILabel()
//        title.numberOfLines = 5
//        title.lineBreakMode = .byWordWrapping
//        title.textAlignment = .center
//        title.attributedText = "Let people know more about this organization from event check-ins by filling out profile information!".attributedText()
//        title.font = .systemFont(ofSize: 16)
//        title.translatesAutoresizingMaskIntoConstraints = false
//        header.addSubview(title)
//
//        title.leftAnchor.constraint(equalTo: header.leftAnchor, constant: 30).isActive = true
//        title.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -30).isActive = true
//        title.topAnchor.constraint(equalTo: header.topAnchor, constant: 20).isActive = true
//        title.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -20).isActive = true
//
//        return header
//    }
    
    //number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return contentCells.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentCells[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return contentCells[indexPath.section][indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath {
        case [3, 0]:
            let editPage = DescriptionEditPage()
            editPage.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(editPage, animated: true)
            
        case [2, 0]:
            //This is the case when you hit Tags cell: org changing their tags
            let tagPicker = TagPickerView()
            tagPicker.customTitle = "Choose 1 - 3 tags that best describe your organization."
            tagPicker.customSubtitle = ""
            tagPicker.maxPicks = 3
            tagPicker.selectedTags = Organization.current!.tags
            tagPicker.customButtonTitle = "Done"
            
            tagPicker.customContinueMethod = { tagPicker in
                
                tagPicker.spinner.removeFromSuperview()
                
                let loadingView: UIView = UIView()
                loadingView.frame = CGRect(x:0, y:0, width:110, height:110)
                loadingView.center = tagPicker.view.center
                loadingView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
                loadingView.clipsToBounds = true
                loadingView.layer.cornerRadius = 10
                
                let label = UILabel()
                label.text = "Updating..."
                label.font = .systemFont(ofSize: 17, weight: .medium)
                label.textColor = .white
                label.translatesAutoresizingMaskIntoConstraints = false
                loadingView.addSubview(label)
                label.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor).isActive = true
                label.topAnchor.constraint(equalTo: loadingView.topAnchor,constant:80).isActive = true
                
                loadingView.addSubview(tagPicker.spinner)
                tagPicker.view.addSubview(loadingView)
                
                tagPicker.spinner.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor).isActive = true
                tagPicker.spinner.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor, constant: -5).isActive = true
                
                tagPicker.spinner.startAnimating()
                
                Organization.current?.pushToServer { success in
                    tagPicker.spinner.stopAnimating()
                    label.removeFromSuperview()
                    loadingView.removeFromSuperview()
                    if success {
                        Organization.current!.tags = tagPicker.selectedTags
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        internetUnavailableError(vc: self)
                    }
                }
            }
            
            tagPicker.customDisappearHandler = { tags in
                Organization.current?.tags = tags
                Organization.current?.pushToServer(nil)
            }
            
            //push the TagPicker Page
            tagPicker.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(tagPicker, animated: true)
        
        default:
            break
        }
    }
    
    
    
}

