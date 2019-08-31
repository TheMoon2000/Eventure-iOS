//
//  ScannerViewController.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/29.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import AVFoundation

class ScannerViewController: UIViewController,AVCaptureMetadataOutputObjectsDelegate {
    
    var session:AVCaptureSession!
    var device: AVCaptureDevice!
    var screenWidth : CGFloat!
    var screenHeight: CGFloat!
    
    private var activeRegion: UIView!
    private var cameraPrompt: UILabel!
    private var cameraDefaultText = "Place QR code within to scan!"
    private var lastZoomFactor: CGFloat = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Scan Code"
        
        setupViews()
        
        guard let newDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            print("WARNING: Device has no camera!")
            return
        }
        
        device = newDevice
        setCamera(device: device)
    }
        
    /// We need to make four views that block the area that is NOT part of the active scanning area.
    private func setupViews() {
        
        activeRegion = {
            let region = UIView()
            region.layer.borderWidth = 1.5
            region.layer.borderColor = MAIN_TINT.cgColor
            region.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(region)
            
            region.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 50).isActive = true
            region.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -50).isActive = true
            region.widthAnchor.constraint(equalTo: region.heightAnchor).isActive = true
            region.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            
            region.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(pinch(_:))))
            
            return region
        }()
        
        activeRegion.layoutIfNeeded()
        
        let wallColor = UIColor(white: 0.1, alpha: 0.6)
        
        let leftWall: UIView = {
            let wall = UIView()
            wall.backgroundColor = wallColor
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
        
    }
    
    
    //设置相机
    
    func setCamera(device: AVCaptureDevice) {
        
        do {
            //创建输入流
            let input =  try AVCaptureDeviceInput(device: device)
            
            //创建输出流
            let output = AVCaptureMetadataOutput()
            
            //设置会话
            session = AVCaptureSession()
            
            //连接输入输出
            
            if session.canAddInput(input) {
                session.addInput(input)
            }
            
            if session.canAddOutput(output) {
                session.addOutput(output)
            //设置输出流代理，从接收端收到的所有元数据都会被传送到delegate方法，所有delegate方法均在queue中执行
                output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                
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
        print("max: \(device.activeFormat.videoMaxZoomFactor)")
        let zoomFactor = lastZoomFactor * gesture.scale
        if zoomFactor <= device.activeFormat.videoMaxZoomFactor {
            device.videoZoomFactor = zoomFactor
            lastZoomFactor = zoomFactor
        }
    }
    
    
    
    //扫描完成的代理
    
    private var lastReturnDate = Date(timeIntervalSinceReferenceDate: 0)
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
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
        
        if let eventUUID = filtered.first {
            
//            session?.stopRunning()
            
            cameraPrompt.text = "Scanned event <\(eventUUID)>. More work needs to be done to load the event information from the server."
            cameraPrompt.textColor = .white
        } else {
            cameraPrompt.text = "Oops, this QR code is not a valid event code."
            cameraPrompt.textColor = WARNING_COLOR
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if thisDate == self.lastReturnDate {
                self.cameraPrompt.text = self.cameraDefaultText
                self.cameraPrompt.textColor = .white
            }
        }
        
        
        
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
        
}

