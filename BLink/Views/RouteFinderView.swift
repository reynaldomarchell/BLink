//
//  RouteFinderView.swift
//  BLink
//
//  Created by reynaldo on 27/03/25.
//

import SwiftUI
import SwiftData

struct RouteFinderView: View {
   @State private var destination = ""
   @State private var selectedRoute: BusRoute?
   @StateObject private var locationManager = LocationManager()
   @State private var customLocation = ""
   @State private var isLoading = false
   @Environment(\.modelContext) private var modelContext
   @Environment(\.dismiss) private var dismiss
   
   // Query all saved locations and bus routes
   @Query private var savedLocations: [SavedLocation]
   @Query private var busRoutes: [BusRoute]
   
   // Filtered routes based on destination search
   private var filteredRoutes: [BusRoute] {
       if destination.isEmpty && customLocation.isEmpty {
           return busRoutes
       } else {
           return busRoutes.filter { route in
               let matchesDestination = destination.isEmpty ||
                   route.routeName.localizedCaseInsensitiveContains(destination) ||
                   route.endPoint.localizedCaseInsensitiveContains(destination) ||
                   route.stations.contains { station in
                       station.name.localizedCaseInsensitiveContains(destination)
                   }
               
               let matchesLocation = customLocation.isEmpty ||
                   route.startPoint.localizedCaseInsensitiveContains(customLocation)
               
               return matchesDestination && matchesLocation
           }
       }
   }
   
   var body: some View {
       NavigationView {
           VStack(spacing: 0) {
               // Unified input section
               HStack(alignment: .top, spacing: 12) {
                   // Icon column
                   VStack(spacing: 6) {
                       Image(systemName: "figure.stand")
                           .resizable()
                           .scaledToFit()
                           .frame(width: 14, height: 14)
                           .foregroundColor(.white)
                           .padding(6)
                           .background(Color.gray)
                           .cornerRadius(4)

                       VStack(spacing: 2) {
                           ForEach(0..<4) { _ in
                               Rectangle()
                                   .fill(Color.black)
                                   .frame(width: 2, height: 2)
                           }
                       }

                       Image(systemName: "mappin.circle")
                           .resizable()
                           .scaledToFit()
                           .frame(width: 14, height: 14)
                           .foregroundColor(.white)
                           .padding(6)
                           .background(Color.orange)
                           .cornerRadius(4)
                   }

                   VStack(spacing: 12) {
                       // Top: Current location input
                       HStack {
                           VStack(alignment: .leading, spacing: 2) {
                               Text("Your Location")
                                   .font(.caption)
                                   .foregroundColor(.secondary)

                               TextField(locationManager.currentAddress.isEmpty ? "Current Location" : locationManager.currentAddress, text: $customLocation)
                                   .font(.subheadline)
                                   .foregroundColor(.primary)
                                   .onTapGesture {
                                       // Only show loading if we're using the actual location
                                       if customLocation.isEmpty && locationManager.currentAddress.isEmpty {
                                           isLoading = true
                                           // Simulate delay and then hide loading
                                           DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                               isLoading = false
                                           }
                                       }
                                   }
                           }

                           Spacer()

                           if isLoading {
                               ProgressView()
                                   .progressViewStyle(CircularProgressViewStyle())
                                   .padding(6)
                           } else {
                               Button(action: {
                                   // Swap location and destination
                                   let tempLocation = customLocation.isEmpty ?
                                       locationManager.currentAddress : customLocation
                                   customLocation = destination
                                   destination = tempLocation
                               }) {
                                   Image(systemName: "arrow.up.arrow.down")
                                       .foregroundColor(.red)
                                       .padding(6)
                                       .background(Circle().stroke(Color.yellow, lineWidth: 2))
                               }
                           }
                       }

                       Divider()

                       // Bottom: Destination input
                       TextField("Where you want to go?", text: $destination)
                           .font(.subheadline)
                           .onTapGesture {
                               // Show loading indicator when tapped
                               if destination.isEmpty {
                                   isLoading = true
                                   // Simulate delay and then hide loading
                                   DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                       isLoading = false
                                   }
                               }
                           }
                   }
               }
               .padding()
               .background(Color(.systemBackground))
               .cornerRadius(20)
               .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
               .padding(.horizontal)
               
               // Recommendations section
               VStack(alignment: .leading, spacing: 15) {
                   Text("Recommendations")
                       .font(.title2)
                       .fontWeight(.bold)
                       .padding(.horizontal)
                   
                   if filteredRoutes.isEmpty {
                       VStack(spacing: 20) {
                           Image(systemName: "magnifyingglass")
                               .font(.system(size: 40))
                               .foregroundColor(.gray)
                           
                           Text("No routes found")
                               .font(.headline)
                               .foregroundColor(.gray)
                           
                           Text("Try a different destination")
                               .font(.subheadline)
                               .foregroundColor(.gray)
                       }
                       .frame(maxWidth: .infinity)
                       .padding(.vertical, 50)
                   } else {
                       ScrollView {
                           VStack(spacing: 15) {
                               ForEach(filteredRoutes) { route in
                                   RouteRecommendationCard(
                                       from: route.startPoint,
                                       to: route.endPoint,
                                       routeCode: route.routeCode,
                                       routeDescription: "\(route.startPoint) → \(route.endPoint)",
                                       duration: route.estimatedTime,
                                       distance: route.distance,
                                       onTap: {
                                           selectedRoute = route
                                       }
                                   )
                                   .id(route.id) // Add explicit ID to ensure proper updates
                               }
                           }
                           .padding(.horizontal)
                       }
                   }
               }
               .padding(.top)
           }
           .navigationBarTitle("Route Finder", displayMode: .inline)
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
               // Pre-load location data
               if locationManager.currentAddress.isEmpty {
                   locationManager.requestLocation()
               }
           }
       }
       .navigationViewStyle(StackNavigationViewStyle())
       .fullScreenCover(isPresented: Binding(
           get: { selectedRoute != nil },
           set: { if !$0 { selectedRoute = nil } }
       )) {
           if let route = selectedRoute {
               RouteResultView(route: route)
           }
       }
   }
}

