//
//  User.swift
//  Polaroid
//
//  Created by Kang Nam on 5/14/18.
//  Copyright © 2018 Kang Nam. All rights reserved.
//

import UIKit

struct User {
    
    let uid: String
    let username: String
    let profileImageUrl: String
    
    init(uid: String, dict: [String:Any]) {
        self.uid = uid
        self.username = dict["username"] as? String ?? ""
        self.profileImageUrl = dict["profileImageUrl"] as? String ?? ""
    }
    
}
