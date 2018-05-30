//
//  DetailPostController.swift
//  Polaroid
//
//  Created by Kang Nam on 5/24/18.
//  Copyright © 2018 Kang Nam. All rights reserved.
//

import UIKit
import Firebase

class DetailPostController: UICollectionViewController, UICollectionViewDelegateFlowLayout, HomePostCellDelegate {
    
    let cellId = "cellId"
    
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.backgroundColor = .white
        navigationItem.title = "Photo"
        navigationController?.navigationBar.tintColor = .black
        
        fetchDetailPost()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomePostCell
        cell.post = posts[indexPath.item]
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 40 + 8 + 8
        height += view.frame.width
        height += 50
        height += 72
        return CGSize(width: view.frame.width, height: height)
    }
    
    fileprivate func fetchDetailPost() {
        guard let detailPost = posts.first else { return }
        let user = detailPost.user
        let posterUid = detailPost.user.uid
        guard let postId = detailPost.id else { return }
        
        self.posts.removeAll()
        
        Database.database().reference().child("posts").child(posterUid).child(postId).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dict = snapshot.value as? [String:Any] else { return }
            var post = Post(user: user, dict: dict)
            let pid: String = snapshot.key
            post.id = pid
            
            let likesRef = Database.database().reference().child("likes").child(pid)
            likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let uid = Auth.auth().currentUser?.uid else { return }
                if let likesDict = snapshot.value as? [String:Int] {
                    likesDict.forEach({ (key, val) in
                        if val == 1 {
                            post.likes += 1
                        }
                    })
                    
                    if let likeValue = likesDict[uid], likeValue == 1 {
                        post.hasLiked = true
                    } else {
                        post.hasLiked = false
                    }
                } else {
                    post.hasLiked = false
                }
                
                self.posts.append(post)
                self.collectionView?.reloadData()
                
            }, withCancel: { (err) in
                print("Failed to fetch likes info for detail post from db:", err)
            })
        }) { (err) in
            print("Failed to fetch detail post from db:", err)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func didLike(for cell: HomePostCell) {
        guard let indexPath = collectionView?.indexPath(for: cell) else { return }
        
        var post = self.posts[indexPath.item]
        guard let postId = post.id else { return }
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("likes").child(postId)
        let values: [String:Any] = [uid: post.hasLiked == true ? 0 : 1]
        ref.updateChildValues(values) { (err, _) in
            if let err = err {
                print("Failed to like post:", err)
                return
            }
            print("Succesfully liked post:", uid)
            post.hasLiked = !post.hasLiked
            self.posts[indexPath.item] = post
            self.collectionView?.reloadItems(at: [indexPath])
        }
    }
    
    func didSelectComment(post: Post) {
        let commentsController = CommentsController(collectionViewLayout: UICollectionViewFlowLayout())
        commentsController.post = post
        navigationController?.pushViewController(commentsController, animated: true)
    }
    
    func didSendMessage(post: Post) {
        print("didSendMessage:")
    }
    
    func didSavePost(post: Post) {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("saved").child(uid)

        guard let postId = post.id else { return }

        let values = [postId: post.user.uid]
        ref.updateChildValues(values) { (err, ref) in
            if let err = err {
                print("Failed to put save post data in db:", err)
                return
            }
            print("Successfully put save post in db")
        }
    }
    
    func didSelectOptions(post: Post) {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "Report Post", style: .destructive, handler: { (_) in
            
            let confirmationController = UIAlertController(title: "Post Reported", message: "We take reports very seriously and will look into this matter for you", preferredStyle: .alert)
            confirmationController.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (alert) in
                confirmationController.dismiss(animated: true, completion: {
                    controller.dismiss(animated: true, completion: nil)
                })
            }))
            
            let ref = Database.database().reference().child("reports").childByAutoId()
            guard let uid = Auth.auth().currentUser?.uid else { return }
            guard let postId = post.id else { return }
            let values: [String:Any] = [
                "uid": uid,
                "creationDate": Date().timeIntervalSince1970,
                "post": postId
            ]
            ref.updateChildValues(values, withCompletionBlock: { (err, _) in
                if let err = err {
                    print("Failed to report post:", err)
                    return
                }
                print("Successfully reported post:", values["post"] as? String ?? "")
                self.present(confirmationController, animated: true, completion: nil)
            })
            
        }))
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        navigationController?.present(controller, animated: true, completion: nil)
    }
        
}
