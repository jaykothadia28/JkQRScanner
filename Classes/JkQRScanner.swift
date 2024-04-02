//
//  JkQRScanner.swift
//  JkQRScanner
//
//  Created by Jay Kothadia on 02/04/24.
//

import UIKit
import AVFoundation

public protocol JkQRScannerDelegate: AnyObject {
    func qrScanner(_ scanner: JkQRScanner, didScanQRCode code: String)
    func qrScannerDidDenyCameraUsageAuthorization()
    func qrScannerDidApproveCameraUsageAuthorization()
}

public class JkQRScanner: NSObject {
    
    weak var delegate: JkQRScannerDelegate?
    var inputView: UIView!
    
    var scannerAreaCornerRadius: CGFloat = 12.0
    var scannerAreaBorderWidth: CGFloat = 2.0
    var scannerAreaBorderColor: UIColor = .white
    var message: String?
    var messageFont: UIFont?
    var addFlashlight: Bool?
    var addPickFromPhotoLibraryOption: Bool?
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    private let baseView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private let transparentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }()
    
    private let cutoutView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var accesoriesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 25.0
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var flashlightButton: UIButton = {
        let flashlightButton = UIButton(type: .system)
        flashlightButton.setImage(UIImage(systemName: "flashlight.off.fill"), for: .normal)
        flashlightButton.tintColor = .white
        flashlightButton.addTarget(self, action: #selector(toggleFlashlight), for: .touchUpInside)
        return flashlightButton
    }()
    
    private lazy var photoLibraryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "photo.fill"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(selectImageFromPhotoLibrary), for: .touchUpInside)
        return button
    }()
    
    /// Initializer that checks for the camera permission and adds the scanner to the input view provided by the controller
    /// - Parameters:
    ///   - delegate: The controller that is going to use the scanner
    ///   - inputView: The view in which you want to add the scanner
    ///   - message: The title message you want to display
    ///   - messageFont: UIFont for the message
    ///   - addFlashlight: set this as `true` if you want to provide the flashlight feature
    ///   - addPickFromPhotoLibraryOption: Set this value as `true` if you wan to enable the feature of scanning QR from a photo of the photo library
    public init(delegate: JkQRScannerDelegate,
         inputView: UIView,
         message: String? = nil, 
         messageFont: UIFont? = nil,
         addFlashlight: Bool = false,
         addPickFromPhotoLibraryOption: Bool = false) {
        super.init()
        
        self.delegate = delegate
        self.inputView = inputView
        self.message = message
        self.messageFont = messageFont
        self.addFlashlight = addFlashlight
        self.addPickFromPhotoLibraryOption = addPickFromPhotoLibraryOption
        
        checkCameraPermission()
    }
    
    private func checkCameraPermission() {
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            prepareScanner()
            addCameraLayer()
        } else {
            requestCameraPermission()
        }
    }
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                self.delegate?.qrScannerDidApproveCameraUsageAuthorization()
                DispatchQueue.main.async {
                    self.prepareScanner()
                    self.addCameraLayer()
                    self.startRunning()
                }
            } else {
                // Permission denied, handle accordingly
                switch AVCaptureDevice.authorizationStatus(for: .video) {
                case .notDetermined:
                    // User has not yet made a choice, no need to do anything
                    break
                case .restricted, .denied:
                    // Permission denied or restricted, inform the user
                    self.delegate?.qrScannerDidDenyCameraUsageAuthorization()
                case .authorized:
                    break
                @unknown default:
                    break
                }
            }
        }
    }
    
    /// Initiates an ``AVCaptureSession`` and prepares it for identifying a QR code
    private func prepareScanner() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
    }
    
    public func startRunning() {
        if captureSession != nil {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.startRunning()
            }
        }
    }
    
    public func stopRunning() {
        if captureSession != nil {
            captureSession.stopRunning()
        }
    }
    
