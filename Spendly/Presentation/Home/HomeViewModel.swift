//
//  HomeViewModel.swift
//  Spendly
//
//  Responsibilities:
//  - Fetch financial summary (balance, income, expenses) from ALL transactions
//  - Provide recent transactions (last 5) for the home screen list
//  - Fetch budgets and categories for spending breakdown
//

import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {

    // MARK: - Dependencies

    private let fetchTransactionsUseCase: FetchTransactionsUseCase
    private let fetchBudgetsUseCase: FetchBudgetsUseCase
    private let fetchCategoriesUseCase: FetchCategoriesUseCase

    // MARK: - State

    /// All transactions — used for accurate totals and analytics
    private(set) var allTransactions: [Transaction] = []

    /// Last 5 transactions shown on the home screen list
    private(set) var recentTransactions: [Transaction] = []

    private(set) var budgets: [Budget] = []
    private(set) var categories: [Category] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    // MARK: - Computed Totals (from ALL transactions, not just recent)

    var totalIncome: Decimal {
        allTransactions
            .filter { $0.type == .income }
            .reduce(0) { $0 + $1.amount }
    }

    var totalExpenses: Decimal {
        allTransactions
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
    }

    var netBalance: Decimal {
        totalIncome - totalExpenses
    }

    var totalBudget: Decimal {
        budgets.reduce(0) { $0 + $1.amount }
    }

    var overallSpendingPercentage: Double {
        guard totalBudget > 0 else { return 0 }
        return Double(truncating: (totalExpenses / totalBudget * 100) as NSDecimalNumber)
    }

    // MARK: - Init

    init(
        fetchTransactionsUseCase: FetchTransactionsUseCase,
        fetchBudgetsUseCase: FetchBudgetsUseCase,
        fetchCategoriesUseCase: FetchCategoriesUseCase
    ) {
        self.fetchTransactionsUseCase = fetchTransactionsUseCase
        self.fetchBudgetsUseCase = fetchBudgetsUseCase
        self.fetchCategoriesUseCase = fetchCategoriesUseCase
    }

    // MARK: - Load

    func loadData() {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            let sorted = try fetchTransactionsUseCase.execute()
                .sorted { $0.date > $1.date }

            allTransactions  = sorted
            recentTransactions = Array(sorted.prefix(5))

            budgets    = try fetchBudgetsUseCase.execute()
            categories = try fetchCategoriesUseCase.execute()
        } catch {
            errorMessage = "Couldn't load data. Please try again."
        }
    }

    // MARK: - Helpers

    func category(for id: UUID?) -> Category? {
        guard let id else { return nil }
        return categories.first { $0.id == id }
    }

    /// Expense total for a specific category across ALL transactions
    func spent(for categoryID: UUID) -> Decimal {
        allTransactions
            .filter { $0.type == .expense && $0.categoryID == categoryID }
            .reduce(0) { $0 + $1.amount }
    }
}
