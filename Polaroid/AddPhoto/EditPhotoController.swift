//
//  EditPhotoController.swift
//  Polaroid
//
//  Created by Kang Nam on 5/14/18.
//  Copyright © 2018 Kang Nam. All rights reserved.
//

import UIKit

class EditPhotoController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var selectedImage: UIImage? {
        didSet {
            setupFilteredImages()
        }
    }

    let thumbnailImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .groupTableViewBackground
        iv.clipsToBounds = true
        return iv
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.decelerationRate = UIScrollViewDecelerationRateFast
        return cv
    }()
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationController?.navigationBar.backgroundColor = .white
        
        setupThumbnailImageView()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(EditPhotoCell.self, forCellWithReuseIdentifier: cellId)
        view.addSubview(collectionView)
        collectionView.anchor(top: thumbnailImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: view.bottomAnchor, topPadding: 0, leftPadding: 0, rightPadding: 0, bottomPadding: 0, width: 0, height: 0)
        collectionView.contentInset = UIEdgeInsetsMake(0, 20, 0, 20)
        
        setupNavigationButtons()
    }
    
    fileprivate func setupThumbnailImageView() {
        view.addSubview(thumbnailImageView)
        thumbnailImageView.image = selectedImage
        thumbnailImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: nil, topPadding: 0, leftPadding: 0, rightPadding: 0, bottomPadding: 0, width: 0, height: view.frame.width)
    }
    
    fileprivate func setupNavigationButtons() {
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleBack))
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
        let nextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNext))
        nextButton.tintColor = UIColor.hex(0x1E88E5)
        navigationItem.rightBarButtonItem = nextButton
    }
    
    @objc func handleNext() {
        let sharePhotoController = SharePhotoController()
        sharePhotoController.image = thumbnailImageView.image
        navigationController?.pushViewController(sharePhotoController, animated: true)
    }
    
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let safeAreaHeight: CGFloat = view.safeAreaLayoutGuide.layoutFrame.size.height
        let height: CGFloat = safeAreaHeight - view.frame.width
        return CGSize(width: 100, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! EditPhotoCell
        cell.filterLabel.text = filters[indexPath.item].name
        cell.thumbnailImageView.image = filteredImages[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        thumbnailImageView.image = filteredImages[indexPath.item]
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    fileprivate let filters: [Filter] = [
        Filter(["name": "Original", "effect": ""]),
        Filter(["name": "Chrome", "effect": "CIPhotoEffectChrome"]),
        Filter(["name": "Fade", "effect": "CIPhotoEffectFade"]),
        Filter(["name": "Instant", "effect": "CIPhotoEffectInstant"]),
        Filter(["name": "Noir", "effect": "CIPhotoEffectNoir"]),
        Filter(["name": "Process", "effect": "CIPhotoEffectProcess"]),
        Filter(["name": "Tonal", "effect": "CIPhotoEffectTonal"]),
        Filter(["name": "Transfer", "effect": "CIPhotoEffectTransfer"]),
        Filter(["name": "Sepia", "effect": "CISepiaTone"])
    ]
  
    fileprivate let context = CIContext(options: nil)
    
    fileprivate var filter: CIFilter?
    
    var filteredImages = [UIImage]()
    fileprivate var preprocessedSelectedImage: CIImage?
    
    func setupFilteredImages() {
        if let selectedImage = selectedImage {
            if let data = UIImageJPEGRepresentation(selectedImage, 1) {
                preprocessedSelectedImage = CIImage(data: data)
                for filter in filters {
                    filteredImages.append(imageWithFilter(filter.effect))
                }
                collectionView.reloadData()
            }
        }
    }
    
    func imageWithFilter(_ filterEffect: String) -> UIImage {
        if filterEffect == "" {
            print("Returning original image:")
            return selectedImage!
        }
        filter = CIFilter(name: filterEffect)
        filter?.setValue(preprocessedSelectedImage!, forKey: kCIInputImageKey)
        if let output = filter?.outputImage {
            if let cgImage = context.createCGImage(output, from: output.extent) {
                let processedImage = UIImage(cgImage: cgImage)
                print("Returning processed image for:", filterEffect)
                return processedImage
            }
        }
        return UIImage()
    }
    
}

struct Filter {
    
    var name: String
    var effect: String
    
    init(_ dict: [String:Any]) {
        self.name = dict["name"] as? String ?? ""
        self.effect = dict["effect"] as? String ?? ""
    }
    
}
