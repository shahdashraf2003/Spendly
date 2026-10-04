//
//  TransactionModel.swift
//  Spendly
//
//  Created by Shahudaa on 04/10/2026.
//


import Foundation
import SwiftData


@Model
final class TransactionModel {
    @Attribute(.unique) var id: UUID
    var amount: Double
    var type: TransactionType
    var date: Date
    var note: String?

    var category: CategoryModel?

    init(
        id: UUID = UUID(),
        amount: Double,
        type: TransactionType,
        date: Date = Date(),
        note: String? = nil,
        category: CategoryModel? = nil
    ) {
        self.id = id
        self.amount = amount
        self.type = type
        self.date = date
        self.note = note
        self.category = category
    }
}