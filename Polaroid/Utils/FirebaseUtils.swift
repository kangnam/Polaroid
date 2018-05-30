//
//  FirebaseUtils.swift
//  Polaroid
//
//  Created by Kang Nam on 5/16/18.
//  Copyright © 2018 Kang Nam. All rights reserved.
//

import Firebase
import UIKit

extension Database {
    
    static func fetchUserWithUID(_ uid: String, completion: @escaping (User) -> ()) {
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let userDictionary = snapshot.value as? [String: Any] else { return }
            let user = User(uid: uid, dict: userDictionary)
            completion(user)
        }) { (err) in
            print("Failed to fetch user for posts:", err)
        }
    }
    
}
