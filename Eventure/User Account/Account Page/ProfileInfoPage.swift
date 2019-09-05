//
//  ProfileInfoPage.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/31.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class ProfileInfoPage: UITableViewController, EditableInfoProvider {
    
    var parentVC: AccountViewController?
    
    private var graduationCellExpanded = false
    private var contentCells = [[UITableViewCell]]()
    
    private var saveBarButton: UIBarButtonItem!
    private var spinner: UIActivityIndicatorView!
    
    private(set) var userProfile: Profile!
    
    var cellsEditable: Bool { return userProfile.editable }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init(profile: Profile?) {
        super.init(nibName: nil, bundle: nil)
        
        self.userProfile = profile ?? User.current!
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "My Profile"
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInset.top = 5
        tableView.contentInset.bottom = 10
        tableView.keyboardDismissMode = .interactive
        tableView.tableFooterView = UIView()
        
        let section0: [UITableViewCell] = {
            var section = [UITableViewCell]()
            
            let nameCell = TextFieldCell(parentVC: self)
            nameCell.icon.image = #imageLiteral(resourceName: "name")
            nameCell.textfield.placeholder = "Full Name"
            nameCell.textfield.textContentType = .name
            nameCell.textfield.autocapitalizationType = .words
            nameCell.textfield.enablesReturnKeyAutomatically = true
            nameCell.textfield.text = userProfile.name
            
            nameCell.changeHandler = { textfield in
                User.current?.saveEnabled = false
                User.current?.fullName = textfield.text!
                User.current?.saveEnabled = true
            }
            
            nameCell.endEditingHandler = { textfield in
                User.current?.fullName = textfield.text!
            }
            
            nameCell.returnHandler = { textfield in
                (self.contentCells[0][1] as! TextFieldCell).textfield.becomeFirstResponder()
            }
            
            section.append(nameCell)
            
            let majorCell = TextFieldCell(parentVC: self)
            majorCell.icon.image = #imageLiteral(resourceName: "major")
            majorCell.textfield.placeholder = "Field(s) of study"
            majorCell.textfield.enablesReturnKeyAutomatically = true
            majorCell.textfield.returnKeyType = .next
            majorCell.textfield.text = userProfile.major
            
            
            majorCell.changeHandler = { textfield in
                User.current?.saveEnabled = false
                User.current?.major = textfield.text!
                User.current?.saveEnabled = true
            }
            
            majorCell.endEditingHandler = { textfield in
                User.current?.major = textfield.text!
            }
            
            majorCell.returnHandler = { textfield in
                textfield.resignFirstResponder()
                if User.current?.graduationYear == nil {
                    self.graduationCellExpanded = true
                    self.refreshGradCell()
                }
            }
            
            section.append(majorCell)
            
            let gradCell = SettingsItemCell()
            gradCell.icon.image = #imageLiteral(resourceName: "graduation")
            gradCell.titleLabel.text = "Year of Graduation:"
            gradCell.valueLabel.text = userProfile.graduation
            if gradCell.valueLabel.text!.isEmpty {
                gradCell.valueLabel.text = "Not Set"
            } else {
                gradCell.valueLabel.textColor = LINK_COLOR
            }
            section.append(gradCell)
            
            let chooser = GraduationYearChooser()
            chooser.set(year: userProfile.graduationYear, season: userProfile.graduationSeason)
            chooser.selectionHandler = { year, season in
                User.current?.graduationYear = year
                User.current?.graduationSeason = season
                gradCell.valueLabel.text = User.current?.graduation ?? "Can't edit"
                gradCell.valueLabel.textColor = LINK_COLOR
            }
            section.append(chooser)
            
            return section
        }()
        
        
        contentCells.append(section0)
        
        let section1: [UITableViewCell] = {
            var section = [UITableViewCell]()
            
            let resumeCell = TextFieldCell(parentVC: self)
            resumeCell.textfield.placeholder = "Link to resume"
            resumeCell.icon.image = #imageLiteral(resourceName: "resume")
            resumeCell.linkDetectionEnabled = true
            resumeCell.textfield.keyboardType = .URL
            resumeCell.textfield.autocapitalizationType = .none
            resumeCell.textfield.enablesReturnKeyAutomatically = true
            resumeCell.textfield.text = userProfile.resume
            resumeCell.textChanged()
            
            resumeCell.changeHandler = { textfield in
                User.current?.saveEnabled = false
                User.current?.resume = textfield.text!
                User.current?.saveEnabled = true
            }
            
            resumeCell.endEditingHandler = { textfield in
                User.current?.resume = textfield.text!
            }
            
            resumeCell.returnHandler = { textfield in
                (self.contentCells[2][0] as! TextFieldCell).textfield.becomeFirstResponder()
            }
            
            section.append(resumeCell)
            
            return section
        }()
        
        contentCells.append(section1)
        
        let section2: [UITableViewCell] = {
            var section = [UITableViewCell]()
            
            let linkedInCell = TextFieldCell(parentVC: self)
            if cellsEditable {
                linkedInCell.textfield.placeholder = "LinkedIn page (optional)"
            } else {
                linkedInCell.textfield.placeholder = "LinkedIn page"
            }
            linkedInCell.icon.image = #imageLiteral(resourceName: "linkedin")
            linkedInCell.linkDetectionEnabled = true
            linkedInCell.textfield.keyboardType = .URL
            linkedInCell.textfield.autocapitalizationType = .none
            linkedInCell.textfield.text = userProfile.linkedIn
            linkedInCell.textChanged()
            
            linkedInCell.changeHandler = { textfield in
                User.current?.saveEnabled = false
                User.current?.linkedIn = textfield.text!
                User.current?.saveEnabled = true
            }
            
            linkedInCell.endEditingHandler = { textfield in
                User.current?.linkedIn = textfield.text!
            }
            
            linkedInCell.returnHandler = { textfield in
                (self.contentCells[2][1] as! TextFieldCell).textfield.becomeFirstResponder()
            }
            
            section.append(linkedInCell)
            
            
            let githubCell = TextFieldCell(parentVC: self)
            if cellsEditable {
                githubCell.textfield.placeholder = "GitHub page (optional)"
            } else {
                githubCell.textfield.placeholder = "GitHub page"
            }
            githubCell.icon.image = #imageLiteral(resourceName: "github")
            githubCell.linkDetectionEnabled = true
            githubCell.textfield.keyboardType = .URL
            githubCell.textfield.autocapitalizationType = .none
            githubCell.textfield.text = userProfile.github
            githubCell.textChanged()
            
            githubCell.changeHandler = { textfield in
                User.current?.saveEnabled = false
                User.current?.github = textfield.text!
                User.current?.saveEnabled = true
            }
            
            githubCell.endEditingHandler = { textfield in
                User.current?.github = textfield.text!
            }
            
            githubCell.returnHandler = { textfield in
                (self.contentCells[3][0] as! TextFieldCell).textfield.becomeFirstResponder()
            }
            
            section.append(githubCell)
            
            return section
        }()
        
        contentCells.append(section2)
        
        let section3: [UITableViewCell] = {
            var section = [UITableViewCell]()
            
            let hobbyCell = TextFieldCell(parentVC: self)
            hobbyCell.icon.image = #imageLiteral(resourceName: "interests")
            if cellsEditable {
                hobbyCell.textfield.placeholder = "Skills and interests (optional)"
            } else {
                hobbyCell.textfield.placeholder = "Skills and interests"
            }
            hobbyCell.textfield.text = userProfile.interests
            
            hobbyCell.changeHandler = { textfield in
                User.current?.saveEnabled = false
                User.current?.interests = textfield.text!
                User.current?.saveEnabled = true
            }
            
            hobbyCell.endEditingHandler = { textfield in
                User.current?.interests = textfield.text!
            }
            
            hobbyCell.returnHandler = { textfield in
                (self.contentCells[3][1] as! CommentCell).commentText.becomeFirstResponder()
            }
            
            section.append(hobbyCell)
            
            let commentCell = CommentCell()
            commentCell.commentText.insertText(userProfile.comments)
            commentCell.commentText.returnKeyType = .default
            commentCell.commentText.isEditable = cellsEditable
            commentCell.textChangeHandler = { textView in
                
                User.current?.saveEnabled = false
                User.current?.comments = textView.text
                User.current?.saveEnabled = true
                
                UIView.performWithoutAnimation {
                    self.tableView.beginUpdates()
                    self.tableView.endUpdates()
                }
                
                if textView.selectedRange.location == textView.text.count {
                    self.tableView.scrollToRow(at: [3, 1], at: .bottom, animated: false)
                }
            }
            
            
            commentCell.textEndEditingHandler = { text in
                User.current?.comments = text
            }
            
            section.append(commentCell)
            
            return section
        }()
        
        contentCells.append(section3)
        
        spinner = UIActivityIndicatorView(style: .gray)
        spinner.startAnimating()
        
        saveBarButton = .init(title: "Save", style: .done, target: self, action: #selector(save))
        navigationItem.rightBarButtonItem = saveBarButton
    }
    
    @objc private func save(disappearing: Bool = false) {
        
        guard let user = User.current else {
            return
        }
        
        guard User.needsUpload else {
            return
        }
        
        navigationItem.rightBarButtonItem = .init(customView: spinner)
                
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "account/UpdateUserInfo",
                           parameters: ["uuid": String(user.uuid)])!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        request.httpMethod = "POST"
        
        var body = JSON()
        body.dictionaryObject?["Full name"] = user.fullName
        body.dictionaryObject?["Graduation year"] = user.graduationYear
        body.dictionaryObject?["Graduation season"] = user.graduationSeason?.rawValue
        body.dictionaryObject?["Major"] = user.major
        body.dictionaryObject?["Resume"] = user.resume
        body.dictionaryObject?["LinkedIn"] = user.linkedIn
        body.dictionaryObject?["GitHub"] = user.github
        body.dictionaryObject?["Interests"] = user.interests
        body.dictionaryObject?["Comments"] = user.comments
        
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
                    }
                } else {
                    let alert = UIAlertController(title: "Changes could not uploaded", message: "It seems that some of your changes to your profile information could not be automatically uploaded due to lack of internet connection. These changes have been saved locally, but will be lost if you quit and reopen this app while being online, as they will be overwritten.", preferredStyle: .alert)
                    alert.addAction(.init(title: "I Understand", style: .cancel))
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
                }
            case "success":
                User.needsUpload = false
            default:
                print(msg!)
            }
            
        }
        
        task.resume()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if User.needsUpload {
            save(disappearing: true)
        }
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section != 0 { return nil }
        
        let header = UIView()
        
        let title = UILabel()
        title.numberOfLines = 5
        title.lineBreakMode = .byWordWrapping
        title.textAlignment = .center
        title.attributedText = "Let recruiters know more about you from event check-ins by filling out your profile information!".attributedText()
        title.font = .systemFont(ofSize: 16)
        title.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(title)
        
        title.leftAnchor.constraint(equalTo: header.leftAnchor, constant: 30).isActive = true
        title.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -30).isActive = true
        title.topAnchor.constraint(equalTo: header.topAnchor, constant: 20).isActive = true
        title.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -20).isActive = true
        
        return header
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return contentCells.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return contentCells[section].count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == [0, 3] {
            return graduationCellExpanded ? 220 : 0
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        return contentCells[indexPath.section][indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if !cellsEditable { return }
        switch indexPath {
        case [0, 2]:
            view.endEditing(true)
            graduationCellExpanded.toggle()
            refreshGradCell()
        default:
            break
        }
    }
    
    private func refreshGradCell() {
        let chooserCell = contentCells[0][3] as! GraduationYearChooser
        chooserCell.picker.isUserInteractionEnabled = graduationCellExpanded
        
        UIView.animate(withDuration: 0.2) {
            chooserCell.picker.alpha = self.graduationCellExpanded ? 1.0 : 0.0
        }
        
        chooserCell.valueChanged()
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    

}
