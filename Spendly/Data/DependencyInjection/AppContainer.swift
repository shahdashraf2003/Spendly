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

	let fetchBudgetsUseCase: FetchBudgetsUseCase
	let addBudgetUseCase: AddBudgetUseCase
	let updateBudgetUseCase: UpdateBudgetUseCase
	let deleteBudgetUseCase: DeleteBudgetUseCase

	let transactionsViewModel: TransactionsViewModel
	let categoriesViewModel: CategoriesViewModel
	let budgetsViewModel: BudgetsViewModel

	/// ViewModel الشاشة الرئيسية — يجمع البيانات من كل الـ UseCases
	let homeViewModel: HomeViewModel

	/// Factory لإنشاء AddBudgetViewModel — يُستدعى في كل مرة يُفتح فيها الشيت
	func makeAddBudgetViewModel() -> AddBudgetViewModel {
		AddBudgetViewModel(
			addBudgetUseCase: addBudgetUseCase,
			fetchCategoriesUseCase: fetchCategoriesUseCase
		)
	}

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

		self.fetchBudgetsUseCase = FetchBudgetsUseCase(
			repository: budgetRepository
		)

		self.addBudgetUseCase = AddBudgetUseCase(
			repository: budgetRepository
		)

		self.updateBudgetUseCase = UpdateBudgetUseCase(
			repository: budgetRepository
		)

		self.deleteBudgetUseCase = DeleteBudgetUseCase(
			repository: budgetRepository
		)

		self.transactionsViewModel = TransactionsViewModel(
			fetchTransactionsUseCase: fetchTransactionsUseCase,
			addTransactionUseCase: addTransactionUseCase,
			updateTransactionUseCase: updateTransactionUseCase,
			deleteTransactionUseCase: deleteTransactionUseCase
		)

		self.categoriesViewModel = CategoriesViewModel(
			fetchCategoriesUseCase: fetchCategoriesUseCase,
			addCategoryUseCase: addCategoryUseCase,
			updateCategoryUseCase: updateCategoryUseCase,
			deleteCategoryUseCase: deleteCategoryUseCase
		)

		self.budgetsViewModel = BudgetsViewModel(
			fetchBudgetsUseCase: fetchBudgetsUseCase,
			addBudgetUseCase: addBudgetUseCase,
			updateBudgetUseCase: updateBudgetUseCase,
			deleteBudgetUseCase: deleteBudgetUseCase
		)
		
		// ── HomeViewModel يجمع البيانات من كل الـ UseCases ──
		self.homeViewModel = HomeViewModel(
			fetchTransactionsUseCase: fetchTransactionsUseCase,
			fetchBudgetsUseCase: fetchBudgetsUseCase,
			fetchCategoriesUseCase: fetchCategoriesUseCase
		)
    }
}
