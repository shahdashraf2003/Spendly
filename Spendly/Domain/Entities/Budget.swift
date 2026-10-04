//
//  Budget.swift
//  Spendly
//
//  Created by Shahudaa on 04/10/2026.
//


import Foundation

struct Budget {
    let id: UUID
    let amount: Decimal
    let period: BudgetPeriod
    let categoryID: UUID

    init(
        id: UUID = UUID(),
        amount: Decimal,
        period: BudgetPeriod,
        categoryID: UUID
    ) {
        self.id = id
        self.amount = amount
        self.period = period
        self.categoryID = categoryID
    }
}