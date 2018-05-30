//
//  PreviewContainerView.swift
//  Polaroid
//
//  Created by Kang Nam on 5/17/18.
//  Copyright © 2018 Kang Nam. All rights reserved.
//

import UIKit
import Photos

class PreviewContainerView: UIView {
    
    let previewImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    lazy var cancelButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "cancel_shadow")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.contentMode = .scaleAspectFill
        btn.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return btn
    }()
    
    lazy var savePhotoButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "save_shadow")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.contentMode = .scaleAspectFill
        btn.addTarget(self, action: #selector(handleSavePhoto), for: .touchUpInside)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(previewImageView)
        addSubview(cancelButton)
        addSubview(savePhotoButton)
        
        previewImageView.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, bottom: bottomAnchor, topPadding: 0, leftPadding: 0, rightPadding: 0, bottomPadding: 0, width: 0, height: 0)
        cancelButton.anchor(top: topAnchor, left: leftAnchor, right: nil, bottom: nil, topPadding: 16, leftPadding: 16, rightPadding: 0, bottomPadding: 0, width: 40, height: 40)
        savePhotoButton.anchor(top: nil, left: leftAnchor, right: nil, bottom: bottomAnchor, topPadding: 0, leftPadding: 16, rightPadding: 0, bottomPadding: 16, width: 40, height: 40)
    }
    
    @objc func handleCancel() {
        self.removeFromSuperview()
    }
    
    @objc func handleSavePhoto() {
        print("handleSavePhoto:")
        
        guard let image = self.previewImageView.image else { return }
        
        let library = PHPhotoLibrary.shared()
        library.performChanges({
            
            PHAssetChangeRequest.creationRequestForAsset(from: image)
            
        }) { (success, err) in
            if let err = err {
                print("Failed to save photo to photo library:", err)
                return
            }
            print("Successfully saved photo to photo library")
            
            DispatchQueue.main.async {
                let saveLabel = UILabel()
                saveLabel.text = "Successfully saved photo"
                saveLabel.textColor = .white
                saveLabel.textAlignment = .center
                saveLabel.font = UIFont.boldSystemFont(ofSize: 14)
                saveLabel.backgroundColor = UIColor(white: 0, alpha: 0.3)
                saveLabel.numberOfLines = 0
                saveLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 80)
                saveLabel.center = self.center
                
                self.addSubview(saveLabel)
                saveLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)
                
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    
                    saveLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
                    
                }, completion: { (completed) in
                    
                    UIView.animate(withDuration: 0.5, delay: 0.75, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                        
                        saveLabel.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                        saveLabel.alpha = 0
                        
                    }, completion: { (_) in
                        saveLabel.removeFromSuperview()
                    })
                    
                })
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
