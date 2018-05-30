//
//  CameraController.swift
//  Polaroid
//
//  Created by Kang Nam on 5/16/18.
//  Copyright © 2018 Kang Nam. All rights reserved.
//

import AVFoundation
import UIKit

class CameraController: UIViewController, AVCapturePhotoCaptureDelegate, UIViewControllerTransitioningDelegate {
    
    let output = AVCapturePhotoOutput()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transitioningDelegate = self
        
        setupCameraSession()
        setupHUD()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    fileprivate func setupCameraSession() {
        let captureSession = AVCaptureSession()

        // 1. setup inputs
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
        } catch let err {
            print("Failed to setup camera input:", err)
            return
        }
        
        // 2. setup outputs
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
        
        // 3. setup output preview
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.frame
        view.layer.addSublayer(previewLayer)
        
        // 4. run
        captureSession.startRunning()
    }
    
    fileprivate func setupHUD() {
        view.addSubview(backButton)
        backButton.anchor(top: view.topAnchor, left: nil, right: view.rightAnchor, bottom: nil, topPadding: 16, leftPadding: 0, rightPadding: 16, bottomPadding: 0, width: 40, height: 40)
        view.addSubview(captureButton)
        captureButton.anchor(top: nil, left: nil, right: nil, bottom: view.bottomAnchor, topPadding: 0, leftPadding: 0, rightPadding: 0, bottomPadding: 0, width: 160, height: 160)
        captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    @objc func handleBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    let customAnimationPresentor = CustomAnimationPresentor()
    let customAnimationDismisser = CustomAnimationDismisser()
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customAnimationPresentor
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customAnimationDismisser
    }
    
    @objc func handleCaptureButton() {
        let settings = AVCapturePhotoSettings()
        guard let previewFormatType = settings.availablePreviewPhotoPixelFormatTypes.first else { return }
        settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewFormatType]
        output.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            let image = UIImage(data: imageData)
            
            let previewContainerView = PreviewContainerView()
            previewContainerView.previewImageView.image = image
            view.addSubview(previewContainerView)
            previewContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: view.bottomAnchor, topPadding: 0, leftPadding: 0, rightPadding: 0, bottomPadding: 0, width: 0, height: 0)
        }
    }
    
    lazy var captureButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "capture_photo")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.contentMode = .scaleAspectFill
        btn.addTarget(self, action: #selector(handleCaptureButton), for: .touchUpInside)
        return btn
    }()
    
    lazy var backButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "right_arrow_shadow")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.contentMode = .scaleAspectFill
        btn.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        return btn
    }()
    
    
    
}
