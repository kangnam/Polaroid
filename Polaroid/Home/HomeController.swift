//
//  HomeController.swift
//  Polaroid
//
//  Created by Kang Nam on 5/15/18.
//  Copyright © 2018 Kang Nam. All rights reserved.
//

import UIKit
import Firebase

class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout, HomePostCellDelegate {
        
    let cellId = "cellId"
    
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: SharePhotoController.updateFeedNotificationName, object: nil)
        
        collectionView?.backgroundColor = .groupTableViewBackground
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        setupNavigationItems()
        
        fetchAllPosts()
    }
    
    @objc func handleUpdateFeed() {
        handleRefresh()
    }
    
    @objc func handleRefresh() {
        posts.removeAll()
        fetchAllPosts()
    }
    
    fileprivate func fetchAllPosts() {
        fetchPosts()
        fetchFollowingUsersIds()
    }
    
    fileprivate func fetchFollowingUsersIds() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("following").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let usersIdsDict = snapshot.value as? [String:Any] else { return }
            
            usersIdsDict.forEach({ (key, value) in
                Database.fetchUserWithUID(key, completion: { (user) in
                    self.fetchPostsWithUser(user)
                })
            })
            
        }) { (err) in
            print("Failed to fetch following users ids", err)
        }
    }
    
    fileprivate func fetchPosts() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.fetchUserWithUID(uid) { (user) in
            self.fetchPostsWithUser(user)
        }
    }
    
    fileprivate func fetchPostsWithUser(_ user: User) {
        let ref = Database.database().reference().child("posts").child(user.uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.collectionView?.refreshControl?.endRefreshing()
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            
            dictionaries.forEach({ (key, value) in
                guard let dictionary = value as? [String: Any] else { return }
                var post = Post(user: user, dict: dictionary)
                post.id = key
                
                let allLikesRef = Database.database().reference().child("likes").child(key)
                allLikesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    guard let uid = Auth.auth().currentUser?.uid else { return } // moved here
                    if let allLikesDict = snapshot.value as? [String:Int] {
                        allLikesDict.forEach({ (key, value) in
                            if value == 1 {
                                post.likes += 1
                            }
                        })
                        // guard let uid = Auth.auth().currentUser?.uid else { return }
                        if let value = allLikesDict[uid], value == 1 {
                            post.hasLiked = true
                        } else {
                            post.hasLiked = false
                        }
                    } else {
                        post.hasLiked = false
                    }

                    self.posts.append(post)
                    self.posts.sort(by: { (p1, p2) -> Bool in
                        return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                    })
                    self.collectionView?.reloadData()

                }, withCancel: { (err) in
                    print("Failed to fetch like info for post from db:", err)
                })
            })
        }) { (err) in
            print("Failed to fetch posts:", err)
        }
    }
    
    fileprivate func setupNavigationItems() {
        navigationItem.title = "Polaroid"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "camera3")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleCamera))
        navigationController?.navigationBar.isTranslucent = false
    }
    
    @objc func handleCamera() {
        let cameraController = CameraController()
        present(cameraController, animated: true) {
            print("Sucessfully presented Camera Controller")
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomePostCell
        if indexPath.item < posts.count {
            cell.post = posts[indexPath.item]
            cell.delegate = self
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 40 + 8 + 8
        height += view.frame.width
        height += 50
        height += 72
        return CGSize(width: view.frame.width, height: height)
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
