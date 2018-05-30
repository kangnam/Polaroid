//
//  EditPhotoCell.swift
//  Polaroid
//
//  Created by Kang Nam on 5/14/18.
//  Copyright © 2018 Kang Nam. All rights reserved.
//

import UIKit

class EditPhotoCell: BaseCell {
    
    let filterLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = .lightGray
        label.text = "Filter"
        return label
    }()
    
    let thumbnailImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .groupTableViewBackground
        return iv
    }()
    
    override func setupViews() {
        addSubview(thumbnailImageView)
        thumbnailImageView.anchor(top: nil, left: leftAnchor, right: rightAnchor, bottom: nil, topPadding: 0, leftPadding: 0, rightPadding: 0, bottomPadding: 0, width: 0, height: 100)
        thumbnailImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        addSubview(filterLabel)
        filterLabel.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, bottom: thumbnailImageView.topAnchor, topPadding: 0, leftPadding: 0, rightPadding: 0, bottomPadding: 0, width: 0, height: 0)
        
    }
    
}
