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
        seedDefaultCategoriesIfNeeded()
    }

    func fetchCategories() throws -> [CategoryModel] {
        let descriptor = FetchDescriptor<CategoryModel>(
            sortBy: [SortDescriptor(\.name)]
        )

        var categories = try modelContext.fetch(descriptor)
        if categories.isEmpty {
            seedDefaultCategoriesIfNeeded()
            categories = try modelContext.fetch(descriptor)
        }

        return categories
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

    // MARK: - Seeding
    func seedDefaultCategoriesIfNeeded() {
        do {
            let descriptor = FetchDescriptor<CategoryModel>()
            let count = try modelContext.fetchCount(descriptor)
            if count == 0 {
                let defaultCategories: [(name: String, icon: String, type: CategoryType)] = [
                    ("category.food", "🍽️", .expense),
                    ("category.shopping", "🛍️", .expense),
                    ("category.transport", "🚗", .expense),
                    ("category.bills", "🧾", .expense),
                    ("category.entertainment", "🎬", .expense),
                    ("category.other", "📦", .expense),
                    ("category.income", "💰", .income)
                ]

                for item in defaultCategories {
                    let model = CategoryModel(
                        name: item.name,
                        icon: item.icon,
                        type: item.type
                    )
                    modelContext.insert(model)
                }

                try modelContext.save()
            }
        } catch {
            print("Failed to seed default categories: \(error)")
        }
    }
}