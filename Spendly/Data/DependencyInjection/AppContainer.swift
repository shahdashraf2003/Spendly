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
    }
}
