//
//  BudgetModel.swift
//  Spendly
//
//  Created by Shahudaa on 04/10/2026.
//


import Foundation
import SwiftData

@Model
final class BudgetModel {
    @Attribute(.unique) var id: UUID
    var amount: Double
    var period: BudgetPeriod

    var category: CategoryModel?

    init(
        id: UUID = UUID(),
        amount: Double,
        period: BudgetPeriod,
        category: CategoryModel? = nil
    ) {
        self.id = id
        self.amount = amount
        self.period = period
        self.category = category
    }
}