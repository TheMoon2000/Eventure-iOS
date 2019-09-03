//
//  AboutEventure.swift
//  Eventure
//
//  Created by jeffhe on 2019/9/3.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import Foundation
import UIKit

class AboutEventure: UIViewController {
    
    let titleLabel: UILabel! = {
        let label = UILabel()
        label.numberOfLines = 10
        label.text = "About Eventure"
        label.font = .systemFont(ofSize: 22, weight: .medium)
        label.textColor = .gray
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    let textLabel: UILabel! = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "William Shakespeare was an English poet and playwright who is considered one of the greatest writers to ever use the English language. He is also the most famous playwright in the world, with his plays being translated in over 50 languages and performed across the globe for audiences of all ages. Known colloquially as The Bard or The Bard of Avon, Shakespeare was also an actor and the creator of the Globe Theatre, a historical theatre, and company that is visited by hundreds of thousands of tourists every year. His works span tragedy, comedy, and historical works, both in poetry and prose. And although the man is the most-recognized playwright in the world, very little of his life is actually known. No known autobiographical letters or diaries have survived to modern day, and with no surviving descendants, Shakespeare is a figure both of magnificent genius and mystery. This has led to many interpretations of his life and works, creating a legend out of the commoner from Stratford-upon-Avon who rose to prominence and in the process wrote many of the seminal works that provide the foundation for the current English language. William Shakespeare was an English poet and playwright who is considered one of the greatest writers to ever use the English language. He is also the most famous playwright in the world, with his plays being translated in over 50 languages and performed across the globe for audiences of all ages. Known colloquially as The Bard or The Bard of Avon, Shakespeare was also an actor and the creator of the Globe Theatre, a historical theatre, and company that is visited by hundreds of thousands of tourists every year. His works span tragedy, comedy, and historical works, both in poetry and prose. And although the man is the most-recognized playwright in the world, very little of his life is actually known. No known autobiographical letters or diaries have survived to modern day, and with no surviving descendants, Shakespeare is a figure both of magnificent genius and mystery. This has led to many interpretations of his life and works, creating a legend out of the commoner from Stratford-upon-Avon who rose to prominence and in the process wrote many of the seminal works that provide the foundation for the current English language.William Shakespeare was an English poet and playwright who is considered one of the greatest writers to ever use the English language. He is also the most famous playwright in the world, with his plays being translated in over 50 languages and performed across the globe for audiences of all ages. Known colloquially as The Bard or The Bard of Avon, Shakespeare was also an actor and the creator of the Globe Theatre, a historical theatre, and company that is visited by hundreds of thousands of tourists every year. His works span tragedy, comedy, and historical works, both in poetry and prose. And although the man is the most-recognized playwright in the world, very little of his life is actually known. No known autobiographical letters or diaries have survived to modern day, and with no surviving descendants, Shakespeare is a figure both of magnificent genius and mystery. This has led to many interpretations of his life and works, creating a legend out of the commoner from Stratford-upon-Avon who rose to prominence and in the process wrote many of the seminal works that provide the foundation for the current English language.William Shakespeare was an English poet and playwright who is considered one of the greatest writers to ever use the English language. He is also the most famous playwright in the world, with his plays being translated in over 50 languages and performed across the globe for audiences of all ages. Known colloquially as The Bard or The Bard of Avon, Shakespeare was also an actor and the creator of the Globe Theatre, a historical theatre, and company that is visited by hundreds of thousands of tourists every year. His works span tragedy, comedy, and historical works, both in poetry and prose. And although the man is the most-recognized playwright in the world, very little of his life is actually known. No known autobiographical letters or diaries have survived to modern day, and with no surviving descendants, Shakespeare is a figure both of magnificent genius and mystery. This has led to many interpretations of his life and works, creating a legend out of the commoner from Stratford-upon-Avon who rose to prominence and in the process wrote many of the seminal works that provide the foundation for the current English language.William Shakespeare was an English poet and playwright who is considered one of the greatest writers to ever use the English language. He is also the most famous playwright in the world, with his plays being translated in over 50 languages and performed across the globe for audiences of all ages. Known colloquially as The Bard or The Bard of Avon, Shakespeare was also an actor and the creator of the Globe Theatre, a historical theatre, and company that is visited by hundreds of thousands of tourists every year. His works span tragedy, comedy, and historical works, both in poetry and prose. And although the man is the most-recognized playwright in the world, very little of his life is actually known. No known autobiographical letters or diaries have survived to modern day, and with no surviving descendants, Shakespeare is a figure both of magnificent genius and mystery. This has led to many interpretations of his life and works, creating a legend out of the commoner from Stratford-upon-Avon who rose to prominence and in the process wrote many of the seminal works that provide the foundation for the current English language.William Shakespeare was an English poet and playwright who is considered one of the greatest writers to ever use the English language. He is also the most famous playwright in the world, with his plays being translated in over 50 languages and performed across the globe for audiences of all ages. Known colloquially as The Bard or The Bard of Avon, Shakespeare was also an actor and the creator of the Globe Theatre, a historical theatre, and company that is visited by hundreds of thousands of tourists every year. His works span tragedy, comedy, and historical works, both in poetry and prose. And although the man is the most-recognized playwright in the world, very little of his life is actually known. No known autobiographical letters or diaries have survived to modern day, and with no surviving descendants, Shakespeare is a figure both of magnificent genius and mystery. This has led to many interpretations of his life and works, creating a legend out of the commoner from Stratford-upon-Avon who rose to prominence and in the process wrote many of the seminal works that provide the foundation for the current English language."
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .gray
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    let icon: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = MAIN_TINT
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(named: "largeicon")
    
        return iv
    }()
    
    
    let scrollView: UIScrollView = {
        let v = UIScrollView()
        v.alwaysBounceVertical = true
        v.contentInsetAdjustmentBehavior = .always
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        return v
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .init(white: 0.92, alpha: 1)
        
        self.view.addSubview(scrollView)
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        scrollView.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 50).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        
        scrollView.addSubview(icon)
        icon.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 50).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 150).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 150).isActive = true
        icon.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        
        scrollView.addSubview(textLabel)
        textLabel.topAnchor.constraint(equalTo: icon.bottomAnchor,constant: 50).isActive = true
        textLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        textLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        //textLabel.heightAnchor.constraint(equalToConstant: 1000).isActive = true
        
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: 2900)
    }
    
}
