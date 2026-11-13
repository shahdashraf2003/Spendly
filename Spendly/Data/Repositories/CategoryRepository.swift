//
//  CategoryRepositoryError.swift
//  Spendly
//
//  Created by Shahudaa on 20/10/2026.
//


import Foundation

enum CategoryRepositoryError: Error {
    case categoryNotFound
}

final class CategoryRepository: CategoryRepositoryInterface {
    private let localDataSource: CategoryLocalDataSource

    init(localDataSource: CategoryLocalDataSource) {
        self.localDataSource = localDataSource
    }

    func fetchCategories() throws -> [Category] {
        let models = try localDataSource.fetchCategories()
        return models.map { $0.toDomain() }
    }

    func fetchCategory(id: UUID) throws -> Category? {
        guard let model = try localDataSource.fetchCategory(id: id) else {
            return nil
        }

        return model.toDomain()
    }

    func addCategory(_ category: Category) throws {
        let model = CategoryModel(
            id: category.id,
            name: category.name,
            icon: category.icon,
            type: category.type
        )

        localDataSource.insert(model)
        try localDataSource.saveChanges()
    }

    func updateCategory(_ category: Category) throws {
        guard let model = try localDataSource.fetchCategory(id: category.id) else {
            throw CategoryRepositoryError.categoryNotFound
        }

        model.name = category.name
        model.icon = category.icon
        model.type = category.type

        try localDataSource.saveChanges()
    }

    func deleteCategory(id: UUID) throws {
        guard let model = try localDataSource.fetchCategory(id: id) else {
            return
        }

        localDataSource.delete(model)
        try localDataSource.saveChanges()
    }
}
