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
    
    @State private var isScanning = false
    @State private var showBusSchedule = false
    @State private var detectedBus: Bus? = nil
    
    var body: some View {
        ZStack {
            // Camera background
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Camera view placeholder (in a real app, this would be a camera feed)
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .overlay(
                    Text("Camera")
                        .font(.largeTitle)
                        .foregroundColor(.white.opacity(0.7))
                )
            
            // Bottom button area
            VStack {
                Spacer()
                
                // Show either the scanning indicator or the search button
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
                    .padding(.bottom, 40)
                } else {
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
                    .padding(.bottom, 40)
                }
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
                            scanBus()
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
        .sheet(isPresented: $showBusSchedule) {
            if let bus = detectedBus {
                BusScheduleView(bus: bus, isPresented: $showBusSchedule)
            }
        }
    }
    
    private func scanBus() {
        // Simulate scanning process
        isScanning = true
        
        // In a real app, this would use Vision and CoreML to detect the bus plate
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
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
