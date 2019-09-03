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
    
    private var session:AVCaptureSession!
    private var device: AVCaptureDevice!
    private var screenWidth : CGFloat!
    private var screenHeight: CGFloat!
    
    private var activeRegion: UIView!
    private var cameraPrompt: UILabel!
    private var spinner: UIActivityIndicatorView!
    private var torchSwitch: UIButton!
    private var cameraDefaultText = "Place QR code within to scan!"
    private var lastZoomFactor: CGFloat = 1.0
    
    private var TORCH_ON = "Let there be light"
    private var TORCH_OFF = "Tap to turn off flashlight"
    private var INVALID_CODE = "Oops, this QR code is not a valid event code."
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // MARK: - Begin methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Scan Code"
        
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
        
    /// We need to make four views that block the area that is NOT part of the active scanning area.
    private func setupViews() {
        
        activeRegion = {
            let region = UIView()
            region.layer.borderWidth = 1.5
            region.layer.borderColor = MAIN_TINT.cgColor
            region.isUserInteractionEnabled = false
            region.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(region)
            
            region.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 50).isActive = true
            region.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -50).isActive = true
            region.widthAnchor.constraint(equalTo: region.heightAnchor).isActive = true
            region.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            
            return region
        }()
        
        activeRegion.layoutIfNeeded()
        
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
                output.rectOfInterest = activeRegion.frame
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
    
    //扫描完成的代理
    
    private var lastReturnDate = Date(timeIntervalSinceReferenceDate: 0)
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        
        // If an event code is already being processed, then prevent any new codes from being scanned.
        if spinner.isAnimating { return }
        
        let parsed: [String] = metadataObjects.map { raw in
            
            guard let dataString = (raw as! AVMetadataMachineReadableCodeObject).stringValue
                else {
                    return ""
            }
            
            guard dataString.hasPrefix(URL_PREFIX) else { return "" }
            
            let encrypted = dataString[dataString.index(dataString.startIndex, offsetBy: URL_PREFIX.count)...]
            
            if let decrypted = NSString(string: String(encrypted)).aes256Decrypt(withKey: AES_KEY) {
                
                return decrypted
            }
            
            return ""
            
        }
        
        let filtered = parsed.filter { !$0.isEmpty }
        
        let thisDate = Date()
        lastReturnDate = thisDate
        
        if let eventID = filtered.first {
            
            session?.stopRunning()
            spinner.startAnimating()
            
            cameraPrompt.text = "Event code scanned! Processing..."
            cameraPrompt.textColor = .white
            
            presentCheckinForm(eventID: eventID)
        } else {
            cameraPrompt.text = INVALID_CODE
            cameraPrompt.textColor = LIGHT_RED
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if thisDate == self.lastReturnDate {
                self.cameraPrompt.text = self.cameraDefaultText
                self.cameraPrompt.textColor = .white
            }
        }
        
    }
    
    func presentCheckinForm(eventID: String) {
        
        print("presenting check-in form for \(eventID)")
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/GetEvent",
                           parameters: ["uuid": eventID])!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
            }
            
            guard error == nil else {
                DispatchQueue.main.async {
                    self.cameraPrompt.text = "No internet connection."
                    self.cameraPrompt.textColor = WARNING_COLOR
                    self.session.startRunning()
                }
                return
            }
            
            if let json = try? JSON(data: data!) {
                let event = Event(eventInfo: json)
                let checkinForm = CheckinPageController(event: event)
                DispatchQueue.main.async {
                    self.present(CheckinNavigationController(rootViewController: checkinForm), animated: true) {
                        self.navigationController?.popViewController(animated: false)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.cameraPrompt.text = self.INVALID_CODE
                    self.cameraPrompt.textColor = LIGHT_RED
                }
            }
        }
        
        task.resume()
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
}

