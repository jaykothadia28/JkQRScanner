//
//  ViewController.swift
//  JkQRScanner
//
//  Created by Jay Kothadia on 04/02/2024.
//  Copyright (c) 2024 Jay Kothadia. All rights reserved.
//

import UIKit
import JkQRScanner

class ViewController: UIViewController {
    
    var qrScanner: JkQRScanner!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        qrScanner = JkQRScanner(delegate: self,
                                inputView: view,
                                message: "Scan the QR displayed on our website's login screen",
                                addFlashlight: true,
                                addPickFromPhotoLibraryOption: true)
        qrScanner.startRunning()
    }
    
    private func goToAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
    }
}

extension ViewController: JkQRScannerDelegate {
    func qrScanner(_ scanner: JkQRScanner, didScanQRCode code: String) {
        print("Scanner output: \(code)")
        qrScanner.stopRunning()
    }
    
    func qrScannerDidDenyCameraUsageAuthorization() {
        // you can redirect user to your app's settings in Settings App to allow camera permission
        goToAppSettings()
    }
    
    func qrScannerDidApproveCameraUsageAuthorization() {
        // perform any actions as per your requirements when the camera permission is allowed
    }
}

