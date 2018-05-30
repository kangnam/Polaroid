//
//  Comment.swift
//  Polaroid
//
//  Created by Kang Nam on 5/17/18.
//  Copyright © 2018 Kang Nam. All rights reserved.
//

import UIKit

struct Comment {
    
    let user: User
    
    let text: String
    let creationDate: Date
    let uid: String
    
    init(user: User, dict: [String:Any]) {
        self.text = dict["text"] as? String ?? ""
        self.uid = dict["uid"] as? String ?? ""
        self.user = user
        
        let secondsAgoFrom1970 = dict["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsAgoFrom1970)
    }
    
}
