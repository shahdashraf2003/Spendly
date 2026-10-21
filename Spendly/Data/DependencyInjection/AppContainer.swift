//
//  AppContainer.swift
//  Spendly
//
//  Created by Shahudaa on 20/10/2026.
//


import Foundation
import SwiftData

@MainActor
final class AppContainer {
	let transactionRepository: TransactionRepositoryInterface
	let categoryRepository: CategoryRepositoryInterface
	let budgetRepository: BudgetRepositoryInterface

	let fetchTransactionsUseCase: FetchTransactionsUseCase
	let addTransactionUseCase: AddTransactionUseCase
	let updateTransactionUseCase: UpdateTransactionUseCase
	let deleteTransactionUseCase: DeleteTransactionUseCase

	let fetchCategoriesUseCase: FetchCategoriesUseCase
	let addCategoryUseCase: AddCategoryUseCase
	let updateCategoryUseCase: UpdateCategoryUseCase
	let deleteCategoryUseCase: DeleteCategoryUseCase

    init(modelContext: ModelContext) {
        let transactionDataSource = TransactionLocalDataSource(
            modelContext: modelContext
        )

        let categoryDataSource = CategoryLocalDataSource(
            modelContext: modelContext
        )

        let budgetDataSource = BudgetLocalDataSource(
            modelContext: modelContext
        )

        self.transactionRepository = TransactionRepository(
            localDataSource: transactionDataSource
        )

        self.categoryRepository = CategoryRepository(
            localDataSource: categoryDataSource
        )

        self.budgetRepository = BudgetRepository(
            localDataSource: budgetDataSource
        )

		self.fetchTransactionsUseCase = FetchTransactionsUseCase(
			repository: transactionRepository
		)

		self.addTransactionUseCase = AddTransactionUseCase(
			repository: transactionRepository
		)

		self.updateTransactionUseCase = UpdateTransactionUseCase(
			repository: transactionRepository
		)

		self.deleteTransactionUseCase = DeleteTransactionUseCase(
			repository: transactionRepository
		)
		
		self.fetchCategoriesUseCase = FetchCategoriesUseCase(
			repository: categoryRepository
		)

		self.addCategoryUseCase = AddCategoryUseCase(
			repository: categoryRepository
		)

		self.updateCategoryUseCase = UpdateCategoryUseCase(
			repository: categoryRepository
		)

		self.deleteCategoryUseCase = DeleteCategoryUseCase(
			repository: categoryRepository
		)
    }
}
