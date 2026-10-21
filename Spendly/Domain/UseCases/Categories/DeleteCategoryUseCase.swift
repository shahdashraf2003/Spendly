//
//  DeleteCategoryUseCase.swift
//  Spendly
//
//  Created by Shahudaa on 21/10/2026.
//


import Foundation

final class DeleteCategoryUseCase {
	private let repository: CategoryRepositoryInterface

	init(repository: CategoryRepositoryInterface) {
        self.repository = repository
    }

    func execute(id: UUID) throws {
        try repository.deleteCategory(id: id)
    }
}
