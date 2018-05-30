//
//  UserSearchCell.swift
//  Polaroid
//
//  Created by Kang Nam on 5/16/18.
//  Copyright © 2018 Kang Nam. All rights reserved.
//

import UIKit

class UserSearchCell: BaseCell {
    
    var user: User? {
        didSet {
            guard let profileImageUrl = user?.profileImageUrl else { return }
            profileImageView.loadImage(urlString: profileImageUrl)
            guard let username = user?.username else { return }
            usernameLabel.text = username
        }
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.layer.cornerRadius = 25
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .groupTableViewBackground
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = "Username"
        return label
    }()
    
    let postsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        
        backgroundColor = .white
        
        addSubview(profileImageView)
        addSubview(usernameLabel)
//        addSubview(postsLabel)
        
        profileImageView.anchor(top: topAnchor, left: leftAnchor, right: nil, bottom: bottomAnchor, topPadding: 8, leftPadding: 8, rightPadding: 0, bottomPadding: 8, width: 50, height: 50)
        usernameLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, right: rightAnchor, bottom: bottomAnchor, topPadding: 0, leftPadding: 8, rightPadding: 0, bottomPadding: 0, width: 0, height: 0)
        
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        addSubview(separatorView)
        separatorView.anchor(top: nil, left: profileImageView.rightAnchor, right: rightAnchor, bottom: bottomAnchor, topPadding: 0, leftPadding: 0, rightPadding: 0, bottomPadding: 0, width: 0, height: 0.5)
    }
    
}
