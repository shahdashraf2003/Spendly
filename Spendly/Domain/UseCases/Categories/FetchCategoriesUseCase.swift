//
//  FetchCategoriesUseCase.swift
//  Spendly
//
//  Created by Shahudaa on 21/10/2026.
//


import Foundation

final class FetchCategoriesUseCase {
	private let repository: CategoryRepositoryInterface

	init(repository: CategoryRepositoryInterface) {
        self.repository = repository
    }

    func execute() throws -> [Category] {
        try repository.fetchCategories()
    }
}
