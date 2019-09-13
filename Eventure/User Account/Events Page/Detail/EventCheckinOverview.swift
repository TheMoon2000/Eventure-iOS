//
//  EventCheckinOverview.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/29.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import Photos

class EventCheckinOverview: UIViewController {
    
    var event: Event!
    private var titleLabel: UILabel!
    private var subtitleLabel: UILabel!
    private var qrCode: UIImageView!
    private var eventName: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .init(white: 0.99, alpha: 1)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.rightBarButtonItem = .init(image: #imageLiteral(resourceName: "checkin_result"), style: .plain, target: self, action: #selector(viewResults))
        
        let code = APP_STORE_LINK + "?id=" + event.uuid

        titleLabel = {
            let label = UILabel()
            label.text = "Event Check-in Code"
            label.textAlignment = .center
            label.textColor = .init(white: 0.1, alpha: 1)
            label.font = .systemFont(ofSize: 25, weight: .semibold)
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
            
            return label
        }()
        
        subtitleLabel = {
            let label = UILabel()
            label.numberOfLines = 5
            label.lineBreakMode = .byWordWrapping
            label.text = "Present this QR code at check-in to collect information about who's attending your event."
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 17)
            label.textColor = .init(white: 0.1, alpha: 1)
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15).isActive = true
            label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
            label.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -30).isActive = true
            
            return label
        }()

        qrCode = {
            let iv = UIImageView(image: generateQRCode(from: code))
            iv.translatesAutoresizingMaskIntoConstraints = false
            iv.isUserInteractionEnabled = true
            iv.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(saveImage(_:))))
            view.addSubview(iv)
            
            iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
            iv.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            iv.widthAnchor.constraint(equalToConstant: 240).isActive = true
            iv.topAnchor.constraint(greaterThanOrEqualTo: subtitleLabel.bottomAnchor, constant: 50).isActive = true
            
            iv.centerYAnchor.constraint(greaterThanOrEqualTo: view.centerYAnchor, constant: 20).isActive = true
            
            
            return iv
        }()
        
        eventName = {
            let label = UILabel()
            label.attributedText = "The code above is for **\(event.title)** by *\(event.hostTitle)*.".attributedText(style: COMPACT_STYLE)
            label.numberOfLines = 5
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
            label.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -30).isActive = true
            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
            
            return label
        }()
    }
    
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            print("WARNING: Unable to find QR Generator filter")
            return nil
        }
        
        filter.setValue(data, forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        
        guard let output = filter.outputImage?.transformed(by: transform) else {
            return nil
        }

        let context = CIContext()
        guard let cg = context.createCGImage(output, from: output.extent) else {
            return UIImage(ciImage: output)
        }
        
        return UIImage(cgImage: cg)
    }
    
    @objc private func saveImage(_ gesture: UIGestureRecognizer) {
        
        guard qrCode.image != nil else {
            print("no image found")
            return
        }
        
        if gesture.state != .began {
            return
        }
        
        let formatted = EventCodeView()
        formatted.titleLabel.text = event.title
        formatted.subtitleLabel.text = event.timeDescription
        formatted.qrCode.image = qrCode.image
        formatted.orgTitle.text = event.hostTitle
        formatted.translatesAutoresizingMaskIntoConstraints = false
        formatted.layoutIfNeeded()
        if let logo = Organization.current?.logoImage {
            formatted.orgLogo.image = logo
        }
        let renderer = UIGraphicsImageRenderer(bounds: formatted.bounds)
        let qr = renderer.image { context in
            formatted.layer.render(in: context.cgContext)
        }
        
        let alert = UIAlertController(title: "QR Code", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(.init(title: "Cancel", style: .cancel))
        alert.addAction(.init(title: "Save QR Code", style: .default, handler: { _ in
            UIImageWriteToSavedPhotosAlbum(qr, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            /*
            PHPhotoLibrary.requestAuthorization { status in
                guard status == .authorized else { return }
                
                PHPhotoLibrary.shared().performChanges({
                    // Add the captured photo's file data as the main resource for the Photos asset.
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    creationRequest.addResource(with: .photo, data: qrData, options: nil)
                }, completionHandler: nil)
            }*/
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "The QR Code has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.all)
    }
    
    @objc private func viewResults() {
        let checkinResults = CheckinResults(event: event)
        let nav = CheckinNavigationController(rootViewController: checkinResults)
        present(nav, animated: true, completion: nil)
    }
    
}
