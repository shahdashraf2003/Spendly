//
//  UpdateCategoryUseCase.swift
//  Spendly
//
//  Created by Shahudaa on 21/10/2026.
//


import Foundation

final class UpdateCategoryUseCase {
	private let repository: CategoryRepositoryInterface

	init(repository: CategoryRepositoryInterface) {
        self.repository = repository
    }

    func execute(_ category: Category) throws {
        guard !category.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw CategoryValidationError.invalidName
        }

        try repository.updateCategory(category)
    }
}