// MARK: - Setup UI -
    
    /// Creates a camera layer and adds to the input view as a subview
    private func addCameraLayer() {
        inputView.addSubview(baseView)
        NSLayoutConstraint.activate([
            baseView.topAnchor.constraint(equalTo: inputView.topAnchor),
            baseView.leadingAnchor.constraint(equalTo: inputView.leadingAnchor),
            baseView.trailingAnchor.constraint(equalTo: inputView.trailingAnchor),
            baseView.bottomAnchor.constraint(equalTo: inputView.bottomAnchor)
        ])
        baseView.layoutIfNeeded()
        
        baseView.layer.addSublayer(previewLayer)
        previewLayer.frame = baseView.bounds
        baseView.layoutIfNeeded()
        
        setupViews()
    }
    
    private func setupViews() {
        let cutoutWidth = baseView.bounds.width * 0.6
        let cutoutHeight = cutoutWidth
        
        // setup transparent view
        baseView.addSubview(transparentView)
        NSLayoutConstraint.activate([
            transparentView.leadingAnchor.constraint(equalTo: baseView.leadingAnchor),
            transparentView.trailingAnchor.constraint(equalTo: baseView.trailingAnchor),
            transparentView.topAnchor.constraint(equalTo: baseView.topAnchor),
            transparentView.bottomAnchor.constraint(equalTo: baseView.bottomAnchor),
        ])
        baseView.layoutIfNeeded()
        
        // setup cutout view
        baseView.addSubview(cutoutView)
        NSLayoutConstraint.activate([
            cutoutView.centerXAnchor.constraint(equalTo: baseView.centerXAnchor),
            cutoutView.centerYAnchor.constraint(equalTo: baseView.centerYAnchor, constant: -15.0),
            cutoutView.widthAnchor.constraint(equalToConstant: cutoutWidth),
            cutoutView.heightAnchor.constraint(equalToConstant: cutoutHeight)
        ])
        baseView.layoutIfNeeded()
        
        cutoutView.layer.cornerRadius = scannerAreaCornerRadius
        cutoutView.layer.borderWidth = scannerAreaBorderWidth
        cutoutView.layer.borderColor = scannerAreaBorderColor.cgColor
        
        // add message label if a message is found
        if let message = message {
            let messageLabel = UILabel()
            messageLabel.translatesAutoresizingMaskIntoConstraints = false
            messageLabel.text = message
            messageLabel.textColor = .white
            messageLabel.textAlignment = .center
            messageLabel.numberOfLines = 0
            messageLabel.font = messageFont ?? UIFont(name: "Helvetica", size: 16.0)
            baseView.addSubview(messageLabel)
            
            NSLayoutConstraint.activate([
                messageLabel.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: 20.0),
                messageLabel.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: -20.0),
                messageLabel.centerXAnchor.constraint(equalTo: baseView.centerXAnchor),
                messageLabel.bottomAnchor.constraint(equalTo: cutoutView.topAnchor, constant: -15.0)
            ])
            
            baseView.layoutIfNeeded()
        }
        
        // make the cutout part transparent
        DispatchQueue.main.async {
            let maskPath = UIBezierPath(roundedRect: self.transparentView.bounds, cornerRadius: 0)
            let cutoutPath = UIBezierPath(roundedRect: self.cutoutView.frame, cornerRadius: 12.0)
            maskPath.append(cutoutPath)
            maskPath.usesEvenOddFillRule = true
            
            // Create the mask layer
            let maskLayer = CAShapeLayer()
            maskLayer.path = maskPath.cgPath
            maskLayer.fillRule = .evenOdd
            self.transparentView.layer.mask = maskLayer
        }
        
        // add flashlight button and gallery button
        if addFlashlight ?? false || addPickFromPhotoLibraryOption ?? false {
            if addFlashlight ?? false {
                accesoriesStackView.addArrangedSubview(flashlightButton)
            }
            if addPickFromPhotoLibraryOption ?? false {
                accesoriesStackView.addArrangedSubview(photoLibraryButton)
            }
            
            baseView.addSubview(accesoriesStackView)
            NSLayoutConstraint.activate([
                accesoriesStackView.centerXAnchor.constraint(equalTo: baseView.centerXAnchor),
                accesoriesStackView.topAnchor.constraint(equalTo: cutoutView.bottomAnchor, constant: 15.0),
                accesoriesStackView.heightAnchor.constraint(equalToConstant: 30.0)
            ])
            baseView.layoutIfNeeded()
        }
    }
    
    private func failed() {
        // Handle failure scenario
    }
    
    // MARK: - Helper Methods -
    @objc private func toggleFlashlight() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                if device.torchMode == .off {
                    device.torchMode = .on
                    flashlightButton.setImage(UIImage(systemName: "flashlight.on.fill"), for: .normal)
                } else {
                    device.torchMode = .off
                    flashlightButton.setImage(UIImage(systemName: "flashlight.off.fill"), for: .normal)
                }
                device.unlockForConfiguration()
            } catch {
                print("Error toggling flashlight: \(error.localizedDescription)")
            }
        }
    }
    
    @objc private func selectImageFromPhotoLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        inputView?.window?.rootViewController?.present(imagePicker, animated: true, completion: nil)
    }
    
    private func detectQRCode(_ image: CIImage) {
        // Create a CIDetector object
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        
        // Get the features from the image
        let features = detector?.features(in: image)
        
        // Process the features
        if let firstFeature = features?.first as? CIQRCodeFeature {
            if let message = firstFeature.messageString {
                delegate?.qrScanner(self, didScanQRCode: message)
            }
        }
    }
    
}

// MARK: - Delegate methods -
extension JkQRScanner: UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCaptureMetadataOutputObjectsDelegate {
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for metadataObject in metadataObjects {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { continue }
            
            // Convert the metadata object's bounds to the preview layer coordinates
            if let transformedBounds = previewLayer?.transformedMetadataObject(for: metadataObject) {
                // Check if the transformed bounds intersect with the cutout area
                if cutoutView.frame.contains(transformedBounds.bounds) {
                    if let stringValue = readableObject.stringValue {
                        delegate?.qrScanner(self, didScanQRCode: stringValue)
                        return
                    }
                }
            }
        }
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let pickedImage = info[.originalImage] as? UIImage,
           let ciImage = CIImage(image: pickedImage) {
            detectQRCode(ciImage)
        }
    }
}

