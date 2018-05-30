//
//  UserProfileHeader.swift
//  Polaroid
//
//  Created by Kang Nam on 5/10/18.
//  Copyright © 2018 Kang Nam. All rights reserved.
//

import UIKit
import Firebase

protocol UserProfileHeaderDelegate {
    func didChangeToGridView()
    func didChangeToListView()
    func didSelectSavedPosts()
    func didSelectEditProfile()
}

class UserProfileHeader: BaseCell {
    
    var delegate: UserProfileHeaderDelegate?
    
    var user: User? {
        didSet {
            guard let profileImageUrl = user?.profileImageUrl else { return }
            profileImageView.loadImage(urlString: profileImageUrl)
            usernameLabel.text = user?.username
            setupEditProfileFollowButton()
        }
    }

    override func setupViews() {
        backgroundColor = .white
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: self.leftAnchor, right: nil, bottom: nil, topPadding: 12, leftPadding: 12, rightPadding: 0, bottomPadding: 0, width: 80, height: 80)
        profileImageView.layer.cornerRadius = 40
        profileImageView.layer.masksToBounds = true
        
        setupBottomToolbar()
        
        addSubview(usernameLabel)
        usernameLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, right: rightAnchor, bottom: gridButton.topAnchor, topPadding: 4, leftPadding: 12, rightPadding: 12, bottomPadding: 4, width: 0, height: 0)
        
        setupUserStatsView()
        
        addSubview(editProfileFollowButton)
        editProfileFollowButton.anchor(top: postsLabel.bottomAnchor, left: postsLabel.leftAnchor, right: followingLabel.rightAnchor, bottom: nil, topPadding: 0, leftPadding: 0, rightPadding: 0, bottomPadding: 0, width: 0, height: 30)
    }
    
    fileprivate func setupUserStatsView() {
        let stackView = UIStackView(arrangedSubviews: [postsLabel, followersLabel, followingLabel])
        addSubview(stackView)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.anchor(top: topAnchor, left: profileImageView.rightAnchor, right: rightAnchor, bottom: nil, topPadding: 12, leftPadding: 12, rightPadding: 12, bottomPadding: 0, width: 0, height: 50)
    }
    
    fileprivate func setupEditProfileFollowButton() {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        guard let userId = user?.uid else { return }
        if userId == currentUID {
            editProfileFollowButton.setTitle("Edit Profile", for: .normal)
            return
        } else {
            let ref = Database.database().reference().child("following").child(currentUID).child(userId)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let isFollowing = snapshot.value as? Int, isFollowing == 1 {
                    self.setupUnfollowStyle()
                } else {
                    self.setupFollowStyle()
                }
            }) { (err) in
                print("Failed to check following status:", err)
            }
        }
    }
    
    fileprivate func setupBottomToolbar() {
        let topDividerView = UIView()
        topDividerView.backgroundColor = .groupTableViewBackground
        
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = .groupTableViewBackground
        
        let stackView = UIStackView(arrangedSubviews: [gridButton, listButton, bookmarkButton])
        
        addSubview(stackView)
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.anchor(top: nil, left: leftAnchor, right: rightAnchor, bottom: bottomAnchor, topPadding: 0, leftPadding: 0, rightPadding: 0, bottomPadding: 0, width: 0, height: 50)
        addSubview(topDividerView)
        topDividerView.anchor(top: stackView.topAnchor, left: leftAnchor, right: rightAnchor, bottom: nil, topPadding: 0, leftPadding: 0, rightPadding: 0, bottomPadding: 0, width: 0, height: 0.5)
        addSubview(bottomDividerView)
        bottomDividerView.anchor(top: nil, left: leftAnchor, right: rightAnchor, bottom: stackView.bottomAnchor, topPadding: 0, leftPadding: 0, rightPadding: 0, bottomPadding: 0, width: 0, height: 0.5)
    }
    
    @objc func handleEditProfileFollow() {
        guard let currentId = Auth.auth().currentUser?.uid else { return }
        guard let userId = user?.uid else { return }
        if editProfileFollowButton.titleLabel?.text == "Edit Profile" {
            delegate?.didSelectEditProfile()
            return
        }
        
        if editProfileFollowButton.titleLabel?.text == "Unfollow" {
            let ref = Database.database().reference().child("following").child(currentId).child(userId)
            ref.removeValue { (err, ref) in
                if let err = err {
                    print("Failed to unfollow user:", err)
                    return
                }
                print("Successfully unfollowed user:", self.user?.username ?? "")
                self.setupEditProfileFollowButton()
            }
        } else {
            let ref = Database.database().reference().child("following").child(currentId)
            let values = [userId: 1]
            ref.updateChildValues(values) { (err, ref) in
                if let err = err {
                    print("Failed to follow user:", err)
                    return
                }
                print("Successfully followed user:", self.user?.username ?? "")
                self.setupUnfollowStyle()
            }
        }
    }
    
    fileprivate func setupUnfollowStyle() {
        self.editProfileFollowButton.setTitle("Unfollow", for: .normal)
        self.editProfileFollowButton.setTitleColor(.black, for: .normal)
        self.editProfileFollowButton.backgroundColor = .white
        self.editProfileFollowButton.layer.borderColor = UIColor.init(white: 0, alpha: 0.2).cgColor
    }
    
    fileprivate func setupFollowStyle() {
        self.editProfileFollowButton.setTitle("Follow", for: .normal)
        self.editProfileFollowButton.setTitleColor(.white, for: .normal)
        self.editProfileFollowButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        self.editProfileFollowButton.layer.borderColor = UIColor.rgb(red: 17, green: 154, blue: 237).cgColor
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = .groupTableViewBackground
        return iv
    }()
    
    lazy var gridButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "grid"), for: .normal)
        button.addTarget(self, action: #selector(changeToGridView), for: .touchUpInside)
        return button
    }()
    
    @objc func changeToGridView() {
        listButton.tintColor = UIColor(white: 0, alpha: 0.2)
        gridButton.tintColor = UIColor.mainBlue()
        bookmarkButton.tintColor = UIColor(white: 0, alpha: 0.2)
        delegate?.didChangeToGridView()
    }
    
    lazy var listButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "list"), for: .normal)
        button.tintColor = UIColor.init(white: 0, alpha: 0.2)
        button.addTarget(self, action: #selector(changeToListView), for: .touchUpInside)
        return button
    }()
    
    @objc func changeToListView() {
        listButton.tintColor = UIColor.mainBlue()
        gridButton.tintColor = UIColor(white: 0, alpha: 0.2)
        bookmarkButton.tintColor = UIColor(white: 0, alpha: 0.2)
        delegate?.didChangeToListView()
    }
    
    lazy var bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "ribbon"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        button.addTarget(self, action: #selector(didSelectSavedPosts), for: .touchUpInside)
        return button
    }()
    
    @objc func didSelectSavedPosts() {
        delegate?.didSelectSavedPosts()
    }
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "username"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    let postsLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "posts", attributes: [.foregroundColor: UIColor.lightGray, .font: UIFont.systemFont(ofSize: 14)]))
        label.attributedText = attributedText
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let followersLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "followers", attributes: [.foregroundColor: UIColor.lightGray, .font: UIFont.systemFont(ofSize: 14)]))
        label.attributedText = attributedText
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let followingLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "following", attributes: [.foregroundColor: UIColor.lightGray, .font: UIFont.systemFont(ofSize: 14)]))
        label.attributedText = attributedText
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    func setAttibutedText(for labelSuffix: String, withInt num: Int) {
        let attributedText = NSMutableAttributedString(string: "\(num)\n", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        switch labelSuffix {
        case "posts":
            attributedText.append(NSAttributedString(string: "posts", attributes: [.foregroundColor: UIColor.lightGray, .font: UIFont.systemFont(ofSize: 14)]))
            postsLabel.attributedText = attributedText
        case "followers":
            attributedText.append(NSAttributedString(string: "followers", attributes: [.foregroundColor: UIColor.lightGray, .font: UIFont.systemFont(ofSize: 14)]))
            followersLabel.attributedText = attributedText
        case "following":
            attributedText.append(NSAttributedString(string: "following", attributes: [.foregroundColor: UIColor.lightGray, .font: UIFont.systemFont(ofSize: 14)]))
            followingLabel.attributedText = attributedText
        default:
            print("error: should never occur")
            return
        }
    }
    
    lazy var editProfileFollowButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .white
        btn.layer.borderColor = UIColor.init(white: 0, alpha: 0.2).cgColor
        btn.layer.cornerRadius = 5
        btn.layer.borderWidth = 1
        btn.addTarget(self, action: #selector(handleEditProfileFollow), for: .touchUpInside)
        return btn
    }()
    
    
    
}


