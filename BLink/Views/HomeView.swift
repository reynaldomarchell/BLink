//
//  HomeView.swift
//  BLink
//
//  Created by reynaldo on 27/03/25.
//

import SwiftUI
import AVFoundation
import Vision
import CoreImage

struct HomeView: View {
    @State private var showRouteFinderView = false
    @State private var recognizedPlate: String?
    @State private var showScanResult = false
    @State private var isShowingManualInput = false
    @State private var isCameraAuthorized = false
    @State private var showTutorial = false
    @State private var capturedImage: CVPixelBuffer?
    @State private var isPlateDetected = false
    @State private var isProcessing = false
    @State private var detectedPlateText = ""
    @State private var scanFrameRect = CGRect(x: 0, y: 0, width: 250, height: 150)
    
    var body: some View {
        ZStack {
            // Camera view
            CameraView(recognizedPlate: $recognizedPlate,
                       showScanResult: $showScanResult,
                       capturedImage: $capturedImage,
                       isPlateDetected: $isPlateDetected,
                       detectedPlateText: $detectedPlateText,
                       scanFrameRect: $scanFrameRect,
                       manualCapture: false)
                .edgesIgnoringSafeArea(.all)
            
            // Overlay UI
            VStack {
                // Header
                ZStack{
                    Rectangle()
                        .foregroundStyle(.clear)
                        .frame(width: 402, height: 60)
                    HStack {
                        Text("B-Link")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding()
                            .foregroundColor(.white)
                        Spacer()
                        
                        Button(action: {
                            showTutorial = true
                        }) {
                            Image(systemName: "questionmark.circle")
                                .font(.title2)
                                .foregroundColor(.black)
                                .padding()
                                .background(Circle().fill(Color.white))
                        }
                        .padding()
                    }
                }
                Spacer()
                
                // Scanning frame with instructions
                VStack(spacing: 40) {
                    Text("Place the bus plate number\ninside the box")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.gray.opacity(0.7))
                        .cornerRadius(10)
                    
                    
                    // Scanning frame - this will be positioned over the camera view
                    ZStack{
                        Rectangle()
                            .stroke(style: StrokeStyle(lineWidth: 3, dash: [10, 5]))
                            .frame(width: 250, height: 150)
                            .foregroundColor(.white)
                            .background(Color.clear)
                            .overlay(
                                GeometryReader { geometry in
                                    Color.clear
                                        .onAppear {
                                            // Store the frame's position for region of interest
                                            let frame = geometry.frame(in: .global)
                                            scanFrameRect = frame
                                        }
                                }
                            )
                        
                        // No preview text
                    }
                    .frame(width: 250, height: 150)
                    
                    
                    // Capture button
                    Button(action: {
                        captureAndAnalyze()
                    }) {
                        ZStack {
                            Circle()
                                .fill(isProcessing ? Color.gray : Color.white)
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 2)
                                        .frame(width: 70, height: 70)
                                )
                            
                            if isProcessing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.5)
                            }
                        }
                    }
                    .disabled(isProcessing)
                    .padding(.top, 30)
                    
                    // Spacer to maintain layout
                    Spacer().frame(height: 10)
                    
                    // Divider with "or" text
                    HStack {
                        Rectangle()
                            .frame(height: 4)
                            .foregroundColor(.white)
                            .frame(width: 100)
                        
                        Text("or")
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                        
                        Rectangle()
                            .frame(height: 4)
                            .foregroundColor(.white)
                            .frame(width: 100)
                    }
                    .padding(.vertical)
                    
                    // Search route option
                    Button(action: {
                        showRouteFinderView = true
                    }) {
                        HStack {
                            Text("Search your route ")
                                .foregroundColor(.white)
                            
                            Text("here")
                                .foregroundColor(.yellow)
                                .fontWeight(.bold)
                                .underline()
                        }
                    }
                    .padding(.bottom, 50)
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
        .alert(isPresented: .constant(!isCameraAuthorized && AVCaptureDevice.authorizationStatus(for: .video) == .denied)) {
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
    
    private func captureAndAnalyze() {
        if isProcessing { return }
        
        isProcessing = true
        
        if isPlateDetected && isValidIndonesianPlate(detectedPlateText) {
            // If plate is already detected and valid, use the detected text
            recognizedPlate = detectedPlateText
            showScanResult = true
            isProcessing = false
        } else if let pixelBuffer = capturedImage {
            // Otherwise try to analyze the current frame
            analyzeImage(pixelBuffer)
        } else {
            isProcessing = false
        }
    }
    
    private func isValidIndonesianPlate(_ text: String) -> Bool {
        // Check if the text matches the Indonesian plate format
        // 1-2 letters (region) + 1-4 digits (number) + 1-3 letters (identifier)
        let platePattern = "^[A-Z]{1,2}\\s?\\d{1,4}\\s?[A-Z]{1,3}$"
        return text.range(of: platePattern, options: .regularExpression) != nil
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
        case .denied, .restricted:
            isCameraAuthorized = false
        @unknown default:
            isCameraAuthorized = false
        }
    }
    
    private func analyzeImage(_ pixelBuffer: CVPixelBuffer) {
        // Create a request to recognize text
        let request = VNRecognizeTextRequest { request, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    self.isProcessing = false
                }
                return
            }
            
            if let results = request.results as? [VNRecognizedTextObservation] {
                // Process text observations
                let recognizedStrings = results.compactMap { observation in
                    // Get multiple candidates to improve chances of finding the plate
                    observation.topCandidates(3).map { $0.string }
                }.flatMap { $0 }
                
                // Look for patterns that might be bus plate numbers
                var plateFound = false
                
                for string in recognizedStrings {
                    // Try to find a plate number in the recognized text
                    if let plateNumber = self.extractPlateNumber(from: string) {
                        DispatchQueue.main.async {
                            self.recognizedPlate = plateNumber
                            self.showScanResult = true
                            self.isProcessing = false
                        }
                        plateFound = true
                        return
                    }
                }
                
                // If no plate was found, try a manual capture anyway
                if !plateFound {
                    DispatchQueue.main.async {
                        // If we have any text at all, try to use it
                        if !recognizedStrings.isEmpty {
                            // Try to find anything that looks like a plate
                            for string in recognizedStrings {
                                // Check if it matches the basic pattern of a license plate
                                if self.looksLikePlate(string) {
                                    self.recognizedPlate = string
                                    self.showScanResult = true
                                    self.isProcessing = false
                                    return
                                }
                            }
                            
                            // If nothing looks like a plate, use the first string
                            self.isShowingManualInput = true
                        } else {
                            self.isShowingManualInput = true
                        }
                        self.isProcessing = false
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.isShowingManualInput = true
                }
            }
        }
        
        // Configure the request for optimal text recognition
        request.recognitionLevel = .accurate // Use accurate for the final capture
        request.usesLanguageCorrection = false
        request.revision = 3 // Use the latest revision for better accuracy
        
        // Create a handler to perform the request
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform text recognition: \(error)")
            DispatchQueue.main.async {
                self.isProcessing = false
                self.isShowingManualInput = true
            }
        }
    }
    
    // Helper function to check if a string looks like a license plate
    private func looksLikePlate(_ text: String) -> Bool {
        // Must have at least one letter and one number
        let hasLetters = text.rangeOfCharacter(from: .letters) != nil
        let hasNumbers = text.rangeOfCharacter(from: .decimalDigits) != nil
        
        // Must not be too long or too short
        let validLength = text.count >= 5 && text.count <= 10
        
        // Must not be common bus text like "BSDCITY"
        let commonBusText = ["BSDCITY", "BSD", "CITY", "BUS", "BUSWAY", "TRANS"]
        let isCommonText = commonBusText.contains { text.uppercased().contains($0) }
        
        return hasLetters && hasNumbers && validLength && !isCommonText
    }
    
    // Helper function to extract plate number from text
    private func extractPlateNumber(from text: String) -> String? {
        // Standard Indonesian license plate pattern:
        // 1-2 letters (region) + 1-4 digits (number) + 1-3 letters (identifier)
        // Examples: B 7366 JE, DK 1234 AB
        let platePattern = "\\b[A-Z]{1,2}\\s?\\d{1,4}\\s?[A-Z]{1,3}\\b"
        
        if let regex = try? NSRegularExpression(pattern: platePattern) {
            let range = NSRange(location: 0, length: text.utf16.count)
            if let match = regex.firstMatch(in: text, range: range) {
                let matchRange = match.range
                if let range = Range(matchRange, in: text) {
                    let plateNumber = String(text[range])
                    
                    // Additional validation - check if it has the right format
                    // Must have at least one letter, followed by numbers, followed by letters
                    let hasCorrectFormat = plateNumber.range(of: "^[A-Z]{1,2}.*\\d+.*[A-Z]{1,3}$", options: .regularExpression) != nil
                    
                    // Check if it's not a common bus text
                    let commonBusText = ["BSDCITY", "BSD", "CITY", "BUS", "BUSWAY", "TRANS"]
                    let isNotCommonText = !commonBusText.contains { plateNumber.uppercased().contains($0) }
                    
                    if hasCorrectFormat && isNotCommonText {
                        return plateNumber
                    }
                }
            }
        }
        
        return nil
    }
}

