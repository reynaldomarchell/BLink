//
//  RouteResultView.swift
//  BLink
//
//  Created by reynaldo on 27/03/25.
//

import SwiftUI
import MapKit

struct RouteResultView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -6.301, longitude: 106.652),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var showAlert = false
    
    // Origin and destination locations
    private let originLocation = "Rumah Mantan | Jl. GOP Indah No 1"
    private let destinationLocation = "Gedung Apel | Jl. GOP Indah No 9"
    
    // Bus stop coordinates (simulated)
    private let busStopCoordinates = CLLocationCoordinate2D(latitude: -6.301, longitude: 106.652)
    private let busStopName = "Halte Sektor 1.3"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Location and destination display
                VStack(spacing: 15) {
                    // Origin location
                    HStack(spacing: 15) {
                        VStack(spacing: 0) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 12, height: 12)
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.5))
                                .frame(width: 2, height: 30)
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Your Location")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(originLocation)
                                .font(.subheadline)
                        }
                        
                        Spacer()
                    }
                    
                    // Destination
                    HStack(spacing: 15) {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 12, height: 12)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Your Destination")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(destinationLocation)
                                .font(.subheadline)
                        }
                        
                        Spacer()
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding()
                
                // Recommendations section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Recommendations")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    // Route recommendation
                    RouteRecommendationCard(
                        from: "Greenwich Park",
                        to: "Halte Sektor 1.3",
                        routeCode: "GS",
                        routeDescription: "Greenwich Park → Sektor 1.3",
                        duration: 65,
                        distance: 6.9,
                        onTap: {}
                    )
                    .padding(.horizontal)
                    
                    // Map view
                    ZStack(alignment: .bottom) {
                        Map(coordinateRegion: $region, annotationItems: [BusStopLocation(coordinate: busStopCoordinates)]) { location in
                            MapMarker(coordinate: location.coordinate, tint: .red)
                        }
                        .frame(height: 300)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        VStack {
                            Button(action: {
                                openMapsDirections()
                            }) {
                                Text("Go to Bus Stop")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(width: 200, height: 50)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            .padding(.bottom, 20)
                        }
                    }
                }
                .padding(.top)
            }
            .navigationBarTitle("Route Result", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                dismiss()
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .foregroundColor(.blue)
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Could Not Open Maps"),
                message: Text("There was a problem opening Maps to get directions to the bus stop."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func openMapsDirections() {
        let placemark = MKPlacemark(coordinate: busStopCoordinates)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = busStopName
        
        let launchOptions = [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
        ]
        
        if !mapItem.openInMaps(launchOptions: launchOptions) {
            showAlert = true
        }
    }
}

// Model for map annotation
struct BusStopLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

#Preview {
    RouteResultView()
}

