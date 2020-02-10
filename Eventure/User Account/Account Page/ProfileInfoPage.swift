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
    private var PROMPT = "Let recruiters know more about you from event check-ins by filling out your profile information!"
    
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

        title = cellsEditable ? "My Profile" : "Registrant Profile"
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInset.top = 5
        tableView.contentInset.bottom = 10
        tableView.keyboardDismissMode = .interactive
        tableView.tintColor = AppColors.main
        tableView.allowsSelection = cellsEditable
    
        view.backgroundColor = AppColors.canvas
        
        let section0: [UITableViewCell] = {
            var section = [UITableViewCell]()
            
            let nameCell = TextFieldCell(parentVC: self)
            nameCell.icon.image = #imageLiteral(resourceName: "name")
            nameCell.textfield.placeholder = "Full Name"
            nameCell.textfield.textContentType = .name
            nameCell.textfield.autocapitalizationType = .words
            nameCell.textfield.enablesReturnKeyAutomatically = true
            nameCell.textfield.text = userProfile.name
            nameCell.textfield.returnKeyType = .done
            
            nameCell.changeHandler = { textfield in
                User.current?.saveEnabled = false
                User.current?.fullName = textfield.text!
                User.current?.saveEnabled = true
                self.needsResave()
            }
            
            nameCell.endEditingHandler = { textfield in
                User.current?.fullName = textfield.text!
                self.save()
            }
            
            nameCell.returnHandler = { textfield in
                textfield.resignFirstResponder()
            }
            
            section.append(nameCell)
            
            if !cellsEditable {
                let emailCell = EmailProfileCell(parentVC: self)
                emailCell.emailLabel.text = userProfile.email
                section.append(emailCell)
            } else {
                section.append(UITableViewCell())
            }
            
            if cellsEditable {
                let majorCell = SettingsItemCell(withAccessory: true)
                majorCell.icon.image = #imageLiteral(resourceName: "major")
                majorCell.titleLabel.text = "Area(s) of study"
                majorCell.valueLabel.numberOfLines = 1
                majorCell.valueLabel.text = "\(userProfile.majors.count) selected"
                section.append(majorCell)
                
            } else {
                let majorCell = MajorPreviewCell()
                majorCell.icon.image = #imageLiteral(resourceName: "major")
                majorCell.setMajor(major: userProfile.majorDescription)
                section.append(majorCell)
            }
            
            let gradCell = cellsEditable ? SettingsItemCell() : SettingsItemCell(withAccessory: false)
            gradCell.icon.image = #imageLiteral(resourceName: "graduation")
            gradCell.titleLabel.text = "Year of Graduation:"
            gradCell.valueLabel.text = userProfile.graduation
            if gradCell.valueLabel.text!.isEmpty {
                gradCell.valueLabel.text = "Not Set"
            } else {
                gradCell.valueLabel.textColor = AppColors.link
            }
            section.append(gradCell)
            
            let chooser = GraduationYearChooser()
            chooser.set(year: userProfile.graduationYear, season: userProfile.graduationSeason)
            chooser.selectionHandler = { year, season in
                User.current?.graduationYear = year
                User.current?.graduationSeason = season
                gradCell.valueLabel.text = User.current?.graduation ?? "Can't edit"
                gradCell.valueLabel.textColor = AppColors.link
                self.needsResave()
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
                self.needsResave()
            }
            
            resumeCell.endEditingHandler = { textfield in
                User.current?.resume = textfield.text!
                self.save()
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
                self.needsResave()
            }
            
            linkedInCell.endEditingHandler = { textfield in
                User.current?.linkedIn = textfield.text!
                self.save()
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
                self.needsResave()
            }
            
            githubCell.endEditingHandler = { textfield in
                User.current?.github = textfield.text!
                self.save()
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
                self.needsResave()
            }
            
            hobbyCell.endEditingHandler = { textfield in
                User.current?.interests = textfield.text!
                self.save()
            }
            
            hobbyCell.returnHandler = { textfield in
                (self.contentCells[3][1] as! CommentCell).commentText.becomeFirstResponder()
            }
            
            section.append(hobbyCell)
            
            let commentCell = CommentCell()
            commentCell.commentText.insertText(userProfile.comments)
            commentCell.commentText.returnKeyType = .default
            commentCell.commentText.isEditable = cellsEditable
            commentCell.textChangeHandler = { [weak self] textView in
                
                User.current?.saveEnabled = false
                User.current?.comments = textView.text
                User.current?.saveEnabled = true
                self?.needsResave()
                
                UIView.performWithoutAnimation {
                    // self?.tableView.beginUpdates()
                    // self?.tableView.endUpdates()
                }
                
                
                if textView.selectedRange.location == textView.text.count {
                    self?.tableView.scrollToRow(at: [3, 1], at: .bottom, animated: false)
                }
            }
            
            
            commentCell.textEndEditingHandler = { text in
                User.current?.comments = text
                self.save()
            }
            
            section.append(commentCell)
            
            return section
        }()
        
        contentCells.append(section3)

        saveBarButton = .init(title: "Saved", style: .done, target: self, action: #selector(saveButtonPressed))
        saveBarButton.isEnabled = false
        if cellsEditable {
            navigationItem.rightBarButtonItem = saveBarButton
        }
    }
    
    func needsResave() {
        saveBarButton.title = "Save"
        saveBarButton.isEnabled = true
    }
    
    func markAsSaved() {
        saveBarButton.title = "Saved"
        saveBarButton.isEnabled = false
    }
    
    @objc private func saveButtonPressed() {
        save()
    }
    
    func save(disappearing: Bool = false, _ onSuccess: (() -> ())? = nil) {
        
        guard let user = User.current else { return }
        guard User.needsUpload else { return }
        guard saveBarButton.isEnabled else { return }
        
        saveBarButton.title = "Saving..."
        saveBarButton.isEnabled = false
        
        user.pushSettings([.fullName, .graduationYear, .graduationSeason, .major, .resumeLink, .linkedIn, .github, .interests, .profileComments]) {
            success in

            if success {
                User.needsUpload = false
                DispatchQueue.main.async {
                    self.markAsSaved()
                    onSuccess?()
                }
            } else {
                self.needsResave()
                let alert = UIAlertController(title: "Changes could not uploaded", message: "It seems that some of your changes to your profile information could not be automatically uploaded due to lack of internet connection. These changes have been saved locally, but will be lost if you quit and reopen this app while being online, as they will be overwritten.", preferredStyle: .alert)
                alert.addAction(.init(title: "OK", style: .cancel))
                self.parentVC?.present(alert, animated: true, completion: nil)
            }
        }
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
        
        if !cellsEditable { return nil }
        
        let header = UIView()
        
        let title = UILabel()
        title.numberOfLines = 5
        title.lineBreakMode = .byWordWrapping
        title.textAlignment = .center
        title.attributedText = PROMPT.attributedText()
        title.textColor = AppColors.prompt
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
        return contentCells.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentCells[section].count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == [0, 4] {
            return graduationCellExpanded ? 220 : 0
        } else if indexPath == [0, 1] {
            return cellsEditable ? 0 : 55
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        return contentCells[indexPath.section][indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath {
        case [0, 2]:
            let ml = MajorList(parentVC: self)
            navigationController?.pushViewController(ml, animated: true)
        case [0, 3]:
            view.endEditing(true)
            graduationCellExpanded.toggle()
            
            if let chooserCell = contentCells[0][4] as? GraduationYearChooser {
                chooserCell.picker.isUserInteractionEnabled = graduationCellExpanded
            
                UIView.animate(withDuration: 0.2) {
                    chooserCell.picker.alpha = self.graduationCellExpanded ? 1.0 : 0.0
                }
                
//                chooserCell.valueChanged(setup: true)
                
            }
            
            tableView.beginUpdates()
            tableView.endUpdates()
            tableView.scrollToRow(at: [0, 4], at: .none, animated: true)
        default:
            break
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let majorCell = contentCells[0][2] as? SettingsItemCell {
            majorCell.valueLabel.text = "\(userProfile.majors.count) selected"
        }
    }
    

}
