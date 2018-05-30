//
//  SharePhotoController.swift
//  Polaroid
//
//  Created by Kang Nam on 5/14/18.
//  Copyright © 2018 Kang Nam. All rights reserved.
//

import UIKit
import Firebase

class SharePhotoController: UIViewController, UITextViewDelegate {
    
    var image: UIImage? {
        didSet {
            if let image = image {
                imageView.image = image
            }
        }
    }
    
    static let updateFeedNotificationName = Notification.Name(rawValue: "UpdateFeed")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .groupTableViewBackground
        
        setupNavigationButtons()
        setupImageAndTextViews()
    }
    
    fileprivate func setupNavigationButtons() {
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleBack))
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
        let shareButton = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(handleShare))
        shareButton.tintColor = .black
        navigationItem.rightBarButtonItem = shareButton
    }
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .red
        return iv
    }()
    
    lazy var textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.backgroundColor = .clear
        tv.textColor = .black
        tv.delegate = self
        return tv
    }()
    
    func textViewDidChange(_ textView: UITextView) {
        let isFormValid = textView.text?.count ?? 0 > 0
        if isFormValid {
            navigationItem.rightBarButtonItem?.isEnabled = true
            navigationItem.rightBarButtonItem?.tintColor = UIColor.hex(0x1E88E5)
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
            navigationItem.rightBarButtonItem?.tintColor = .black
        }
    }
    
    fileprivate func setupImageAndTextViews() {
        let containerView = UIView()
        view.addSubview(containerView)
        containerView.backgroundColor = .white
        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: nil, topPadding: 0, leftPadding: 0, rightPadding: 0, bottomPadding: 0, width: 0, height: 100)
        
        containerView.addSubview(imageView)
        imageView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, right: nil, bottom: containerView.bottomAnchor, topPadding: 8, leftPadding: 8, rightPadding: 0, bottomPadding: 8, width: 84, height: 0)
        
        containerView.addSubview(textView)
        textView.anchor(top: containerView.topAnchor, left: imageView.rightAnchor, right: containerView.rightAnchor, bottom: containerView.bottomAnchor, topPadding: 0, leftPadding: 4, rightPadding: 0, bottomPadding: 0, width: 0, height: 0)
        textViewDidChange(textView)
    }
    
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleShare() {
        guard let image = image else { return }
        guard let uploadData = UIImageJPEGRepresentation(image, 0.4) else { return }
        guard let caption = textView.text, caption.count > 0 else { return }
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        let filename = UUID().uuidString
        Storage.storage().reference().child("posts").child(filename).putData(uploadData, metadata: nil) { (metadata, err) in
            if let err = err {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Failed to upload post image:", err)
                return
            }
            guard let imageUrl = metadata?.downloadURL()?.absoluteString else { return }
            print("Successfully uploaded post image:", imageUrl)
            self.saveToDatabaseWithImageUrl(imageUrl)
        }
    }
    
    fileprivate func saveToDatabaseWithImageUrl(_ imageUrl: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let postImage = image else { return }
        guard let caption = textView.text, caption.count > 0 else { return }
        
        let usersRefPost = Database.database().reference().child("posts").child(uid)
        let ref = usersRefPost.childByAutoId()
        
        let values: [String:Any] = [
            "imageUrl": imageUrl,
            "creationDate": Date().timeIntervalSince1970,
            "imageWidth": postImage.size.width,
            "imageHeight": postImage.size.height,
            "caption": caption
        ]
        
        ref.updateChildValues(values) { (err, ref) in
            if let err = err {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Failed to save post to db:", err)
                return
            }
            print("Successfully saved post to db:", imageUrl)
            self.dismiss(animated: true, completion: nil)
            
            
            NotificationCenter.default.post(name: SharePhotoController.updateFeedNotificationName, object: nil)
        }
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