// Camera view using UIViewRepresentable
struct CameraView: UIViewRepresentable {
    @Binding var recognizedPlate: String?
    @Binding var showScanResult: Bool
    @Binding var capturedImage: CVPixelBuffer?
    @Binding var isPlateDetected: Bool
    @Binding var detectedPlateText: String
    @Binding var scanFrameRect: CGRect
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
        context.coordinator.scanFrameRect = scanFrameRect
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
        private var lastProcessingTime: Date = Date()
        private let processingInterval: TimeInterval = 0.2 // Process frames more frequently
        private var plateDetectionHistory: [String: Int] = [:]
        private let confidenceThreshold = 3
        var scanFrameRect: CGRect = .zero
        private var screenSize: CGSize = UIScreen.main.bounds.size
        
        init(_ parent: CameraView) {
            self.parent = parent
            super.init()
        }
        
        func setupCamera() -> UIView {
            let cameraView = UIView(frame: UIScreen.main.bounds)
            screenSize = cameraView.bounds.size
            
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
                
                // Enable auto-focus
                if camera.isFocusModeSupported(.continuousAutoFocus) {
                    camera.focusMode = .continuousAutoFocus
                }
                
                // Enable auto-exposure
                if camera.isExposureModeSupported(.continuousAutoExposure) {
                    camera.exposureMode = .continuousAutoExposure
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
            
            // Check if enough time has passed since last processing
            let currentTime = Date()
            if currentTime.timeIntervalSince(lastProcessingTime) < processingInterval {
                return
            }
            
            lastProcessingTime = currentTime
            
            // Perform real-time text detection
            detectPlateInFrame(pixelBuffer)
        }
        
        private func detectPlateInFrame(_ pixelBuffer: CVPixelBuffer) {
            // Skip if scan frame is not set yet
            if scanFrameRect == .zero {
                return
            }
            
            // Convert UI coordinates to normalized coordinates for Vision
            let normalizedRect = convertToNormalizedRect(scanFrameRect, pixelBuffer: pixelBuffer)
            
            let request = VNRecognizeTextRequest { [weak self] request, error in
                guard let self = self, error == nil else { return }
                
                if let results = request.results as? [VNRecognizedTextObservation] {
                    // Process text observations
                    let recognizedStrings = results.compactMap { observation in
                        // Get multiple candidates to improve chances of finding the plate
                        observation.topCandidates(5).map { $0.string }
                    }.flatMap { $0 }
                    
                    var plateDetected = false
                    var plateText = ""
                    
                    // Look for Indonesian license plate pattern with more flexibility
                    // Format: B 7366 JE (1-2 letters + space + 1-4 digits + space + 1-3 letters)
                    let platePattern = "\\b[A-Z]{1,2}\\s*\\d{1,4}\\s*[A-Z]{1,3}\\b"
                    
                    for string in recognizedStrings {
                        // Clean up the string - remove unwanted characters
                        let cleanedString = string.replacingOccurrences(of: "BSDCITY", with: "")
                                           .replacingOccurrences(of: "BSD", with: "")
                                           .replacingOccurrences(of: "CITY", with: "")
                                           .trimmingCharacters(in: .whitespacesAndNewlines)
                  
                        if let regex = try? NSRegularExpression(pattern: platePattern) {
                            let range = NSRange(location: 0, length: cleanedString.utf16.count)
                            if let match = regex.firstMatch(in: cleanedString, range: range) {
                                let matchRange = match.range
                                if let range = Range(matchRange, in: cleanedString) {
                                    let candidate = String(cleanedString[range])
                                    
                                    // Additional validation
                                    let hasCorrectFormat = candidate.range(of: "^[A-Z]{1,2}\\s*\\d{1,4}\\s*[A-Z]{1,3}$", options: .regularExpression) != nil
                                    
                                    // Check if it's not a common bus text
                                    let commonBusText = ["BSDCITY", "BSD", "CITY", "BUS", "BUSWAY", "TRANS"]
                                    let isNotCommonText = !commonBusText.contains { candidate.uppercased().contains($0) }
                                    
                                    if hasCorrectFormat && isNotCommonText {
                                        plateDetected = true
                                        plateText = candidate
                                        
                                        // Format the plate number consistently
                                        if let formattedPlate = self.formatPlateNumber(plateText) {
                                            plateText = formattedPlate
                                        }
                                        
                                        break
                                    }
                                }
                            }
                        }
                        
                        // Also try to match just the pattern "B 7366" (letter + space + numbers)
                        let simplePattern = "\\b[A-Z]\\s*\\d{4}\\b"
                        if let regex = try? NSRegularExpression(pattern: simplePattern) {
                            let range = NSRange(location: 0, length: cleanedString.utf16.count)
                            if let match = regex.firstMatch(in: cleanedString, range: range) {
                                let matchRange = match.range
                                if let range = Range(matchRange, in: cleanedString) {
                                    let candidate = String(cleanedString[range])
                                    
                                    // If we find a simple pattern and haven't found a full plate yet
                                    if !plateDetected {
                                        plateDetected = true
                                        plateText = candidate
                                        
                                        // Try to find the JE part separately
                                        let letterPattern = "\\b[A-Z]{2}\\b"
                                        if let letterRegex = try? NSRegularExpression(pattern: letterPattern) {
                                            let letterRange = NSRange(location: 0, length: cleanedString.utf16.count)
                                            if let letterMatch = letterRegex.firstMatch(in: cleanedString, range: letterRange) {
                                                if let letterMatchRange = Range(letterMatch.range, in: cleanedString) {
                                                    let letters = String(cleanedString[letterMatchRange])
                                                    if letters != "BS" && letters != "SD" {
                                                        plateText += " " + letters
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Implement confidence-based detection with history tracking
                    if plateDetected {
                        // Update confidence for this plate
                        let currentConfidence = self.plateDetectionHistory[plateText] ?? 0
                        self.plateDetectionHistory[plateText] = currentConfidence + 1
                        
                        // Decay confidence for other plates
                        for (plate, confidence) in self.plateDetectionHistory where plate != plateText {
                            self.plateDetectionHistory[plate] = max(0, confidence - 1)
                        }
                        
                        // Find the plate with the highest confidence
                        if let (mostConfidentPlate, confidence) = self.plateDetectionHistory.max(by: { $0.value < $1.value }) {
                            if confidence >= self.confidenceThreshold {
                                plateDetected = true
                                plateText = mostConfidentPlate
                            } else {
                                plateDetected = false
                            }
                        } else {
                            plateDetected = false
                        }
                    } else {
                        // Decay all confidences when no plate is detected
                        for plate in self.plateDetectionHistory.keys {
                            self.plateDetectionHistory[plate] = max(0, (self.plateDetectionHistory[plate] ?? 0) - 1)
                        }
                        
                        // Remove plates with zero confidence
                        self.plateDetectionHistory = self.plateDetectionHistory.filter { $0.value > 0 }
                    }
                    
                    // Store the detected plate text for capture button use, but don't update UI
                    DispatchQueue.main.async {
                        if plateDetected {
                            self.parent.detectedPlateText = plateText
                        }
                    }
                }
            }
            
            // Configure the request for optimal text recognition
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = false
            request.revision = 3
            
            // Set the region of interest to the scan frame with a tighter boundary
            request.regionOfInterest = normalizedRect
            
            // Create a handler to perform the request
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                print("Failed to perform text recognition: \(error)")
            }
        }
        
        // Helper function to format plate numbers consistently
        private func formatPlateNumber(_ plateText: String) -> String? {
            // Try to extract the components of the plate number
            let components = plateText.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            
            // Check if we have enough components
            if components.count >= 2 {
                // First component should be a letter (region code)
                let regionCode = components[0]
                
                // Second component should be numbers
                let numbers = components[1]
                
                // Third component (if exists) should be letters
                var identifier = ""
                if components.count >= 3 {
                    identifier = components[2]
                }
                
                // If we have all three parts, format as "B 7366 JE"
                if !regionCode.isEmpty && !numbers.isEmpty && !identifier.isEmpty {
                    return "\(regionCode) \(numbers) \(identifier)"
                }
                
                // If we only have region and numbers, format as "B 7366"
                if !regionCode.isEmpty && !numbers.isEmpty {
                    return "\(regionCode) \(numbers)"
                }
            }
            
            // If we couldn't parse it properly, return the original
            return nil
        }
        
        // Convert UI coordinates to normalized coordinates for Vision framework
        private func convertToNormalizedRect(_ rect: CGRect, pixelBuffer: CVPixelBuffer) -> CGRect {
            let pixelBufferWidth = CGFloat(CVPixelBufferGetWidth(pixelBuffer))
            let pixelBufferHeight = CGFloat(CVPixelBufferGetHeight(pixelBuffer))
            
            // Calculate the scale factors
            let scaleX = pixelBufferWidth / screenSize.width
            let scaleY = pixelBufferHeight / screenSize.height
            
            // Convert to pixel buffer coordinates
            let x = rect.origin.x * scaleX
            let y = rect.origin.y * scaleY
            let width = rect.size.width * scaleX
            let height = rect.size.height * scaleY
            
            // Normalize coordinates (Vision uses normalized coordinates)
            let normalizedX = x / pixelBufferWidth
            let normalizedY = 1.0 - ((y + height) / pixelBufferHeight) // Flip Y coordinate
            let normalizedWidth = width / pixelBufferWidth
            let normalizedHeight = height / pixelBufferHeight
            
            // Create normalized rect with minimal padding to focus on the frame
            let padding = 0.02 // 2% padding
            return CGRect(
                x: max(0, normalizedX - padding),
                y: max(0, normalizedY - padding),
                width: min(1.0, normalizedWidth + (padding * 2)),
                height: min(1.0, normalizedHeight + (padding * 2))
            )
        }
    }
}

#Preview {
    HomeView()
}

