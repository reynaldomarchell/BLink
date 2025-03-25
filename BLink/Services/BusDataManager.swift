//
//  BusDataManager.swift
//  BLink
//
//  Created by reynaldo on 25/03/25.
//

import Foundation
import SwiftData

class BusDataManager {
    static let shared = BusDataManager()
    
    // Generate random Jakarta plate number
    func generateRandomPlateNumber() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let plateLetters = String((0..<3).map { _ in letters.randomElement()! })
        let plateNumbers = Int.random(in: 1000...9999)
        return "B \(plateNumbers) \(plateLetters)"
    }
    
    // Sample data for the app
    func populateSampleData(modelContext: ModelContext) {
        // Check if data already exists
        let descriptor = FetchDescriptor<Bus>()
        guard (try? modelContext.fetch(descriptor))?.isEmpty ?? true else {
            return
        }
        
        // Create routes
        let routes = [
            Route(name: "Terminal Intermoda - De Park - Terminal Intermoda",
                  startPoint: "Terminal Intermoda",
                  destination: "Terminal Intermoda"),
            Route(name: "The Breeze - Aeon Mall - ICE - Aeon Mall - The Breeze",
                  startPoint: "The Breeze",
                  destination: "The Breeze"),
            Route(name: "Greenwich Park - Halte Sektor 1.3",
                  startPoint: "Greenwich Park",
                  destination: "Halte Sektor 1.3"),
            Route(name: "Intermoda - ICE - QBIG - Ara Rasa - The Breeze",
                  startPoint: "Intermoda",
                  destination: "The Breeze")
        ]
        
        // Create buses with random plate numbers
        let busNumbers = ["7", "8", "5", "6", "9", "10", "11"]
        
        for route in routes {
            for _ in 1...5 {
                let busNumber = busNumbers.randomElement() ?? "7"
                let bus = Bus(
                    plateNumber: generateRandomPlateNumber(),
                    routeName: route.name,
                    routeCode: route.name.prefix(3).uppercased(),
                    busNumber: busNumber
                )
                route.buses.append(bus)
                modelContext.insert(bus)
            }
            modelContext.insert(route)
        }
    }
}
