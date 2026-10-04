//
//  Item.swift
//  Spendly
//
//  Created by Shahudaa on 04/10/2026.
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
