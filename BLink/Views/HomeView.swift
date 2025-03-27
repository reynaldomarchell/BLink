//
//  HomeView.swift
//  BLink
//
//  Created by reynaldo on 27/03/25.
//

import SwiftUI
import AVFoundation
import Vision

struct HomeView: View {
    @State private var showRouteFinderView = false
    @State private var recognizedPlate: String?
    @State private var showScanResult = false
    @State private var isShowingManualInput = false
    @State private var isCameraAuthorized = false
    @State private var showTutorial = false
    @State private var capturedImage: CVPixelBuffer?
    
    var body: some View {
        ZStack {
            // Camera view
            CameraView(recognizedPlate: $recognizedPlate,
                       showScanResult: $showScanResult,
                       capturedImage: $capturedImage,
                       manualCapture: true)
                .edgesIgnoringSafeArea(.all)
            
            // Overlay UI
            VStack {
                // Header
                HStack {
                    Text("Blink")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                    
                    Spacer()
                    
                    Button(action: {
                        showTutorial = true
                    }) {
                        Image(systemName: "questionmark.circle")
                            .font(.title)
                            .foregroundColor(.primary)
                            .padding()
                            .background(Circle().fill(Color.white))
                    }
                    .padding()
                }
                
                Spacer()
                
                // Scanning frame with instructions
                VStack(spacing: 20) {
                    Text("Place the bus plate number\ninside the box")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.gray.opacity(0.7))
                        .cornerRadius(10)
                    
                    // Scanning frame - this will be positioned over the camera view
                    ZStack {
                        Rectangle()
                            .stroke(style: StrokeStyle(lineWidth: 3, dash: [10, 5]))
                            .frame(width: 250, height: 150)
                            .foregroundColor(.white)
                    }
                    .frame(width: 250, height: 150)
                    
                    // Capture button
                    Button(action: {
                        if let pixelBuffer = capturedImage {
                            analyzeImage(pixelBuffer)
                        }
                    }) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 60, height: 60)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                                    .frame(width: 70, height: 70)
                            )
                    }
                    .padding(.top, 30)
                    
                    // Divider with "or" text
                    HStack {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.white)
                            .frame(width: 100)
                        
                        Text("or")
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                        
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.white)
                            .frame(width: 100)
                    }
                    .padding(.vertical)
                    
                    // Manual input option
                    Button(action: {
                        isShowingManualInput = true
                    }) {
                        Text("Input the bus plate here.")
                            .foregroundColor(.yellow)
                            .underline()
                    }
                    .padding(.bottom, 10)
                    
                    // Search route option
                    Button(action: {
                        showRouteFinderView = true
                    }) {
                        HStack {
                            Text("Search your route ")
                                .foregroundColor(.white)
                            
                            Text("here")
                                .foregroundColor(.yellow)
                                .underline()
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            checkCameraPermission()
        }
        .sheet(isPresented: $showScanResult) {
            if let plate = recognizedPlate {
                ScanResultView(plateNumber: plate)
            }
        }
        .sheet(isPresented: $showRouteFinderView) {
            RouteFinderView()
        }
        .sheet(isPresented: $isShowingManualInput) {
            ManualPlateInputView(onSubmit: { plate in
                recognizedPlate = plate
                isShowingManualInput = false
                showScanResult = true
            })
        }
        .fullScreenCover(isPresented: $showTutorial) {
            TutorialContent(isPresented: $showTutorial)
        }
        .alert(isPresented: .constant(!isCameraAuthorized)) {
            Alert(
                title: Text("Camera Access Required"),
                message: Text("B-Link needs camera access to scan bus plates. Please enable it in Settings."),
                primaryButton: .default(Text("Settings"), action: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }),
                secondaryButton: .cancel()
            )
        }
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isCameraAuthorized = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.isCameraAuthorized = granted
                }
            }
        default:
            isCameraAuthorized = false
        }
    }
    
    private func analyzeImage(_ pixelBuffer: CVPixelBuffer) {
        // Create a request to recognize text
        let request = VNRecognizeTextRequest { request, error in
            guard error == nil else { return }
            
            if let results = request.results as? [VNRecognizedTextObservation] {
                // Process text observations
                let recognizedStrings = results.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }
                
                // Look for patterns that might be bus plate numbers
                for string in recognizedStrings {
                    // Pattern matching for bus plates
                    // Looking for patterns like "S11 BSD", "B 1234 XYZ", etc.
                    let busPlatePattern1 = "\\b[A-Z]\\d{1,4}\\s?[A-Z]{2,3}\\b" // S11 BSD
                    let busPlatePattern2 = "\\b[A-Z]\\s?\\d{1,4}\\s?[A-Z]{2,3}\\b" // B 1234 XYZ
                    
                    let regex1 = try? NSRegularExpression(pattern: busPlatePattern1)
                    let regex2 = try? NSRegularExpression(pattern: busPlatePattern2)
                    
                    let range = NSRange(location: 0, length: string.utf16.count)
                    
                    if (regex1?.firstMatch(in: string, range: range) != nil) ||
                       (regex2?.firstMatch(in: string, range: range) != nil) ||
                       string.contains("BSD") || string.contains("S11") {
                        
                        DispatchQueue.main.async {
                            self.recognizedPlate = string
                            self.showScanResult = true
                        }
                        break
                    }
                }
            }
        }
        
        // Configure the request for optimal text recognition
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        request.customWords = ["BSD", "S11", "AEON", "ICE", "LOOP", "LINE"]
        
        // Create a handler to perform the request
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform text recognition: \(error)")
        }
    }
}

