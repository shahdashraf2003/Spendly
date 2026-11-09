//
//  AddBudgetViewModel.swift
//  Spendly
//


import Foundation
import Observation

@MainActor
@Observable
final class AddBudgetViewModel {

    // MARK: - Dependencies

    private let addBudgetUseCase: AddBudgetUseCase
    private let fetchCategoriesUseCase: FetchCategoriesUseCase

    // MARK: - State

    private(set) var expenseCategories: [Category] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var didSaveSuccessfully = false

    // MARK: - Form State

    var amountText: String = ""
    var selectedCategory: Category?
    var selectedPeriod: BudgetPeriod = .monthly

    // MARK: - Validation Errors

    private(set) var amountError = false
    private(set) var categoryError = false

    // MARK: - Init

    init(
        addBudgetUseCase: AddBudgetUseCase,
        fetchCategoriesUseCase: FetchCategoriesUseCase
    ) {
        self.addBudgetUseCase = addBudgetUseCase
        self.fetchCategoriesUseCase = fetchCategoriesUseCase
    }

    // MARK: - Load

    func loadCategories() {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            let all = try fetchCategoriesUseCase.execute()
            expenseCategories = all.filter { $0.type == .expense }
        } catch {
            errorMessage = "general.error.loading_data"
        }
    }

    // MARK: - Save

    func saveBudget() {
        amountError = !(Decimal(string: amountText).map { $0 > 0 } ?? false)
        categoryError = (selectedCategory == nil)

        guard !amountError, !categoryError else { return }

        guard let amount = Decimal(string: amountText), let category = selectedCategory else { return }

        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        let budget = Budget(
            amount: amount,
            period: selectedPeriod,
            categoryID: category.id
        )

        do {
            try addBudgetUseCase.execute(budget)
            didSaveSuccessfully = true
        } catch BudgetRepositoryError.duplicateBudget {
            errorMessage = "add_budget.error.duplicate"
        } catch {
            errorMessage = "add_budget.error.generic"
        }
    }
}
