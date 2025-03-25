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
            // Camera background
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Camera view placeholder
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .overlay(
                    Text("Camera")
                        .font(.largeTitle)
                        .foregroundColor(.white.opacity(0.7))
                )
            
            // Scanning overlay
            if isScanning {
                VStack {
                    Spacer()
                    HStack {
                        Image(systemName: "bus")
                        Text("Scanning the Bus...")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                    Spacer().frame(height: 100)
                }
            }
            
            // Route info at bottom
            VStack {
                Spacer()
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
                .padding(.bottom, 40)
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
                            Image(systemName: "viewfinder.circle.fill")
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
        }
        .onAppear {
            // Auto-scan when view appears
            scanBus()
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
    }
    
    private func scanBus() {
        // Simulate scanning process
        isScanning = true
        
        // In a real app, this would use Vision and CoreML to detect the bus plate
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
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
