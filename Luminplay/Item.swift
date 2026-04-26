//
//  Item.swift
//  Luminplay
//
//  Created by rayanceking on 2026/4/26.
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
