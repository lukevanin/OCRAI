//
//  CameraViewController.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/15.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    private let cancelSegue = "cancel"
    
    private var captureSession: AVCaptureSession!
    private var photoOutput: AVCapturePhotoOutput!
    fileprivate var imageContext: CIContext!
    fileprivate var selectedImageData: Data? {
        didSet {
            self.updateViewState()
        }
    }
    
    @IBOutlet weak var cameraView: CameraView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var previewControlsView: UIView!
    
    @IBAction func onCameraAction(_ sender: Any) {
        let format: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecJPEG,
            AVVideoCompressionPropertiesKey: [
                AVVideoQualityKey: NSNumber(floatLiteral: 1.0)
                ]
        ]
        let settings = AVCapturePhotoSettings(format: format)
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @IBAction func onUsePhotoButton(_ sender: Any) {
        performSegue(withIdentifier: cancelSegue, sender: selectedImageData)
    }
    
    @IBAction func retakePhotoButton(_ sender: Any) {
        selectedImageData = nil
    }
    
    @IBAction func onCancelAction(_ sender: Any) {
        performSegue(withIdentifier: cancelSegue, sender: nil)
    }
    
    // MARK: Life cycle
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeImageContext()
        initializeCamera()
        updateViewState()
    }
    
    // MARK: Camera
    
    private func initializeImageContext() {
        let eaglContext = EAGLContext(api: .openGLES2)
        let options: [String: Any] = [
            kCIContextHighQualityDownsample: NSNumber(booleanLiteral: true)
        ]
        imageContext = CIContext(eaglContext: eaglContext!, options: options)
    }
    
    private func initializeCamera() {
        
        let deviceSession = AVCaptureDeviceDiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: AVMediaTypeVideo,
            position: .back
        )

        let device = deviceSession?.devices.first
        let cameraInput = try? AVCaptureDeviceInput(device: device)
        
        photoOutput = AVCapturePhotoOutput()
        
        print("==========")
        print("Available capture formats:")
        print("  Pixel formats: \(photoOutput.availablePhotoPixelFormatTypes)")
        print("  Photo codecs: \(photoOutput.availablePhotoCodecTypes)")
        print("  Raw pixel formats: \(photoOutput.availableRawPhotoPixelFormatTypes)")
        print("==========")
        print("")
        
        captureSession = AVCaptureSession()

        if captureSession.canAddInput(cameraInput) {
            captureSession.addInput(cameraInput)
        }
        
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        
        cameraView.previewLayer?.session = captureSession
    }
    
    private func updateViewState() {
        if let imageData = selectedImageData {
            // Selected image
            captureSession.stopRunning()
            previewImageView.isHidden = false
            previewControlsView.isHidden = false
            cameraView.isHidden = true
            cameraButton.isHidden = true
            previewImageView.image = UIImage(data: imageData)
        }
        else {
            // Capture mode.
            captureSession.startRunning()
            previewImageView.isHidden = true
            previewControlsView.isHidden = true
            cameraView.isHidden = false
            cameraButton.isHidden = false
        }
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
 
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        guard let photoSampleBuffer = photoSampleBuffer else {
            print("Cannot capture photo, photo sample buffer uavailable.")
            return
        }
        
        let jpegData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
        
        guard let imageData = jpegData else {
            print("Cannot capture photo, cannot convert image buffer to image.")
            return
        }
        
        DispatchQueue.main.async {
            self.selectedImageData = imageData
        }
    }
}
