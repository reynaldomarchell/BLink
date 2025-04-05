//
//  RouteResultView.swift
//  BLink
//
//  Created by reynaldo on 27/03/25.
//

import SwiftUI
import MapKit

struct RouteResultView: View {
   let route: BusRoute
   
   @Environment(\.dismiss) private var dismiss
   @State private var showAlert = false
   @StateObject private var locationManager = LocationManager()
   @State private var isMapLoaded = false
   
   // Start station coordinates (simulated for now - in a real app, you'd get this from the route)
   private let startStationCoordinates = CLLocationCoordinate2D(latitude: -6.298, longitude: 106.648)
   
   // Map camera position
   @State private var position: MapCameraPosition = .automatic
   
   // Simulated coordinates for all stations
   private var stationCoordinates: [CLLocationCoordinate2D] {
       // Create simulated coordinates for each station in the route
       let baseLatitude = -6.298
       let baseLongitude = 106.648
       
       return route.stations.enumerated().map { index, station in
           // Create a path that moves generally eastward with some variation
           let latOffset = Double.random(in: -0.003...0.003)
           let longOffset = 0.004 * Double(index) // Move eastward
           
           return CLLocationCoordinate2D(
               latitude: baseLatitude + latOffset,
               longitude: baseLongitude + longOffset
           )
       }
   }
   
   // Route polyline points connecting all stations
   private var routePolyline: [CLLocationCoordinate2D] {
       return stationCoordinates
   }
   
