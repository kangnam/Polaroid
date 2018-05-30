//
//  Post.swift
//  Polaroid
//
//  Created by Kang Nam on 5/14/18.
//  Copyright © 2018 Kang Nam. All rights reserved.
//

import UIKit

struct Post {
    
    var id: String?
    let imageUrl: String
    let caption: String
    let user: User
    let creationDate: Date
    
    var hasLiked: Bool = false
    var likes: Int = 0
    
    init(user: User, dict: [String:Any]) {
        self.imageUrl = dict["imageUrl"] as? String ?? ""
        self.caption = dict["caption"] as? String ?? ""
        self.user = user
        
        let secondsAgoFrom1970 = dict["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsAgoFrom1970)
    }
    
}
