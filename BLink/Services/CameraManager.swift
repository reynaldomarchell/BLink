//
//  CameraManager.swift
//  BLink
//
//  Created by reynaldo on 25/03/25.
//

import AVFoundation
import UIKit
import SwiftUI

class CameraManager: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    @Published var output = AVCapturePhotoOutput()
    @Published var preview: AVCaptureVideoPreviewLayer?
    @Published var isCameraAuthorized = false
    @Published var isCameraAvailable = false
    @Published var error: CameraError?
    
    enum CameraError: Error, LocalizedError, Identifiable {
        case cameraUnavailable
        case cannotAddInput
        case cannotAddOutput
        case createCaptureInput(Error)
        case deniedAuthorization
        case restrictedAuthorization
        
        var id: String { localizedDescription }
        
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
        // Run camera setup on a background thread to avoid UI freezes
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // Check if session is already running
            if self.session.isRunning {
                return
            }
            
            do {
                // Begin configuration
                self.session.beginConfiguration()
                
                // Remove any existing inputs and outputs
                for input in self.session.inputs {
                    self.session.removeInput(input)
                }
                
                for output in self.session.outputs {
                    self.session.removeOutput(output)
                }
                
                // Get camera device
                guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                    DispatchQueue.main.async {
                        self.error = .cameraUnavailable
                    }
                    self.session.commitConfiguration()
                    return
                }
                
                // Create input
                let input = try AVCaptureDeviceInput(device: device)
                
                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                } else {
                    DispatchQueue.main.async {
                        self.error = .cannotAddInput
                    }
                    self.session.commitConfiguration()
                    return
                }
                
                // Create output
                if self.session.canAddOutput(self.output) {
                    self.session.addOutput(self.output)
                } else {
                    DispatchQueue.main.async {
                        self.error = .cannotAddOutput
                    }
                    self.session.commitConfiguration()
                    return
                }
                
                // Set session preset
                self.session.sessionPreset = .high
                
                // Commit configuration
                self.session.commitConfiguration()
                
                // Update state
                DispatchQueue.main.async {
                    self.isCameraAvailable = true
                }
                
                // Start running the session
                self.session.startRunning()
                
            } catch {
                DispatchQueue.main.async {
                    self.error = .createCaptureInput(error)
                }
            }
        }
    }
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        guard isCameraAvailable, session.isRunning else {
            completion(nil)
            return
        }
        
        let settings = AVCapturePhotoSettings()
        
        self.output.capturePhoto(with: settings, delegate: PhotoCaptureProcessor(completion: completion))
    }
    
    func stop() {
        if session.isRunning {
            session.stopRunning()
        }
    }
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

// SwiftUI wrapper for the camera preview
struct CameraPreview: UIViewRepresentable {
    @ObservedObject var cameraManager: CameraManager
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        DispatchQueue.main.async {
            cameraManager.preview = AVCaptureVideoPreviewLayer(session: cameraManager.session)
            cameraManager.preview?.frame = view.bounds
            cameraManager.preview?.videoGravity = .resizeAspectFill
            cameraManager.preview?.connection?.videoOrientation = .portrait
            
            if let preview = cameraManager.preview {
                view.layer.addSublayer(preview)
            }
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let preview = cameraManager.preview {
            preview.frame = uiView.bounds
        }
    }
}
