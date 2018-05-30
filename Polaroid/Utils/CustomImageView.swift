//
//  CustomImageView.swift
//  Polaroid
//
//  Created by Kang Nam on 5/14/18.
//  Copyright © 2018 Kang Nam. All rights reserved.
//

import UIKit

var imageCache = [String: UIImage]()
//var imageCache = NSCache<NSString, UIImage>()

class CustomImageView: UIImageView {
    
    var lastUrlToLoadImage: String?
    
    func loadImage(urlString: String) {
        lastUrlToLoadImage = urlString
        
        self.image = nil
        
        if let cachedImage = imageCache[urlString] {
            print("Successfully fetched post image from Cache")
            self.image = cachedImage
            return
        }
        
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            if let err = err {
                print("Failed to fetch post image:", err)
                return
            }
            if url.absoluteString != self.lastUrlToLoadImage {
                return
            }
            guard let imageData = data else { return }
            print("Successfully fetched post image:", imageData)
            let photoImage = UIImage(data: imageData)
            imageCache[url.absoluteString] = photoImage
            DispatchQueue.main.async {
                self.image = photoImage
            }
        }.resume()
    }
    
}
