//
//  BaseCell.swift
//  Polaroid
//
//  Created by Kang Nam on 5/10/18.
//  Copyright © 2018 Kang Nam. All rights reserved.
//

import UIKit

class BaseCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {}
    
}
