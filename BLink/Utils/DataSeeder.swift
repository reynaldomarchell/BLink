//
//  DataSeeder.swift
//  BLink
//
//  Created by reynaldo on 27/03/25.
//

import Foundation
import SwiftData

class DataSeeder {
    static func seedInitialData(modelContext: ModelContext) {
        // Seed bus routes
        let busRoutes = [
            BusRoute(
                routeName: "Greenwich Park - Halte Sektor 1.3",
                startPoint: "Greenwich Park",
                endPoint: "Halte Sektor 1.3",
                stations: [
                    Station(name: "Greenwich Park", arrivalTime: nil, isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "CBD Barat", arrivalTime: nil, isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "CBD Timur", arrivalTime: nil, isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "Lobby AEON Mall", arrivalTime: nil, isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "Halte Sektor 1.3", arrivalTime: nil, isCurrentStation: false, isPreviousStation: false, isNextStation: false)
                ],
                routeCode: "GS",
                color: "green",
                estimatedTime: 65,
                distance: 6.9
            ),
            BusRoute(
                routeName: "The Breeze - Lobby AEON",
                startPoint: "The Breeze",
                endPoint: "Lobby AEON",
                stations: [
                    Station(name: "The Breeze", arrivalTime: nil, isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "AEON", arrivalTime: nil, isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "ICE Loop Line", arrivalTime: nil, isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "Lobby AEON", arrivalTime: nil, isCurrentStation: false, isPreviousStation: false, isNextStation: false)
                ],
                routeCode: "BC",
                color: "purple",
                estimatedTime: 65,
                distance: 6.9
            )
        ]
        
        // Seed saved locations
        let savedLocations = [
            SavedLocation(name: "Home", address: "Rumah Mantan | Jl. GOP Indah No 1", isHome: true),
            SavedLocation(name: "Office", address: "Gedung Apel | Jl. GOP Indah No 9", isHome: false)
        ]
        
        // Seed bus info
        let busInfos = [
            BusInfo(plateNumber: "B 7366 JE", routeCode: "GS", routeName: "Greenwich Park - Halte Sektor 1.3"),
            BusInfo(plateNumber: "В 7366 PAA", routeCode: "BC", routeName: "The Breeze - Lobby AEON"),
            BusInfo(plateNumber: "B 7566 PAA", routeCode: "GS", routeName: "Greenwich Park - Halte Sektor 1.3"),
            BusInfo(plateNumber: "B 7002 PGX", routeCode: "BC", routeName: "The Breeze - Lobby AEON")
        ]
        
        // Insert data into the model context
        for route in busRoutes {
            modelContext.insert(route)
        }
        
        for location in savedLocations {
            modelContext.insert(location)
        }
        
        for busInfo in busInfos {
            modelContext.insert(busInfo)
        }
    }
}

