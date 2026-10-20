//
//  CategoryLocalDataSource.swift
//  Spendly
//
//  Created by Shahudaa on 20/10/2026.
//


import Foundation
import SwiftData

final class CategoryLocalDataSource {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchCategories() throws -> [CategoryModel] {
        let descriptor = FetchDescriptor<CategoryModel>(
            sortBy: [SortDescriptor(\.name)]
        )

        return try modelContext.fetch(descriptor)
    }

    func fetchCategory(id: UUID) throws -> CategoryModel? {
        let descriptor = FetchDescriptor<CategoryModel>(
            predicate: #Predicate { $0.id == id }
        )

        return try modelContext.fetch(descriptor).first
    }

    func insert(_ model: CategoryModel) {
        modelContext.insert(model)
    }

    func delete(_ model: CategoryModel) {
        modelContext.delete(model)
    }

    func saveChanges() throws {
        try modelContext.save()
    }
}