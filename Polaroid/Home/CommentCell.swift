//
//  CommentCell.swift
//  Polaroid
//
//  Created by Kang Nam on 5/17/18.
//  Copyright © 2018 Kang Nam. All rights reserved.
//

import UIKit

class CommentCell: BaseCell {
    
    var comment: Comment? {
        didSet {
            guard let profileImageUrl = comment?.user.profileImageUrl else { return }
            profileImageView.loadImage(urlString: profileImageUrl)
            guard let creationDate = comment?.creationDate else { return }
            dateLabel.text = creationDate.timeAgoDisplay().uppercased()
            setupAttributedComment()
        }
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = .groupTableViewBackground
        iv.layer.cornerRadius = 20
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let commentLabel: UILabel = {
        let label = UILabel()
        label.text = "comment"
        label.numberOfLines = 0
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.text = "date"
        label.textColor = .lightGray
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        
        backgroundColor = .white
        
        addSubview(profileImageView)
        addSubview(commentLabel)
        addSubview(dateLabel)
        
        profileImageView.anchor(top: topAnchor, left: leftAnchor, right: nil, bottom: nil, topPadding: 8, leftPadding: 4, rightPadding: 0, bottomPadding: 8, width: 40, height: 40)
        
        commentLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, right: rightAnchor, bottom: nil, topPadding: 8, leftPadding: 4, rightPadding: 4, bottomPadding: 0, width: 0, height: 0)
        
        dateLabel.anchor(top: commentLabel.bottomAnchor, left: profileImageView.rightAnchor, right: rightAnchor, bottom: bottomAnchor, topPadding: 0, leftPadding: 4, rightPadding: 4, bottomPadding: 8, width: 0, height: 0)
        
        let separatorView = UIView()
        separatorView.backgroundColor = .groupTableViewBackground
        addSubview(separatorView)
        separatorView.anchor(top: nil, left: profileImageView.rightAnchor, right: rightAnchor, bottom: bottomAnchor, topPadding: 0, leftPadding: 0, rightPadding: 0, bottomPadding: 0, width: 0, height: 0.5)
    }
    
    fileprivate func setupAttributedComment() {
        guard let text = comment?.text else { return }
        guard let username = comment?.user.username else { return }
        let attributedText = NSMutableAttributedString(string: "\(username) ", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 14)]))
        commentLabel.attributedText = attributedText
    }
    
}
