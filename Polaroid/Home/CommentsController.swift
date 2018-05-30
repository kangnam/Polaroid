//
//  CommentsController.swift
//  Polaroid
//
//  Created by Kang Nam on 5/17/18.
//  Copyright © 2018 Kang Nam. All rights reserved.
//

import UIKit
import Firebase

class CommentsController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var comments = [Comment]()
    var post: Post?
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Comments"
        collectionView?.backgroundColor = .white
        collectionView?.register(CommentCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .interactive
        
        setupNavigationItem()
        fetchComments()
    }
    
    fileprivate func fetchComments() {
        guard let postId = post?.id else { return }
        let ref = Database.database().reference().child("comments").child(postId)
        ref.observe(.childAdded, with: { (snapshot) in
            guard let commentDict = snapshot.value as? [String:Any] else { return }
            guard let uid = commentDict["uid"] as? String else { return }
            
            Database.fetchUserWithUID(uid, completion: { (user) in
                let comment = Comment(user: user, dict: commentDict)
                self.comments.append(comment)
                self.collectionView?.reloadData()
            })
            
        }) { (err) in
            print("Failed to observe comment:", err)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    fileprivate func setupNavigationItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleBack))
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CommentCell
        if indexPath.item < comments.count {
            cell.comment = comments[indexPath.item]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.item < comments.count {
            let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
            let sizingCell = CommentCell(frame: frame)
            sizingCell.comment = comments[indexPath.item]
            sizingCell.layoutIfNeeded()
            
            let targetSize = CGSize(width: view.frame.width, height: .infinity)
            let estimatedSize = sizingCell.systemLayoutSizeFitting(targetSize)
            
            let height = max(56, estimatedSize.height)
            return CGSize(width: view.frame.width, height: height)
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)
        sendButton.anchor(top: containerView.topAnchor, left: nil, right: containerView.rightAnchor, bottom: containerView.bottomAnchor, topPadding: 0, leftPadding: 0, rightPadding: 12, bottomPadding: 0, width: 50, height: 0)
        
        containerView.addSubview(commentTextField)
        commentTextField.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, right: sendButton.leftAnchor, bottom: containerView.bottomAnchor, topPadding: 0, leftPadding: 12, rightPadding: 12, bottomPadding: 0, width: 0, height: 0)
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        containerView.addSubview(separatorView)
        separatorView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, right: containerView.rightAnchor, bottom: nil, topPadding: 0, leftPadding: 0, rightPadding: 0, bottomPadding: 0, width: 0, height: 0.5)
        
        return containerView
    }()
    
    let commentTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter comment"
        return tf
    }()
    
    @objc func handleSend() {
        print("Inserting comment:", commentTextField.text ?? "")
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let post = self.post else { return }
        guard let id = post.id else { return }
        let postId = id
        let ref = Database.database().reference().child("comments").child(postId).childByAutoId()
        
        let values: [String:Any] = [
            "text": commentTextField.text ?? "",
            "creationDate": Date().timeIntervalSince1970,
            "uid": uid
        ]
        
        ref.updateChildValues(values) { (err, ref) in
            if let err = err {
                print("Failed to insert comment in db:", err)
                return
            }
            print("Successfully inserted comment in db:", values["text"] ?? "")
            self.commentTextField.text = ""
        }
    }
}


