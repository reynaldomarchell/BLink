//
//  CameraScannerView.swift
//  BLink
//
//  Created by reynaldo on 25/03/25.
//

import SwiftUI
import AVFoundation
import Vision

struct CameraScannerView: View {
    @Binding var showTutorial: Bool
    @Binding var showRouteFinder: Bool
    var onRouteSelected: (String, String) -> Void
    
    @StateObject private var cameraManager = CameraManager()
    @State private var isScanning = false
    @State private var showBusSchedule = false
    @State private var detectedBus: Bus? = nil
    
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
                    }
                    .padding(.top, 60)
                    .padding(.trailing, 20)
                }
                Spacer()
            }
            
            // Bottom area with shutter button and search button
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
                    // Camera shutter and search buttons
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
                        
                        // Search button
                        Button(action: {
                            showRouteFinder = true
                        }) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                Text("Search Bus Route")
                            }
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(20)
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
        .sheet(isPresented: $showBusSchedule) {
            if let bus = detectedBus {
                BusScheduleView(bus: bus, isPresented: $showBusSchedule)
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
                
                // Simulate finding a bus
                let plateNumber = BusDataManager.shared.generateRandomPlateNumber()
                detectedBus = Bus(
                    plateNumber: plateNumber,
                    routeName: "Greenwich - Sektor 1.3 Loop Line",
                    routeCode: "GS",
                    busNumber: "8"
                )
                
                showBusSchedule = true
            }
        }
    }
}
