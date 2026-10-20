//
//  BudgetLocalDataSource.swift
//  Spendly
//
//  Created by Shahudaa on 20/10/2026.
//


import Foundation
import SwiftData

final class BudgetLocalDataSource {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchBudgets() throws -> [BudgetModel] {
        let descriptor = FetchDescriptor<BudgetModel>()

        return try modelContext.fetch(descriptor)
    }

    func fetchBudget(id: UUID) throws -> BudgetModel? {
        let descriptor = FetchDescriptor<BudgetModel>(
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

    func insert(_ model: BudgetModel) {
        modelContext.insert(model)
    }

    func delete(_ model: BudgetModel) {
        modelContext.delete(model)
    }

    func saveChanges() throws {
        try modelContext.save()
    }
}