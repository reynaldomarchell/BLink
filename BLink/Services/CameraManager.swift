//
//  CameraManager.swift
//  BLink
//
//  Created by reynaldo on 25/03/25.
//

import AVFoundation
import UIKit
import SwiftUI

class CameraManager: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var session = AVCaptureSession()
    @Published var output = AVCapturePhotoOutput()
    @Published var preview: AVCaptureVideoPreviewLayer?
    @Published var isCameraAuthorized = false
    @Published var isCameraAvailable = false
    @Published var error: CameraError?
    
    enum CameraError: Error, LocalizedError {
        case cameraUnavailable
        case cannotAddInput
        case cannotAddOutput
        case createCaptureInput(Error)
        case deniedAuthorization
        case restrictedAuthorization
        
        var errorDescription: String? {
            switch self {
            case .cameraUnavailable:
                return "Camera unavailable"
            case .cannotAddInput:
                return "Cannot add capture input to session"
            case .cannotAddOutput:
                return "Cannot add video output to session"
            case .createCaptureInput(let error):
                return "Error creating capture input: \(error.localizedDescription)"
            case .deniedAuthorization:
                return "Camera access denied"
            case .restrictedAuthorization:
                return "Camera access restricted"
            }
        }
    }
    
    override init() {
        super.init()
        checkPermissions()
    }
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.isCameraAuthorized = true
            self.setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.isCameraAuthorized = granted
                    if granted {
                        self?.setupCamera()
                    }
                }
            }
        case .denied:
            self.error = .deniedAuthorization
        case .restricted:
            self.error = .restrictedAuthorization
        @unknown default:
            break
        }
    }
    
    func setupCamera() {
        do {
            self.session.beginConfiguration()
            
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                self.error = .cameraUnavailable
                self.session.commitConfiguration()
                return
            }
            
            let input = try AVCaptureDeviceInput(device: device)
            
            if self.session.canAddInput(input) {
                self.session.addInput(input)
            } else {
                self.error = .cannotAddInput
                self.session.commitConfiguration()
                return
            }
            
            if self.session.canAddOutput(self.output) {
                self.session.addOutput(self.output)
            } else {
                self.error = .cannotAddOutput
                self.session.commitConfiguration()
                return
            }
            
            self.session.commitConfiguration()
            self.isCameraAvailable = true
            
        } catch {
            self.error = .createCaptureInput(error)
        }
    }
    
    func start() {
        guard !session.isRunning && isCameraAvailable else { return }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }
    
    func stop() {
        guard session.isRunning else { return }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.stopRunning()
        }
    }
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        guard isCameraAvailable else {
            completion(nil)
            return
        }
        
        let settings = AVCapturePhotoSettings()
        self.output.capturePhoto(with: settings, delegate: PhotoCaptureProcessor { image in
            completion(image)
        })
    }
    
    // Photo capture processor to handle the photo capture delegate methods
    class PhotoCaptureProcessor: NSObject, AVCapturePhotoCaptureDelegate {
        private let completion: (UIImage?) -> Void
        
        init(completion: @escaping (UIImage?) -> Void) {
            self.completion = completion
        }
        
        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            if let error = error {
                print("Error capturing photo: \(error)")
                completion(nil)
                return
            }
            
            guard let imageData = photo.fileDataRepresentation(),
                  let image = UIImage(data: imageData) else {
                completion(nil)
                return
            }
            
            completion(image)
        }
    }
}

// SwiftUI wrapper for the camera preview
struct CameraPreview: UIViewRepresentable {
    @ObservedObject var cameraManager: CameraManager
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        cameraManager.preview = AVCaptureVideoPreviewLayer(session: cameraManager.session)
        cameraManager.preview?.frame = view.bounds
        cameraManager.preview?.videoGravity = .resizeAspectFill
        
        if let preview = cameraManager.preview {
            view.layer.addSublayer(preview)
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            cameraManager.start()
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
