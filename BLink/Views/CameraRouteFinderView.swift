//
//  CameraRouteFinderView.swift
//  BLink
//
//  Created by reynaldo on 25/03/25.
//

import SwiftUI
import AVFoundation
import Vision

struct CameraRouteFinderView: View {
    var startPoint: String
    var destination: String
    var onDismiss: () -> Void
    
    @StateObject private var cameraManager = CameraManager()
    @State private var isScanning = false
    @State private var scanResult: ScanResult? = nil
    @State private var showResult = false
    @State private var showTutorial = false
    @State private var showRouteFinder = false
    
    enum ScanResult {
        case success(Bus)
        case failure
    }
    
    var body: some View {
        ZStack {
            // Real camera view
            if cameraManager.isCameraAvailable {
                CameraPreview(cameraManager: cameraManager)
                    .edgesIgnoringSafeArea(.all)
            } else {
                // Fallback if camera is not available
                Color.black.edgesIgnoringSafeArea(.all)
                    .overlay(
                        Text(cameraManager.error?.localizedDescription ?? "Camera initializing...")
                            .foregroundColor(.white)
                            .padding()
                    )
            }
            
            // Top right buttons
            VStack {
                HStack {
                    Spacer()
                    VStack(spacing: 20) {
                        Button(action: {
                            showTutorial = true
                        }) {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        
                        Button(action: {
                            onDismiss()
                        }) {
                            Image(systemName: "arrow.left.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.top, 60)
                    .padding(.trailing, 20)
                }
                Spacer()
            }
            
            // Bottom area with shutter button and route info
            VStack {
                Spacer()
                
                if isScanning {
                    // Scanning indicator
                    HStack {
                        Image(systemName: "bus")
                        Text("Scanning the Bus...")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(20)
                } else {
                    // Camera shutter and route info
                    VStack(spacing: 20) {
                        // Shutter button
                        Button(action: {
                            scanBus()
                        }) {
                            Image(systemName: "camera.circle.fill")
                                .font(.system(size: 70))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 0)
                        }
                        
                        // Route info button
                        Button(action: {
                            showRouteFinder = true
                        }) {
                            VStack(spacing: 8) {
                                Text("Starting Point")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text(startPoint)
                                    .fontWeight(.medium)
                                
                                Divider()
                                
                                Text("Destination")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text(destination)
                                    .fontWeight(.medium)
                            }
                            .padding()
                            .frame(width: UIScreen.main.bounds.width - 40)
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                    }
                }
                
                // Add consistent bottom padding
                Spacer().frame(height: 40)
            }
        }
        .onAppear {
            // Initialize camera when view appears
            cameraManager.checkPermissions()
        }
        .onDisappear {
            // Stop camera when view disappears
            cameraManager.stop()
        }
        .sheet(isPresented: $showTutorial) {
            TutorialView(isPresented: $showTutorial)
        }
        .sheet(isPresented: $showRouteFinder) {
            RouteFinderView(
                isPresented: $showRouteFinder,
                initialStartPoint: startPoint,
                initialDestination: destination,
                onRouteSelected: { start, destination in
                    // Return to camera view with updated route
                    onDismiss()
                    // This would update the parent view's route
                }
            )
        }
        .sheet(isPresented: $showResult) {
            if let result = scanResult {
                switch result {
                case .success(let bus):
                    ResultSuccessView(bus: bus, isPresented: $showResult)
                case .failure:
                    ResultFailureView(isPresented: $showResult)
                }
            }
        }
        .alert(item: $cameraManager.error) { error in
            Alert(
                title: Text("Camera Error"),
                message: Text(error.localizedDescription),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func scanBus() {
        // Start scanning process
        isScanning = true
        
        // Capture a photo from the camera
        cameraManager.capturePhoto { image in
            guard let image = image else {
                isScanning = false
                return
            }
            
            // In a real app, this would use CoreML to detect the bus plate
            // For now, we'll simulate the process with a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isScanning = false
                
                // Randomly determine if the bus is correct for the route (for demo purposes)
                let isCorrectBus = Bool.random()
                
                if isCorrectBus {
                    let plateNumber = BusDataManager.shared.generateRandomPlateNumber()
                    let bus = Bus(
                        plateNumber: plateNumber,
                        routeName: "\(startPoint) - \(destination)",
                        routeCode: "GS",
                        busNumber: "8"
                    )
                    scanResult = .success(bus)
                } else {
                    scanResult = .failure
                }
                
                showResult = true
            }
        }
    }
}
