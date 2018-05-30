//
//  UserProfileController.swift
//  Polaroid
//
//  Created by Kang Nam on 5/10/18.
//  Copyright © 2018 Kang Nam. All rights reserved.
//

import UIKit
import Firebase

class UserProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UserProfileHeaderDelegate, HomePostCellDelegate {
    
    
    
    var isGridView: Bool = true
//    var isFinishedPaging: Bool = false
    
    var user: User?
    var userId: String?
    var posts = [Post]()
    
    let cellId = "cellId"
    let headerId = "headerId"
    let homePostCellId = "homePostCellId"
    
    fileprivate var header: UserProfileHeader?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: homePostCellId)
        collectionView?.backgroundColor = .white
        navigationController?.navigationBar.tintColor = .black
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        
        setupLogOutButton()
        
        fetchUser()
        fetchFollowingInfo()
        fetchFollowersInfo()
    }
    
    @objc func handleRefresh() {
        if let uid = user?.uid {
            print("refreshing for uid:", uid)
            fetchAllFollowInfo()
        } else {
            self.collectionView?.refreshControl?.endRefreshing()
        }
    }
    
    fileprivate func fetchAllFollowInfo() {
        fetchFollowingInfo()
        fetchFollowersInfo()
        self.collectionView?.refreshControl?.endRefreshing()
    }
    
    fileprivate func fetchOrderedPosts() {
        guard let uid = self.user?.uid else { return }
        let ref = Database.database().reference().child("posts").child(uid)
        ref.queryOrdered(byChild: "creationDate").observe(.childAdded, with: { (snapshot) in
            guard let dict = snapshot.value as? [String:Any] else { return }
            guard let user = self.user else { return }
            var post = Post(user: user, dict: dict)
            let postId = snapshot.key
            post.id = postId
            
            let allLikesRef = Database.database().reference().child("likes").child(postId)
            allLikesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let allLikesDict = snapshot.value as? [String:Int] {
                    allLikesDict.forEach({ (key, value) in
                        if value == 1 {
                            post.likes += 1
                        }
                    })
                    guard let uid = Auth.auth().currentUser?.uid else { return }
                    if let value = allLikesDict[uid], value == 1 {
                        post.hasLiked = true
                    } else {
                        post.hasLiked = false
                    }
                } else {
                    post.hasLiked = false
                }
                
                self.posts.insert(post, at: 0)
                
                if let header = self.header {
                    header.setAttibutedText(for: "posts", withInt: self.posts.count)
                }
                
                self.collectionView?.reloadData()
                
            }, withCancel: { (err) in
                print("Failed to fetch likes for post:", err)
            })
            
        }) { (err) in
            print("Failed to fetch ordered posts:", err)
        }
    }
    
    fileprivate func fetchFollowingInfo() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("following").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dict = snapshot.value as? [String:Any] else { return }
            let followingNum = dict.values.count
            if let header = self.header {
                header.setAttibutedText(for: "following", withInt: followingNum)
                self.collectionView?.reloadData()
            }
            
        }) { (err) in
            print("Failed to fetch followers info from db:", err)
        }
    }
    
    fileprivate func fetchFollowersInfo() {
        let uid = userId ?? (Auth.auth().currentUser?.uid ?? "")
        let ref = Database.database().reference().child("following")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            var followers: Int = 0
            guard let dictionaries = snapshot.value as? [String:[String:Int]] else { return }
            dictionaries.forEach({ (key, followingDict) in
                followingDict.forEach({ (userId, isFollowingVal) in
                    if userId == uid {
                        followers += 1
                    }
                })
            })
            if let header = self.header {
                header.setAttibutedText(for: "followers", withInt: followers)
                self.collectionView?.reloadData()
            }
            
        }) { (err) in
            print("Failed to fetch followers info from db:", err)
        }
    }
    
    fileprivate func fetchPostsWithUser() {
        guard let uid = self.user?.uid else { return }
        let ref = Database.database().reference().child("posts").child(uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            
            dictionaries.forEach({ (key, value) in
                guard let dictionary = value as? [String: Any] else { return }
                guard let user = self.user else { return }
                var post = Post(user: user, dict: dictionary)
                post.id = key
                
                let allLikesRef = Database.database().reference().child("likes").child(key)
                allLikesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let allLikesDict = snapshot.value as? [String:Int] {
                        allLikesDict.forEach({ (key, value) in
                            if value == 1 {
                                post.likes += 1
                            }
                        })
                        guard let uid = Auth.auth().currentUser?.uid else { return }
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
    
    fileprivate func fetchUser() {
        
        let uid = userId ?? (Auth.auth().currentUser?.uid ?? "")
        
        Database.fetchUserWithUID(uid) { (user) in
            self.user = user
            self.navigationItem.title = self.user?.username
            self.collectionView?.reloadData()
            
            self.fetchOrderedPosts()
            // pagination
            // self.paginatePosts()
        }
    }
    
    fileprivate func setupLogOutButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "gear")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLogOut))
    }
    
    @objc func handleLogOut() {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            do {
                try Auth.auth().signOut()
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                self.present(navController, animated: true, completion: nil)
            } catch let err {
                print("Failed to sign out:", err)
                return
            }
        }))
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        navigationController?.present(controller, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! UserProfileHeader
        header.user = self.user
        header.delegate = self
        self.header = header
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // pagination
//        if indexPath.item == self.posts.count - 1 && !isFinishedPaging {
//            paginatePosts()
//        }

        if isGridView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfilePhotoCell
            if indexPath.item < posts.count {
                cell.post = posts[indexPath.item]
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homePostCellId, for: indexPath) as! HomePostCell
            if indexPath.item < posts.count {
                cell.post = posts[indexPath.item]
                cell.delegate = self
            }
            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isGridView {
            let detailPostController = DetailPostController(collectionViewLayout: UICollectionViewFlowLayout())
            let post = posts[indexPath.item]
            detailPostController.posts.append(post)
            self.navigationController?.pushViewController(detailPostController, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isGridView {
            return CGSize(width: view.frame.width/3-1, height: view.frame.width/3-1)
        } else {
            var height: CGFloat = 40 + 8 + 8
            height += view.frame.width
            height += 50
            height += 72
            return CGSize(width: view.frame.width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func didChangeToListView() {
        isGridView = false
        collectionView?.reloadData()
    }
    
    func didChangeToGridView() {
        isGridView = true
        collectionView?.reloadData()
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
    
    func didSelectSavedPosts() {
        let savedPostsController = SavedPostsController(collectionViewLayout: UICollectionViewFlowLayout())
        navigationController?.pushViewController(savedPostsController, animated: true)
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
    
    func didSelectEditProfile() {
        let controller = EditProfileController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - ONLY FOR PAGINATION
    /*
    fileprivate func paginatePosts() {
        guard let uid = user?.uid else { return }
        let ref = Database.database().reference().child("posts").child(uid)
        var query = ref.queryOrdered(byChild: "creationDate")
        
        if posts.count > 0 {
            guard let endingValue = posts.last?.creationDate.timeIntervalSince1970 else { return }
            query = query.queryEnding(atValue: endingValue)
        }
        let queryLimit: UInt = 3
        query.queryLimited(toLast: queryLimit).observeSingleEvent(of: .value, with: { (snapshot) in
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            allObjects.reverse()
            if allObjects.count < queryLimit {
                self.isFinishedPaging = true
            }
            if self.posts.count > 0 && allObjects.count > 0 {
                allObjects.removeFirst()
            }
            allObjects.forEach({ (snapshot) in
                guard let user = self.user else { return }
                guard let dict = snapshot.value as? [String:Any] else { return }
                var post = Post(user: user, dict: dict)
                post.id = snapshot.key
                self.posts.append(post)
            })
            self.collectionView?.reloadData()
        }) { (err) in
            print("Failed to fetch posts from db using pagination:", err)
        }
    }
    */
    // END OF PAGINATION
    
}


