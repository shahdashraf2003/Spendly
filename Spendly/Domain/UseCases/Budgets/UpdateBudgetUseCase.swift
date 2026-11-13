//
//  UpdateBudgetUseCase.swift
//  Spendly
//
//  Created by Shahudaa on 21/10/2026.
//


import Foundation

final class UpdateBudgetUseCase {
	private let repository: BudgetRepositoryInterface

	init(repository: BudgetRepositoryInterface) {
        self.repository = repository
    }

    func execute(_ budget: Budget) throws {
        guard budget.amount > 0 else {
            throw BudgetValidationError.invalidAmount
        }

        try repository.updateBudget(budget)
    }
}
