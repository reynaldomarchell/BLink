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
    @State private var showRouteResult = false
    @StateObject private var locationManager = LocationManager()
    @State private var currentLocation: String = ""
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var savedLocations: [SavedLocation]
    
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
                        // Top: Current location (disabled input)
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Your Location")
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                TextField("Where are you now?", text: $locationManager.currentAddress)
                                    .font(.subheadline)
                                    .foregroundColor(currentLocation.isEmpty ? .gray : .primary)
                            }

                            Spacer()

                            Button(action: {
                                // Swap action
                            }) {
                                Image(systemName: "arrow.up.arrow.down")
                                    .foregroundColor(.red)
                                    .padding(6)
                                    .background(Circle().stroke(Color.yellow, lineWidth: 2))
                            }
                        }

                        Divider()

                        // Bottom: Destination input
                        TextField("Where you want to go?", text: $destination)
                            .font(.subheadline)
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
                    
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(0..<4) { _ in
                                RouteRecommendationCard(
                                    from: "Greenwich Park",
                                    to: "Halte Sektor 1.3",
                                    routeCode: "GS",
                                    routeDescription: "Greenwich Park → Sektor 1.3",
                                    duration: 65,
                                    distance: 6.9,
                                    onTap: {
                                        showRouteResult = true
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
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
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $showRouteResult) {
            RouteResultView()
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

