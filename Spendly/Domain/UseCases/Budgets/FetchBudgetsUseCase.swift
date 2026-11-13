//
//  FetchBudgetsUseCase.swift
//  Spendly
//
//  Created by Shahudaa on 21/10/2026.
//


import Foundation

final class FetchBudgetsUseCase {
	private let repository: BudgetRepositoryInterface

	init(repository: BudgetRepositoryInterface) {
        self.repository = repository
    }

    func execute() throws -> [Budget] {
        try repository.fetchBudgets()
    }
}
