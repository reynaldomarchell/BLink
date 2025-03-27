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
    @Environment(\.modelContext) private var modelContext
    @Query private var savedLocations: [SavedLocation]
    
    // Simulated user's current location
    private let currentLocation = "Rumah Mantan | Jl. GOP Indah No 1"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Location and destination inputs
                VStack(spacing: 15) {
                    // Current location
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
                            
                            Text(currentLocation)
                                .font(.subheadline)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            // Refresh location
                        }) {
                            Image(systemName: "arrow.clockwise.circle")
                                .foregroundColor(.yellow)
                        }
                    }
                    
                    // Destination input
                    HStack(spacing: 15) {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 12, height: 12)
                        
                        TextField("Where you want to go?", text: $destination)
                            .font(.subheadline)
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
                // Go back
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .foregroundColor(.blue)
            })
            .fullScreenCover(isPresented: $showRouteResult) {
                RouteResultView()
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

