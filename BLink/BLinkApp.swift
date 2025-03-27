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
    var body: some Scene {
        WindowGroup {
            SplashView()
        }
        .modelContainer(for: [BusRoute.self, SavedLocation.self, BusInfo.self])
    }
}