struct RouteRecommendationCard: View {
   let from: String
   let to: String
   let routeCode: String
   let routeDescription: String
   let duration: Int
   let distance: Double
   let onTap: () -> Void
   
   var body: some View {
       Button(action: onTap) {
           VStack(alignment: .leading, spacing: 10) {
               // Route title
               HStack {
                   Text(from)
                       .foregroundColor(.blue)
                   
                   Image(systemName: "arrow.right")
                       .foregroundColor(.secondary)
                   
                   Text(to)
                       .foregroundColor(.blue)
               }
               .font(.headline)
               
               // Route details
               HStack {
                   ZStack {
                       Capsule()
                           .fill(Color.green.opacity(0.2))
                           .frame(width: 36, height: 24)
                       
                       Text(routeCode)
                           .font(.caption)
                           .fontWeight(.bold)
                           .foregroundColor(.green)
                   }
                   
                   Text(routeDescription)
                       .font(.subheadline)
                       .foregroundColor(.secondary)
               }
               
               // Duration and distance
               HStack(spacing: 20) {
                   Label("\(duration) Minutes", systemImage: "clock")
                       .font(.subheadline)
                       .foregroundColor(.secondary)
                   
                   Label("\(String(format: "%.1f", distance)) Km", systemImage: "figure.walk")
                       .font(.subheadline)
                       .foregroundColor(.secondary)
               }
           }
           .padding()
           .frame(maxWidth: .infinity, alignment: .leading)
           .background(Color(.systemBackground))
           .cornerRadius(12)
           .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
       }
       .buttonStyle(PlainButtonStyle())
   }
}

#Preview {
   RouteFinderView()
}

