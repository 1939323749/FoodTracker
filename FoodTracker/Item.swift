//
//  Item.swift
//  FoodTracker
//
//  Created by mba on 2023/10/15.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
