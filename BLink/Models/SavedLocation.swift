//
//  SavedLocation.swift
//  BLink
//
//  Created by reynaldo on 27/03/25.
//

import Foundation
import SwiftData

@Model
final class SavedLocation {
    var id: UUID
    var name: String
    var address: String
    var isHome: Bool
    
    init(id: UUID = UUID(), name: String, address: String, isHome: Bool = false) {
        self.id = id
        self.name = name
        self.address = address
        self.isHome = isHome
    }
}

