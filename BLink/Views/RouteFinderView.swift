//
//  RouteFinderView.swift
//  BLink
//
//  Created by reynaldo on 25/03/25.
//

import SwiftUI
import SwiftData

struct RouteFinderView: View {
    @Binding var isPresented: Bool
    var initialStartPoint: String = ""
    var initialDestination: String = ""
    var onRouteSelected: (String, String) -> Void
    
    @State private var startPoint: String
    @State private var destination: String
    @State private var suggestions: [Route] = []
    
    @Environment(\.modelContext) private var modelContext
    @Query private var routes: [Route]
    
    init(isPresented: Binding<Bool>, initialStartPoint: String = "", initialDestination: String = "", onRouteSelected: @escaping (String, String) -> Void) {
        self._isPresented = isPresented
        self.initialStartPoint = initialStartPoint
        self.initialDestination = initialDestination
        self.onRouteSelected = onRouteSelected
        self._startPoint = State(initialValue: initialStartPoint)
        self._destination = State(initialValue: initialDestination)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search fields
                VStack(spacing: 15) {
                    TextField("Starting Point", text: $startPoint)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .onChange(of: startPoint) { _, _ in
                            updateSuggestions()
                        }
                    
                    TextField("Destination", text: $destination)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .onChange(of: destination) { _, _ in
                            updateSuggestions()
                        }
                    
                    Button(action: {
                        submitRoute()
                    }) {
                        Text("Scan Bus")
                            .fontWeight(.medium)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                }
                .padding()
                
                // Suggestions list
                List {
                    Section(header: Text("Suggestions")) {
                        ForEach(suggestions) { route in
                            Button(action: {
                                startPoint = route.startPoint
                                destination = route.destination
                                submitRoute()
                            }) {
                                VStack(alignment: .leading) {
                                    Text("\(route.startPoint) → \(route.destination)")
                                        .fontWeight(.medium)
                                    Text(route.name)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Route Finder")
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
        }
        .onAppear {
            updateSuggestions()
        }
    }
    
    private func updateSuggestions() {
        // Filter suggestions based on input
        if startPoint.isEmpty && destination.isEmpty {
            // Show all routes if no input
            suggestions = Array(routes.prefix(5))
        } else {
            // Filter based on input
            suggestions = routes.filter { route in
                let matchesStart = startPoint.isEmpty ||
                    route.startPoint.localizedCaseInsensitiveContains(startPoint)
                let matchesDest = destination.isEmpty ||
                    route.destination.localizedCaseInsensitiveContains(destination)
                return matchesStart && matchesDest
            }
        }
    }
    
    private func submitRoute() {
        guard !startPoint.isEmpty && !destination.isEmpty else { return }
        
        // Save the journey
        let journey = UserJourney(startPoint: startPoint, destination: destination)
        modelContext.insert(journey)
        
        // Close sheet and pass back the selected route
        onRouteSelected(startPoint, destination)
        isPresented = false
    }
}