   var body: some View {
       NavigationView {
           ScrollView {
               VStack(spacing: 12) {
                   // Location and destination display
                   VStack(spacing: 8) {
                       // Origin location
                       HStack(spacing: 12) {
                           VStack(spacing: 0) {
                               Circle()
                                   .fill(Color.green)
                                   .frame(width: 10, height: 10)
                               
                               Rectangle()
                                   .fill(Color.gray.opacity(0.5))
                                   .frame(width: 2, height: 24)
                           }
                           
                           VStack(alignment: .leading, spacing: 2) {
                               Text("Your Location")
                                   .font(.caption)
                                   .foregroundColor(.secondary)
                               
                               Text(locationManager.currentAddress.isEmpty ? "Current Location" : locationManager.currentAddress)
                                   .font(.subheadline)
                           }
                           
                           Spacer()
                       }
                       
                       // Destination
                       HStack(spacing: 12) {
                           Circle()
                               .fill(Color.orange)
                               .frame(width: 10, height: 10)
                           
                           VStack(alignment: .leading, spacing: 2) {
                               Text("Your Destination")
                                   .font(.caption)
                                   .foregroundColor(.secondary)
                               
                               Text(route.endPoint)
                                   .font(.subheadline)
                           }
                           
                           Spacer()
                       }
                   }
                   .padding(.horizontal, 16)
                   .padding(.vertical, 12)
                   .background(Color(.systemBackground))
                   .cornerRadius(12)
                   .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                   .padding(.horizontal, 16)
                   .padding(.top, 8)
                   
                   // Route Details section
                   VStack(alignment: .leading, spacing: 12) {
                       Text("Route Details")
                           .font(.title3)
                           .fontWeight(.bold)
                           .padding(.horizontal, 16)
                           .padding(.top, 4)
                       
                       // Route recommendation
                       CompactRouteCard(
                           from: route.startPoint,
                           to: route.endPoint,
                           routeCode: route.routeCode,
                           duration: route.estimatedTime,
                           distance: route.distance
                       )
                       .padding(.horizontal, 16)
                       
                       // Stations list
                       VStack(alignment: .leading, spacing: 4) {
                           Text("Stations")
                               .font(.headline)
                               .padding(.horizontal, 16)
                               .padding(.top, 4)
                           
                           ScrollView(.horizontal, showsIndicators: false) {
                               HStack(spacing: 12) {
                                   ForEach(route.stations, id: \.name) { station in
                                       StationCard(station: station)
                                   }
                               }
                               .padding(.horizontal, 16)
                               .padding(.vertical, 4)
                           }
                       }
                       
                       // Map view showing the entire route
                       VStack(alignment: .leading, spacing: 8) {
                           Text("Route Map")
                               .font(.headline)
                               .padding(.horizontal, 16)
                               .padding(.top, 4)
                           
                           ZStack(alignment: .bottom) {
                               if !isMapLoaded {
                                   Rectangle()
                                       .fill(Color.gray.opacity(0.2))
                                       .frame(height: 250)
                                       .cornerRadius(12)
                                       .padding(.horizontal, 16)
                                       .overlay(
                                           ProgressView()
                                               .progressViewStyle(CircularProgressViewStyle())
                                       )
                               }
                               
                               Map(position: $position) {
                                   // Add markers for all stations
                                   ForEach(Array(zip(route.stations, stationCoordinates)), id: \.0.name) { station, coordinate in
                                       Marker(station.name, coordinate: coordinate)
                                           .tint(getStationColor(station))
                                   }
                                   
                                   // Path connecting all stations
                                   MapPolyline(coordinates: routePolyline)
                                       .stroke(Color(UIColor(red: 0/255, green: 74/255, blue: 173/255, alpha: 1.0)), lineWidth: 4)
                               }
                               .mapStyle(.standard)
                               .frame(height: 250)
                               .cornerRadius(12)
                               .padding(.horizontal, 16)
                               .onAppear {
                                   // Calculate the center and span to show all stations
                                   let region = regionForCoordinates(stationCoordinates)
                                   position = .region(region)
                                   
                                   // Mark map as loaded after a short delay
                                   DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                       isMapLoaded = true
                                   }
                               }
                               
                               Button(action: {
                                   openMapsDirections()
                               }) {
                                   Text("Go to Start Station")
                                       .font(.headline)
                                       .foregroundColor(.white)
                                       .frame(maxWidth: .infinity)
                                       .frame(height: 44)
                                       .background(Color.blue)
                                       .cornerRadius(10)
                                       .padding(.horizontal, 32)
                                       .padding(.bottom, 16)
                               }
                           }
                       }
                   }
               }
               .padding(.bottom, 16)
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
           .onAppear {
               // Request location when view appears
               if locationManager.currentAddress.isEmpty {
                   locationManager.requestLocation()
               }
           }
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
   
   // Helper function to calculate region that shows all coordinates
   private func regionForCoordinates(_ coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
       guard !coordinates.isEmpty else {
           return MKCoordinateRegion(
               center: CLLocationCoordinate2D(latitude: -6.298, longitude: 106.648),
               span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
           )
       }
       
       var minLat = coordinates[0].latitude
       var maxLat = coordinates[0].latitude
       var minLon = coordinates[0].longitude
       var maxLon = coordinates[0].longitude
       
       for coordinate in coordinates {
           minLat = min(minLat, coordinate.latitude)
           maxLat = max(maxLat, coordinate.latitude)
           minLon = min(minLon, coordinate.longitude)
           maxLon = max(maxLon, coordinate.longitude)
       }
       
       let center = CLLocationCoordinate2D(
           latitude: (minLat + maxLat) / 2,
           longitude: (minLon + maxLon) / 2
       )
       
       // Add some padding
       let latDelta = (maxLat - minLat) * 1.3
       let lonDelta = (maxLon - minLon) * 1.3
       
       return MKCoordinateRegion(
           center: center,
           span: MKCoordinateSpan(latitudeDelta: max(0.01, latDelta), longitudeDelta: max(0.01, lonDelta))
       )
   }
   
   // Helper function to get color for station marker
   private func getStationColor(_ station: Station) -> Color {
       if station.name == route.startPoint {
           return .green
       } else if station.name == route.endPoint {
           return .red
       } else if station.isCurrentStation {
           return .blue
       } else if station.isNextStation {
           return .orange
       } else {
           return .purple
       }
   }
   
   private func openMapsDirections() {
       // Still directing to the start station
       let placemark = MKPlacemark(coordinate: startStationCoordinates)
       let mapItem = MKMapItem(placemark: placemark)
       mapItem.name = route.startPoint
       
       let launchOptions = [
           MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
       ]
       
       if !mapItem.openInMaps(launchOptions: launchOptions) {
           showAlert = true
       }
   }
}

// More compact route card for smaller screens
struct CompactRouteCard: View {
   let from: String
   let to: String
   let routeCode: String
   let duration: Int
   let distance: Double
   
   var body: some View {
       VStack(alignment: .leading, spacing: 8) {
           // Route title
           HStack {
               Text(from)
                   .foregroundColor(.blue)
               
               Image(systemName: "arrow.right")
                   .foregroundColor(.secondary)
                   .font(.caption)
               
               Text(to)
                   .foregroundColor(.blue)
           }
           .font(.subheadline)
           
           // Route details
           HStack {
               ZStack {
                   Capsule()
                       .fill(Color.green.opacity(0.2))
                       .frame(width: 32, height: 22)
                   
                   Text(routeCode)
                       .font(.caption2)
                       .fontWeight(.bold)
                       .foregroundColor(.green)
               }
               
               Text("\(from) → \(to)")
                   .font(.caption)
                   .foregroundColor(.secondary)
                   .lineLimit(1)
           }
           
           // Duration and distance
           HStack(spacing: 16) {
               Label("\(duration) Minutes", systemImage: "clock")
                   .font(.caption)
                   .foregroundColor(.secondary)
               
               Label("\(String(format: "%.1f", distance)) Km", systemImage: "figure.walk")
                   .font(.caption)
                   .foregroundColor(.secondary)
           }
       }
       .padding(12)
       .frame(maxWidth: .infinity, alignment: .leading)
       .background(Color(.systemBackground))
       .cornerRadius(12)
       .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
   }
}

struct StationCard: View {
   let station: Station
   
   var body: some View {
       VStack(alignment: .center, spacing: 6) {
           Circle()
               .fill(stationColor)
               .frame(width: 10, height: 10)
           
           Text(station.name)
               .font(.caption2)
               .multilineTextAlignment(.center)
               .lineLimit(2)
               .frame(width: 80, height: 30)
       }
       .frame(width: 96, height: 60)
       .padding(.vertical, 6)
       .padding(.horizontal, 8)
       .background(Color(.systemBackground))
       .cornerRadius(8)
       .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
   }
   
   private var stationColor: Color {
       if station.isPreviousStation {
           return .blue.opacity(0.5)
       } else if station.isCurrentStation {
           return .green
       } else if station.isNextStation {
           return .orange
       } else {
           return .gray
       }
   }
}

#Preview {
   // Create a sample route for preview
   let stations = [
       Station(name: "Greenwich Park", arrivalTime: nil, isCurrentStation: false, isPreviousStation: false, isNextStation: false),
       Station(name: "CBD Barat", arrivalTime: nil, isCurrentStation: true, isPreviousStation: false, isNextStation: false),
       Station(name: "CBD Timur", arrivalTime: nil, isCurrentStation: false, isPreviousStation: false, isNextStation: true),
       Station(name: "Lobby AEON Mall", arrivalTime: nil, isCurrentStation: false, isPreviousStation: false, isNextStation: false)
   ]
   
   let sampleRoute = BusRoute(
       routeName: "Greenwich Park - Halte Sektor 1.3",
       startPoint: "Greenwich Park",
       endPoint: "Halte Sektor 1.3",
       stations: stations,
       routeCode: "GS",
       color: "green",
       estimatedTime: 65,
       distance: 6.9
   )
   
   return RouteResultView(route: sampleRoute)
}

