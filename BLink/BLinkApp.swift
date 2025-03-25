//
//  BLinkApp.swift
//  BLink
//
//  Created by reynaldo on 24/03/25.
//

import SwiftUI
import SwiftData

@main
struct BLinkApp: App {
    @State private var modelContainer: ModelContainer
    
    init() {
        do {
            let schema = Schema([Bus.self, BusStop.self, Route.self, UserJourney.self])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    BusDataManager.shared.populateSampleData(modelContext: modelContainer.mainContext)
                }
        }
        .modelContainer(modelContainer)
    }
}
