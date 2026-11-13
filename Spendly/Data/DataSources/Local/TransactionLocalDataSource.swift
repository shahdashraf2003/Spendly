//
//  TransactionLocalDataSource.swift
//  Spendly
//
//  Created by Shahudaa on 20/10/2026.
//


import Foundation
import SwiftData

final class TransactionLocalDataSource {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchTransactions() throws -> [TransactionModel] {
        let descriptor = FetchDescriptor<TransactionModel>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        return try modelContext.fetch(descriptor)
    }

    func fetchTransaction(id: UUID) throws -> TransactionModel? {
        let descriptor = FetchDescriptor<TransactionModel>(
            predicate: #Predicate { $0.id == id }
        )

        return try modelContext.fetch(descriptor).first
    }

    func fetchCategory(id: UUID) throws -> CategoryModel? {
        let descriptor = FetchDescriptor<CategoryModel>(
            predicate: #Predicate { $0.id == id }
        )

        return try modelContext.fetch(descriptor).first
    }

    func insert(_ model: TransactionModel) {
        modelContext.insert(model)
    }

    func delete(_ model: TransactionModel) {
        modelContext.delete(model)
    }

    func saveChanges() throws {
        try modelContext.save()
    }
}