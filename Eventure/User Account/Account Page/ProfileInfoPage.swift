//
//  ProfileInfoPage.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/31.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class ProfileInfoPage: UITableViewController {
    
    private var graduationCellExpanded = false
    private var contentCells = [[UITableViewCell]]()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "My Profile"
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInset.top = 5
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
            nameCell.textfield.text = User.current?.fullName
            
            nameCell.endEditingHandler = { textfield in
                User.current?.fullName = textfield.text!
            }
            
            nameCell.returnHandler = { textfield in
                (self.contentCells[0][1] as! TextFieldCell).textfield.becomeFirstResponder()
            }
            
            section.append(nameCell)
            
            let majorCell = TextFieldCell(parentVC: self)
            majorCell.icon.image = #imageLiteral(resourceName: "major")
            majorCell.textfield.placeholder = "(Intended) Major(s) and minor(s)"
            majorCell.textfield.enablesReturnKeyAutomatically = true
            majorCell.textfield.returnKeyType = .next
            majorCell.textfield.text = User.current?.major
            
            majorCell.endEditingHandler = { textfield in
                User.current?.major = textfield.text!
            }
            
            majorCell.returnHandler = { textfield in
                textfield.resignFirstResponder()
                if User.current?.yearOfGraduation == nil {
                    self.graduationCellExpanded = true
                    self.refreshGradCell()
                }
            }
            
            section.append(majorCell)
            
            let gradCell = SettingsItemCell()
            gradCell.icon.image = #imageLiteral(resourceName: "graduation")
            gradCell.titleLabel.text = "Year of Graduation"
            gradCell.valueLabel.text = User.current!.graduation
            section.append(gradCell)
            
            let chooser = GraduationYearChooser()
            chooser.selectionHandler = { year, season in
                User.current?.yearOfGraduation = year
                User.current?.seasonOfGraduation = season
                gradCell.valueLabel.text = User.current!.graduation
            }
            section.append(chooser)
            
            return section
        }()
        
        
        contentCells.append(section0)
        
        let section1: [UITableViewCell] = {
            var section = [UITableViewCell]()
            
            let resumeCell = TextFieldCell(parentVC: self)
            resumeCell.textfield.placeholder = "Link to resume (recommended)"
            resumeCell.icon.image = #imageLiteral(resourceName: "resume")
            resumeCell.linkDetectionEnabled = true
            resumeCell.textfield.keyboardType = .URL
            resumeCell.textfield.autocapitalizationType = .none
            resumeCell.textfield.enablesReturnKeyAutomatically = true
            resumeCell.textfield.text = User.current?.resume
            
            resumeCell.endEditingHandler = { textfield in
                User.current?.resume = textfield.text!
            }
            
            resumeCell.returnHandler = { textfield in
                (self.contentCells[2][0] as! TextFieldCell).textfield.becomeFirstResponder()
            }
            
            section.append(resumeCell)
            
            if let resume = User.current?.resume {
                resumeCell.textfield.text = resume
            }
            
            return section
        }()
        
        contentCells.append(section1)
        
        let section2: [UITableViewCell] = {
            var section = [UITableViewCell]()
            
            let linkedInCell = TextFieldCell(parentVC: self)
            linkedInCell.textfield.placeholder = "LinkedIn page (optional)"
            linkedInCell.icon.image = #imageLiteral(resourceName: "linkedin")
            linkedInCell.linkDetectionEnabled = true
            linkedInCell.textfield.keyboardType = .URL
            linkedInCell.textfield.autocapitalizationType = .none
            linkedInCell.textfield.text = User.current?.linkedIn
            
            linkedInCell.endEditingHandler = { textfield in
                User.current?.linkedIn = textfield.text!
            }
            
            linkedInCell.returnHandler = { textfield in
                (self.contentCells[2][1] as! TextFieldCell).textfield.becomeFirstResponder()
            }
            
            section.append(linkedInCell)
            
            
            let githubCell = TextFieldCell(parentVC: self)
            githubCell.textfield.placeholder = "GitHub page (optional)"
            githubCell.icon.image = #imageLiteral(resourceName: "github")
            githubCell.linkDetectionEnabled = true
            githubCell.textfield.keyboardType = .URL
            githubCell.textfield.autocapitalizationType = .none
            githubCell.textfield.text = User.current?.github
            
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
            hobbyCell.textfield.placeholder = "Skills and interests (optional)"
            hobbyCell.textfield.text = User.current?.interests
            
            hobbyCell.endEditingHandler = { textfield in
                User.current?.interests = textfield.text!
            }
            
            section.append(hobbyCell)
            
            return section
        }()
        
        contentCells.append(section3)
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
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return [nil, "Resume", "Platforms", "Others"][section]
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
