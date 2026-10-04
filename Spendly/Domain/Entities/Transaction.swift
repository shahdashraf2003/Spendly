//
//  Transaction.swift
//  Spendly
//
//  Created by Shahudaa on 04/10/2026.
//


import Foundation

struct Transaction {
    let id: UUID
    let amount: Decimal
    let type: TransactionType
    let date: Date
    let note: String?
    let categoryID: UUID?

    init(
        id: UUID = UUID(),
        amount: Decimal,
        type: TransactionType,
        date: Date = Date(),
        note: String? = nil,
        categoryID: UUID? = nil
    ) {
        self.id = id
        self.amount = amount
        self.type = type
        self.date = date
        self.note = note
        self.categoryID = categoryID
    }
}