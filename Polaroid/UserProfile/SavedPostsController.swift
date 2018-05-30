//
//  SavedPostsController.swift
//  Polaroid
//
//  Created by Kang Nam on 5/24/18.
//  Copyright © 2018 Kang Nam. All rights reserved.
//

import UIKit
import Firebase

class SavedPostsController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        collectionView?.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellId)
        navigationController?.navigationBar.tintColor = .black
        navigationItem.title = "Saved"
        
        fetchSavedPosts()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfilePhotoCell
        cell.post = posts[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width/3 - 1, height: view.frame.width/3 - 1)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailPostController = DetailPostController(collectionViewLayout: UICollectionViewFlowLayout())
        detailPostController.posts.append(posts[indexPath.item])
        navigationController?.pushViewController(detailPostController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    fileprivate func fetchSavedPosts() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("saved").child(uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot.value ?? "")
            if let savedPostsDict = snapshot.value as? [String:String] {
                
                savedPostsDict.forEach({ (postId, uid) in
                    
                    Database.fetchUserWithUID(uid, completion: { (user) in
                        let postRef = Database.database().reference().child("posts").child(uid).child(postId)
                        postRef.observeSingleEvent(of: .value, with: { (snapshot) in
                            
                            guard let postDict = snapshot.value as? [String:Any] else { return }
                            var post = Post(user: user, dict: postDict)
                            post.id = postId
                            
                            self.posts.append(post)
                            self.posts.sort(by: { (p1, p2) -> Bool in
                                return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                            })
                            self.collectionView?.reloadData()
                            
                        }, withCancel: { (err) in
                            print("Failed to fetch post from db:", err)
                        })
                    })
                })
            }
        }) { (err) in
            print("Failed to fetch saved posts from db:", err)
        }
    }
    
}
