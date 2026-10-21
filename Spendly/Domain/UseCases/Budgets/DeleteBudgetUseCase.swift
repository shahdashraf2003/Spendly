//
//  DeleteBudgetUseCase.swift
//  Spendly
//
//  Created by Shahudaa on 21/10/2026.
//


import Foundation

final class DeleteBudgetUseCase {
	private let repository: BudgetRepositoryInterface

	init(repository: BudgetRepositoryInterface) {
        self.repository = repository
    }

    func execute(id: UUID) throws {
        try repository.deleteBudget(id: id)
    }
}