// Camera view using UIViewRepresentable
struct CameraView: UIViewRepresentable {
    @Binding var recognizedPlate: String?
    @Binding var showScanResult: Bool
    @Binding var capturedImage: CVPixelBuffer?
    var manualCapture: Bool
    
    // Create the UIView
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .black
        
        let cameraView = context.coordinator.setupCamera()
        view.addSubview(cameraView)
        cameraView.frame = view.bounds
        
        return view
    }
    
    // Update the view if needed
    func updateUIView(_ uiView: UIView, context: Context) {
        // Nothing to update
    }
    
    // Create the coordinator
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Coordinator class to handle camera setup and text recognition
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        var parent: CameraView
        var captureSession: AVCaptureSession?
        var previewLayer: AVCaptureVideoPreviewLayer?
        
        init(_ parent: CameraView) {
            self.parent = parent
            super.init()
        }
        
        func setupCamera() -> UIView {
            let cameraView = UIView(frame: UIScreen.main.bounds)
            
            // Initialize capture session
            let captureSession = AVCaptureSession()
            self.captureSession = captureSession
            
            // Set up camera input
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                print("No camera available")
                return cameraView
            }
            
            do {
                // Configure camera for high resolution
                try camera.lockForConfiguration()
                if camera.isAutoFocusRangeRestrictionSupported {
                    camera.autoFocusRangeRestriction = .near
                }
                camera.unlockForConfiguration()
                
                // Add camera input to session
                let input = try AVCaptureDeviceInput(device: camera)
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                }
                
                // Set up video output
                let videoOutput = AVCaptureVideoDataOutput()
                videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
                videoOutput.alwaysDiscardsLateVideoFrames = true
                
                if captureSession.canAddOutput(videoOutput) {
                    captureSession.addOutput(videoOutput)
                }
                
                // Configure session for high resolution
                captureSession.sessionPreset = .high
                
                // Set up preview layer
                let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                self.previewLayer = previewLayer
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.frame = cameraView.bounds
                cameraView.layer.addSublayer(previewLayer)
                
                // Start session in background
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    self?.captureSession?.startRunning()
                }
                
            } catch {
                print("Camera setup error: \(error.localizedDescription)")
            }
            
            return cameraView
        }
        
        // Process video frames
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            
            // Store the current frame for manual capture
            DispatchQueue.main.async {
                self.parent.capturedImage = pixelBuffer
            }
            
            // If manual capture is enabled, don't do automatic recognition
            if parent.manualCapture {
                return
            }
            
            // The code below will only run if manualCapture is false (automatic mode)
            // For automatic text recognition (not used in this implementation)
        }
    }
}

#Preview {
    HomeView()
}

