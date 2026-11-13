//
//  BudgetRepositoryError.swift
//  Spendly
//
//  Created by Shahudaa on 20/10/2026.
//


import Foundation

enum BudgetRepositoryError: Error {
    case budgetNotFound
    case categoryNotFound
    case duplicateBudget
}

final class BudgetRepository: BudgetRepositoryInterface {
    private let localDataSource: BudgetLocalDataSource

    init(localDataSource: BudgetLocalDataSource) {
        self.localDataSource = localDataSource
    }

    func fetchBudgets() throws -> [Budget] {
        let models = try localDataSource.fetchBudgets()
        return models.compactMap { $0.toDomain() }
    }

    func fetchBudget(id: UUID) throws -> Budget? {
        guard let model = try localDataSource.fetchBudget(id: id) else {
            return nil
        }

        return model.toDomain()
    }

    func addBudget(_ budget: Budget) throws {
        let category = try resolveCategory(id: budget.categoryID)
        try validateUniqueBudget(budget)

        let model = BudgetModel(
            id: budget.id,
            amount: budget.amount,
            period: budget.period,
            category: category
        )

        localDataSource.insert(model)
        try localDataSource.saveChanges()
    }

    func updateBudget(_ budget: Budget) throws {
        guard let model = try localDataSource.fetchBudget(id: budget.id) else {
            throw BudgetRepositoryError.budgetNotFound
        }

        let category = try resolveCategory(id: budget.categoryID)
        try validateUniqueBudget(budget, excludingID: budget.id)

        model.amount = budget.amount
        model.period = budget.period
        model.category = category

        try localDataSource.saveChanges()
    }

    func deleteBudget(id: UUID) throws {
        guard let model = try localDataSource.fetchBudget(id: id) else {
            return
        }

        localDataSource.delete(model)
        try localDataSource.saveChanges()
    }

    private func resolveCategory(id: UUID) throws -> CategoryModel {
        guard let category = try localDataSource.fetchCategory(id: id) else {
            throw BudgetRepositoryError.categoryNotFound
        }

        return category
    }

    private func validateUniqueBudget(
        _ budget: Budget,
        excludingID: UUID? = nil
    ) throws {
        let existingBudgets = try localDataSource.fetchBudgets()

        let duplicateExists = existingBudgets.contains { model in
            guard
                model.category?.id == budget.categoryID,
                model.period == budget.period
            else {
                return false
            }

            if let excludingID, model.id == excludingID {
                return false
            }

            return true
        }

        if duplicateExists {
            throw BudgetRepositoryError.duplicateBudget
        }
    }
}
