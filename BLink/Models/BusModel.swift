//
//  BusModel.swift
//  BLink
//
//  Created by reynaldo on 25/03/25.
//

import Foundation
import SwiftData

// MARK: - Bus Model
@Model
class Bus {
    var plateNumber: String
    var routeName: String
    var routeCode: String
    var busNumber: String
    var schedule: [BusStop]
    
    init(plateNumber: String, routeName: String, routeCode: String, busNumber: String, schedule: [BusStop] = []) {
        self.plateNumber = plateNumber
        self.routeName = routeName
        self.routeCode = routeCode
        self.busNumber = busNumber
        self.schedule = schedule
    }
}

// MARK: - Bus Stop Model
@Model
class BusStop {
    var name: String
    var arrivalTime: Date
    
    init(name: String, arrivalTime: Date) {
        self.name = name
        self.arrivalTime = arrivalTime
    }
}

// MARK: - Route Model
@Model
class Route {
    var id: UUID
    var name: String
    var startPoint: String
    var destination: String
    var buses: [Bus]
    
    init(id: UUID = UUID(), name: String, startPoint: String, destination: String, buses: [Bus] = []) {
        self.id = id
        self.name = name
        self.startPoint = startPoint
        self.destination = destination
        self.buses = buses
    }
}

// MARK: - User Journey Model
@Model
class UserJourney {
    var id: UUID
    var startPoint: String
    var destination: String
    var date: Date
    
    init(id: UUID = UUID(), startPoint: String, destination: String, date: Date = Date()) {
        self.id = id
        self.startPoint = startPoint
        self.destination = destination
        self.date = date
    }
}
