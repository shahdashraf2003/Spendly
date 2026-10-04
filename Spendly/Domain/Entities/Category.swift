//
//  Category.swift
//  Spendly
//
//  Created by Shahudaa on 04/10/2026.
//


import Foundation

struct Category {
    let id: UUID
    let name: String
    let icon: String
    let type: CategoryType

    init(
        id: UUID = UUID(),
        name: String,
        icon: String,
        type: CategoryType
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.type = type
    }
}