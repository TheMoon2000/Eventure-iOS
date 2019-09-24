//
//  ScannerViewController.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/29.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyJSON

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private(set) var session:AVCaptureSession!
    private(set) var device: AVCaptureDevice!
    private var screenWidth : CGFloat!
    private var screenHeight: CGFloat!
    
    private var activeRegion: UIView!
    private(set) var cameraPrompt: UILabel!
    private(set) var spinner: UIActivityIndicatorView!
    private(set) var torchSwitch: UIButton!
    private(set) var cameraDefaultText = "Place QR code within to scan!"
    private(set) var lastZoomFactor: CGFloat = 1.0
    
    private var TORCH_ON = "Let there be light"
    private var TORCH_OFF = "Tap to turn off flashlight"
    var INVALID_CODE: String {
        return "Oops, this QR code is not a valid event code."
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // MARK: - Begin methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Scan Code"
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = .init(title: "Album", style: .plain, target: self, action: #selector(pickLocalImage))
        
        setupViews()
        
        spinner = {
            let spinner = UIActivityIndicatorView(style: .white)
            spinner.hidesWhenStopped = true
            spinner.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(spinner)
            
            spinner.centerXAnchor.constraint(equalTo: activeRegion.centerXAnchor).isActive = true
            spinner.centerYAnchor.constraint(equalTo: activeRegion.centerYAnchor).isActive = true
            
            return spinner
        }()
        
        
        guard let newDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            print("WARNING: Device has no camera!")
            return
        }
        
         view.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(pinch(_:))))
        
        device = newDevice
        setCamera(device: device)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        session?.startRunning()
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.all)
    }
    /// We need to make four views that block the area that is NOT part of the active scanning area.
    private func setupViews() {
        
        activeRegion = {
            let region = UIView()
            region.layer.borderWidth = 1.5
            region.layer.borderColor = MAIN_TINT.cgColor
            region.isUserInteractionEnabled = false
            region.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(region)
            
            let left = region.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 50)
            left.priority = .defaultHigh
            left.isActive = true
            
            let right = region.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -50)
            right.priority = .defaultHigh
            right.isActive = true
            
            region.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            region.widthAnchor.constraint(lessThanOrEqualToConstant: 400).isActive = true
            region.widthAnchor.constraint(equalTo: region.heightAnchor).isActive = true
            region.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            
            return region
        }()
        
        let wallColor = UIColor(white: 0.1, alpha: 0.6)
        
        let leftWall: UIView = {
            let wall = UIView()
            wall.backgroundColor = wallColor
            wall.isUserInteractionEnabled = false
            wall.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(wall)
            
            wall.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            wall.rightAnchor.constraint(equalTo: activeRegion.leftAnchor).isActive = true
            wall.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            wall.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            return wall
        }()
        
        // Right wall
        let rightWall: UIView = {
            let wall = UIView()
            wall.isUserInteractionEnabled = false
            wall.backgroundColor = wallColor
            wall.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(wall)
            
            wall.leftAnchor.constraint(equalTo: activeRegion.rightAnchor).isActive = true
            wall.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            wall.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            wall.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            return wall
        }()
        
        // Top wall
        let _: UIView = {
            let wall = UIView()
            wall.isUserInteractionEnabled = false
            wall.backgroundColor = wallColor
            wall.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(wall)
            
            wall.leftAnchor.constraint(equalTo: leftWall.rightAnchor).isActive = true
            wall.rightAnchor.constraint(equalTo: rightWall.leftAnchor).isActive = true
            wall.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            wall.bottomAnchor.constraint(equalTo: activeRegion.topAnchor).isActive = true
            
            return wall
        }()
        
        // Bottom wall
        let _: UIView = {
            let wall = UIView()
            wall.isUserInteractionEnabled = false
            wall.backgroundColor = wallColor
            wall.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(wall)
            
            wall.leftAnchor.constraint(equalTo: leftWall.rightAnchor).isActive = true
            wall.rightAnchor.constraint(equalTo: rightWall.leftAnchor).isActive = true
            wall.topAnchor.constraint(equalTo: activeRegion.bottomAnchor).isActive = true
            wall.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            return wall
        }()
        
        cameraPrompt = {
            let label = UILabel()
            label.numberOfLines = 5
            label.textColor = .white
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 14)
            label.text = cameraDefaultText
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            label.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
            label.topAnchor.constraint(equalTo: activeRegion.bottomAnchor, constant: 15).isActive = true
            
            return label
        }()
        
        torchSwitch = {
            let button = UIButton(type: .system)
            button.tintColor = .white
            button.isHidden = true
            button.imageEdgeInsets.right = 10
            button.imageView?.contentMode = .scaleAspectFit
            button.titleLabel?.font = .systemFont(ofSize: 15)
            button.setImage(#imageLiteral(resourceName: "light").withRenderingMode(.alwaysTemplate), for: .normal)
            button.setTitle(TORCH_ON, for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(button)
            
            button.centerXAnchor.constraint(equalTo: activeRegion.centerXAnchor).isActive = true
            button.bottomAnchor.constraint(equalTo: activeRegion.bottomAnchor, constant: -10).isActive = true
            button.heightAnchor.constraint(equalToConstant: 28).isActive = true
            
            button.addTarget(self, action: #selector(toggleTorch(_:)), for: .touchUpInside)
            
            return button
        }()
        
        view.layoutIfNeeded()
    }
    
    
    //设置相机
    
    func setCamera(device: AVCaptureDevice) {
        
        do {
            let input =  try AVCaptureDeviceInput(device: device)
            let output = AVCaptureMetadataOutput()
            let videoOutput = AVCaptureVideoDataOutput()
            
            //设置会话
            session = AVCaptureSession()
            
            //连接输入输出
            if session.canAddInput(input) {
                session.addInput(input)
            }
            
            if session.canAddOutput(output) {
                session.addOutput(output)
                session.addOutput(videoOutput)
                
                output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
                
                //设置扫描二维码类型
                output.metadataObjectTypes = [ AVMetadataObject.ObjectType.qr]
                
                //扫描区域
                
                //rectOfInterest 属性中x和y互换，width和height互换。
                output.rectOfInterest = CGRect(
                    x: activeRegion.frame.origin.y / view.bounds.height,
                    y: activeRegion.frame.origin.x / view.bounds.width,
                    width: activeRegion.frame.height / view.bounds.height,
                    height: activeRegion.frame.width / view.bounds.width)
            }
            
            
            //捕捉图层
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.frame = view.bounds
            self.view.layer.insertSublayer(previewLayer, at: 0)
            
            //持续对焦
            
            if device.isFocusModeSupported(.continuousAutoFocus) {
                try input.device.lockForConfiguration()
                input.device.focusMode = .continuousAutoFocus
                input.device.unlockForConfiguration()
            }
            
            session.startRunning()
        } catch  {}
        
    }
    
    @objc private func pinch(_ gesture: UIPinchGestureRecognizer) {
        let zoomFactor = min(max(1, lastZoomFactor * gesture.scale), device.activeFormat.videoMaxZoomFactor)
        
        try? device.lockForConfiguration()
        device.videoZoomFactor = zoomFactor
        device.unlockForConfiguration()
        
        if gesture.state == .ended {
            lastZoomFactor = zoomFactor
        }
        
    }
    
    @objc private func toggleTorch(_ sender: UIButton) {
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                
                if sender.title(for: .normal) == TORCH_ON {
                    device.torchMode = .on
                    sender.setImage(#imageLiteral(resourceName: "light_off").withRenderingMode(.alwaysTemplate), for: .normal)
                    sender.setTitle(TORCH_OFF, for: .normal)
                } else {
                    device.torchMode = .off
                    sender.setImage(#imageLiteral(resourceName: "light").withRenderingMode(.alwaysTemplate), for: .normal)
                    sender.setTitle(TORCH_ON, for: .normal)
                }
                
                device.unlockForConfiguration()
            } catch {
                print("WARNING: Torch could not be used")
            }
        } else {
            print("WARNING: Torch is not available")
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        let rawMetadata = CMCopyDictionaryOfAttachments(allocator: nil, target: sampleBuffer, attachmentMode: kCMAttachmentMode_ShouldPropagate)
        let metadata = CFDictionaryCreateMutableCopy(nil, 0, rawMetadata) as NSMutableDictionary
        let exifData = metadata.value(forKey: "{Exif}") as? NSMutableDictionary
        
        let FNumber : Double = exifData?["FNumber"] as! Double
        let ExposureTime : Double = exifData?["ExposureTime"] as! Double
        let ISOSpeedRatingsArray = exifData!["ISOSpeedRatings"] as? NSArray
        let ISOSpeedRatings : Double = ISOSpeedRatingsArray![0] as! Double
        
        //Calculating the luminosity
        let luminosity : Double = (FNumber * FNumber ) / ( ExposureTime * ISOSpeedRatings)
        
        if device.hasTorch {
            torchSwitch.isHidden = luminosity > 0.3 && device.torchMode == .off
        }
    }
    
    func detectQRCode(_ image: UIImage?) -> String? {
        if let image = image, let ciImage = CIImage.init(image: image) {
            var options: [String: Any]
            let context = CIContext()
            options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
            let qrDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options)
            if ciImage.properties.keys.contains((kCGImagePropertyOrientation as String)){
                options = [CIDetectorImageOrientation: ciImage.properties[(kCGImagePropertyOrientation as String)] ?? 1]
            }else {
                options = [CIDetectorImageOrientation: 1]
            }
            let features = qrDetector?.features(in: ciImage, options: options)
            
            return (features?.first as? CIQRCodeFeature)?.messageString
        }
        return nil
    }
    
    //扫描完成的代理
    
    private var lastReturnDate = Date(timeIntervalSinceReferenceDate: 0)
    
    /// Override this
    func decryptDataString(_ string: String) -> String? {
        return nil
    }
    
    func resetDisplay() {
        spinner.stopAnimating()
        self.cameraPrompt.text = self.cameraDefaultText
        self.cameraPrompt.textColor = .white
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        
        // If an event code is already being processed, then prevent any new codes from being scanned.
        if spinner.isAnimating { return }
        
        let parsed: [String] = metadataObjects.map { raw in
            
            guard let dataString = (raw as! AVMetadataMachineReadableCodeObject).stringValue
                else {
                    return ""
            }
            
            return decryptDataString(dataString) ?? ""
        }
        
        let thisDate = Date()
        lastReturnDate = thisDate

        let filtered = parsed.filter { !$0.isEmpty }
        
        if let decrypted = filtered.first {
            processDecryptedCode(string: decrypted)
        } else {
            cameraPrompt.text = INVALID_CODE
            cameraPrompt.textColor = LIGHT_RED
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                if thisDate == self?.lastReturnDate {
                    self?.cameraPrompt.text = self?.cameraDefaultText
                    self?.cameraPrompt.textColor = .white
                }
            }
        }
        
        
        
    }
    
    func processDecryptedCode(string: String) {
        // Override this...
        session?.stopRunning()
        spinner.startAnimating()
        
        cameraPrompt.text = "Code scanned! Processing..."
        cameraPrompt.textColor = .white
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    @objc func pickLocalImage() {
        guard UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) else {
            return
        }
        
        let picker = UIImagePickerController()
        picker.sourceType = .savedPhotosAlbum
        picker.delegate = self
        present(picker, animated: true)
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
}

extension ScannerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
}
