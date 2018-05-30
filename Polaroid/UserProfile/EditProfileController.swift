//
//  EditProfileController.swift
//  Polaroid
//
//  Created by Kang Nam on 5/24/18.
//  Copyright © 2018 Kang Nam. All rights reserved.
//

import UIKit
import Firebase

class EditProfileController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(deleteButton)
        deleteButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: nil, topPadding: 20, leftPadding: 40, rightPadding: 40, bottomPadding: 0, width: 0, height: 40)
        
    }
    
    lazy var deleteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Delete Account", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        btn.backgroundColor = UIColor.hex(0xD32F2F)
        btn.layer.cornerRadius = 5
        btn.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)
        return btn
    }()
    
    @objc func handleDelete() {
        print("handleDelete:")
        
        let controller = UIAlertController(title: "Are you sure?", message: "Your account will not be able to be recovered if you do so", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Yes", style: .destructive) { (alert) in
            
            guard let uid = Auth.auth().currentUser?.uid else { return }
            self.deleteEverything(for: uid)
            self.deleteButton.isEnabled = false
            // animation?
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        controller.addAction(confirmAction)
        present(controller, animated: true, completion: nil)
    }
    
    fileprivate func deletePosts(for uid: String) {
        print("deletePosts:")
        
        let ref = Database.database().reference().child("posts").child(uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let postsDict = snapshot.value as? [String:Any] {
                postsDict.forEach({ (pid, value) in
                    self.deleteLikes(for: pid)
                    
                    let postRef = ref.child(pid)
                    postRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        guard let postInfoDict = snapshot.value as? [String:Any] else { return }
                        let postImageUrl = postInfoDict["imageUrl"] as! String
                        self.deleteItemInStorage(with: postImageUrl, completion: { (completed) in
                            if completed {
                                print("Successfully deleted post image with url:", postImageUrl)
                            }
                        })
                        
                    }, withCancel: { (err) in
                        print("Failed to fetch post data from db:", err)
                    })
                    
                    self.deleteSavedPosts(for: uid)
                    
                })
                
            }
            ref.removeValue { (err, _) in
                if let err = err {
                    print("Failed to delete posts from db:", err)
                    return
                }
                print("Successfully deleted posts from db")
                self.deleteFollowers(for: uid)
            }
        }) { (err) in
            print("Failed to fetch posts from db:", err)
        }
        
    }
    
    fileprivate func deleteSavedPosts(for uid: String) {
        Database.database().reference().child("saved").child(uid).removeValue { (err, _) in
            if let err = err {
                print("Failed to delete saved posts for user:", err)
                return
            }
            print("Successfully deleted saved posts for user:", uid)
        }
    }
    
    fileprivate func deleteFollowers(for uid: String) {
        print("deleteFollowers:")
        let ref = Database.database().reference().child("following")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let followingDict = snapshot.value as? [String:[String:Int]] {
                followingDict.forEach({ (key, dict) in
                    dict.forEach({ (id, val) in
                        if id == uid {
                            let followingRef = ref.child(key).child(id)
                            followingRef.removeValue(completionBlock: { (err, _) in
                                if let err = err {
                                    print("Failed to remove value in following:", err)
                                    return
                                }
                                print("Successfully removed value in following")
                            })
                        }
                    })
                })
            }
            self.deleteFollowing(for: uid)
        }) { (err) in
            print("Failed to delete followers from db:", err)
        }
    }
    
    fileprivate func deleteFollowing(for uid: String) {
        print("deleteFollowing:")
        
        let ref = Database.database().reference().child("following").child(uid)
        ref.removeValue { (err, _) in
            if let err = err {
                print("Failed to remove following values for user:", err)
                return
            }
            print("Successfully removed following values for user")
            self.deleteComments(for: uid)
        }
    }
    
    fileprivate func deleteComments(for uid: String) {
        print("deleteComments:")
        let ref = Database.database().reference().child("comments")
        ref.observe(.value, with: { (snapshot) in
            
            if let allCommentsDict = snapshot.value as? [String:[String:[String:Any]]] {
                allCommentsDict.forEach({ (pid, commentsDict) in
                    commentsDict.forEach({ (autoId, infoDict) in
                        let userOfComment = infoDict["uid"] as! String
                        if userOfComment == uid {
                            
                            let toRemoveRef = ref.child(pid).child(autoId)
                            toRemoveRef.removeValue(completionBlock: { (err, _) in
                                if let err = err {
                                    print("Failed to remove comment for post:", err)
                                    return
                                }
                                print("Successfully removed comment for post")
                            })
                            
                        }
                    })
                })
            }
            self.deleteUser(for: uid)
        }) { (err) in
            print("Failed to fetch comments from db:", err)
        }
    }
    
    fileprivate func deleteLikes(for pid: String) {
        print("deleteLikes:")
        
        let ref = Database.database().reference().child("likes").child(pid)
        ref.removeValue { (err, _) in
            if let err = err {
                print("Failed to remove likes for post:", err)
                return
            }
            print("Successfully removed likes for post")
        }
    }
    
    fileprivate func deleteUser(for uid: String) {
        print("deleteUser:")
        
        let ref = Database.database().reference().child("users").child(uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dict = snapshot.value as? [String:Any] else { return }
            let profileImageUrl = dict["profileImageUrl"] as! String
            self.deleteItemInStorage(with: profileImageUrl, completion: { (completed) in
                if completed {
                    print("Successfully deleted profile image with url:", profileImageUrl)
                    ref.removeValue(completionBlock: { (err, _) in
                        if let err = err {
                            print("Failed to remove value user info from db:", err)
                            return
                        }
                        print("Successfully removed user info from db")
                        self.deleteAuth()
                    })
                }
            })
            
        }) { (err) in
            print("Failed to fetch user info from db:", err)
        }
    }
    
    fileprivate func deleteItemInStorage(with url: String, completion: @escaping (Bool) -> ()) {
        Storage.storage().reference(forURL: url).delete { (err) in
            if let err = err {
                print("Failed to delete item in storage:", err)
                return
            }
            completion(true)
        }
    }
    
    fileprivate func deleteEverything(for uid: String) {
        deletePosts(for: uid)
        // the others will follow
    }
    
    fileprivate func deleteAuth() {
        print("deleteAuth:")
        
        guard let user = Auth.auth().currentUser else { return }
        
        user.delete(completion: { (err) in
            if let err = err {
                print("Failed to unauthenticate user:", err)
                
                do {
                    try Auth.auth().signOut()
                    let loginController = LoginController()
                    let navController = UINavigationController(rootViewController: loginController)
                    self.present(navController, animated: true, completion: nil)
                } catch let err {
                    print("Failed to sign out:", err)
                    return
                }
                return
            }
            
            print("Successfully unauthenticated user")
            if Auth.auth().currentUser == nil {
                let loginController = LoginController()
                let loginNavController = UINavigationController(rootViewController: loginController)
                self.present(loginNavController, animated: true, completion: nil)
            } else {
                print("Something went terribly wrong...")
            }
        })
        
    }
    
}
