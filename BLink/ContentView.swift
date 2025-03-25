//
//  ContentView.swift
//  BLink
//
//  Created by reynaldo on 25/03/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showTutorial = false
    @State private var showRouteFinder = false
    @State private var currentRoute: (startPoint: String, destination: String)? = nil
    
    var body: some View {
        NavigationStack {
            if let route = currentRoute {
                CameraRouteFinderView(
                    startPoint: route.startPoint,
                    destination: route.destination,
                    onDismiss: { self.currentRoute = nil }
                )
            } else {
                CameraScannerView(
                    showTutorial: $showTutorial,
                    showRouteFinder: $showRouteFinder,
                    onRouteSelected: { start, destination in
                        self.currentRoute = (start, destination)
                    }
                )
            }
        }
        .sheet(isPresented: $showTutorial) {
            TutorialView(isPresented: $showTutorial)
        }
        .sheet(isPresented: $showRouteFinder) {
            RouteFinderView(
                isPresented: $showRouteFinder,
                onRouteSelected: { start, destination in
                    self.currentRoute = (start, destination)
                }
            )
        }
    }
}

#Preview {
    ContentView()
}
