//
//  HomePostCell.swift
//  Polaroid
//
//  Created by Kang Nam on 5/15/18.
//  Copyright © 2018 Kang Nam. All rights reserved.
//

import UIKit

protocol HomePostCellDelegate {
    
    func didLike(for cell: HomePostCell)
    func didSelectComment(post: Post)
    func didSavePost(post: Post)
    func didSelectOptions(post: Post)
}

class HomePostCell: BaseCell {
    
    var delegate: HomePostCellDelegate?
    
    var post: Post? {
        didSet {
            guard let profileImageUrl = post?.user.profileImageUrl else { return }
            profileImageView.loadImage(urlString: profileImageUrl)
            guard let username = post?.user.username else { return }
            usernameLabel.text = username
            guard let postImageUrl = post?.imageUrl else { return }
            photoImageView.loadImage(urlString: postImageUrl)
            setupAttributedCaption()
            guard let creationDate = post?.creationDate else { return }
            dateLabel.text = creationDate.timeAgoDisplay().uppercased()
            likeButton.setImage(post?.hasLiked == true ? UIImage(named: "like_selected")?.withRenderingMode(.alwaysTemplate) : UIImage(named: "like_unselected")?.withRenderingMode(.alwaysOriginal), for: .normal)
            likesLabel.text = post?.likes.likeDisplay()
        }
    }
    
    fileprivate func setupAttributedCaption() {
        guard let caption = post?.caption else { return }
        guard let username = post?.user.username else { return }
        let attributedText = NSMutableAttributedString(string: "\(username) ", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: caption, attributes: [.font: UIFont.systemFont(ofSize: 14)]))
        captionLabel.attributedText = attributedText
    }
    
    override func setupViews() {
        super.setupViews()
        backgroundColor = .white
        
        addSubview(profileImageView)
        addSubview(photoImageView)
        addSubview(optionsButton)
        addSubview(usernameLabel)
        
        profileImageView.anchor(top: topAnchor, left: leftAnchor, right: nil, bottom: nil, topPadding: 8, leftPadding: 8, rightPadding: 0, bottomPadding: 0, width: 40, height: 40)
        photoImageView.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, right: rightAnchor, bottom: nil, topPadding: 8, leftPadding: 0, rightPadding: 0, bottomPadding: 0, width: 0, height: 0)
        photoImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        optionsButton.anchor(top: topAnchor, left: nil, right: rightAnchor, bottom: photoImageView.topAnchor, topPadding: 0, leftPadding: 0, rightPadding: 0, bottomPadding: 0, width: 44, height: 0)
        usernameLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, right: optionsButton.leftAnchor, bottom: photoImageView.topAnchor, topPadding: 0, leftPadding: 8, rightPadding: 0, bottomPadding: 0, width: 0, height: 0)
        
        setupActionButtons()
        
        addSubview(likesLabel)
        likesLabel.anchor(top: likeButton.bottomAnchor, left: leftAnchor, right: rightAnchor, bottom: nil, topPadding: 0, leftPadding: 8, rightPadding: 8, bottomPadding: 0, width: 0, height: 0)
        
        addSubview(captionLabel)
        captionLabel.anchor(top: likesLabel.bottomAnchor, left: leftAnchor, right: rightAnchor, bottom: nil, topPadding: 4, leftPadding: 8, rightPadding: 8, bottomPadding: 0, width: 0, height: 0)
        
        addSubview(dateLabel)
        dateLabel.anchor(top: captionLabel.bottomAnchor, left: leftAnchor, right: rightAnchor, bottom: nil, topPadding: 4, leftPadding: 8, rightPadding: 8, bottomPadding: 0, width: 0, height: 0)
    }
    
    fileprivate func setupActionButtons() {
        let stackView = UIStackView(arrangedSubviews: [likeButton, commentButton])
        stackView.distribution = .fillEqually
        addSubview(stackView)
        stackView.anchor(top: photoImageView.bottomAnchor, left: leftAnchor, right: nil, bottom: nil, topPadding: 0, leftPadding: 8, rightPadding: 0, bottomPadding: 0, width: 80, height: 50)
        
        addSubview(savePostButton)
        savePostButton.anchor(top: photoImageView.bottomAnchor, left: nil, right: rightAnchor, bottom: nil, topPadding: 0, leftPadding: 0, rightPadding: 8, bottomPadding: 0, width: 40, height: 40)
    }
    
    @objc func handleLike() {
        delegate?.didLike(for: self)
    }
    
    @objc func handleComment() {
        guard let post = post else { return }
        delegate?.didSelectComment(post: post)
    }
    
    @objc func handleSavePost() {
        guard let post = post else { return }
        delegate?.didSavePost(post: post)
    }
    
    let photoImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = .groupTableViewBackground
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.layer.cornerRadius = 20
        iv.backgroundColor = .groupTableViewBackground
        iv.clipsToBounds = true
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "username"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .black
        return label
    }()
    
    lazy var optionsButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("•••", for: .normal)
        btn.setTitleColor(.gray, for: .normal)
        btn.addTarget(self, action: #selector(handleOptions), for: .touchUpInside)
        return btn
    }()
    
    @objc func handleOptions() {
        guard let post = post else { return }
        delegate?.didSelectOptions(post: post)
    }
    
    lazy var likeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "like_unselected")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.tintColor = UIColor.hex(0xB71C1C)
        btn.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        return btn
    }()
    
    lazy var commentButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "comment")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        return btn
    }()
    
    lazy var savePostButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "ribbon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(handleSavePost), for: .touchUpInside)
        return btn
    }()
    
    let likesLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = "0 likes"
        return label
    }()
    
    let captionLabel: UILabel = {
        let label = UILabel()
        label.text = "caption"
        label.numberOfLines = 0
        return label
    }()
    
    let dateLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor.lightGray
        label.text = "unavailable".uppercased()
        return label
    }()
    
}
