//
//  CategoryModel.swift
//  Spendly
//
//  Created by Shahudaa on 04/10/2026.
//

import Foundation
import SwiftData

@Model
final class CategoryModel {
    @Attribute(.unique) var id: UUID
    var name: String
    var icon: String
    var type: CategoryType

    @Relationship(
        deleteRule: .nullify,
        inverse: \TransactionModel.category
    )
    var transactions: [TransactionModel] = []

    @Relationship(
        deleteRule: .cascade,
        inverse: \BudgetModel.category
    )
    var budgets: [BudgetModel] = []

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
