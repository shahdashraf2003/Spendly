//
//  BudgetsViewModel.swift
//  Spendly
//
//  Created by Shahudaa on 27/10/2026.
//



import Foundation
import Observation

@MainActor
@Observable
final class BudgetsViewModel {
    private let fetchBudgetsUseCase: FetchBudgetsUseCase
    private let addBudgetUseCase: AddBudgetUseCase
    private let updateBudgetUseCase: UpdateBudgetUseCase
    private let deleteBudgetUseCase: DeleteBudgetUseCase

    private(set) var budgets: [Budget] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    init(
        fetchBudgetsUseCase: FetchBudgetsUseCase,
        addBudgetUseCase: AddBudgetUseCase,
        updateBudgetUseCase: UpdateBudgetUseCase,
        deleteBudgetUseCase: DeleteBudgetUseCase
    ) {
        self.fetchBudgetsUseCase = fetchBudgetsUseCase
        self.addBudgetUseCase = addBudgetUseCase
        self.updateBudgetUseCase = updateBudgetUseCase
        self.deleteBudgetUseCase = deleteBudgetUseCase
    }

    func loadBudgets() {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            budgets = try fetchBudgetsUseCase.execute()
        } catch {
            errorMessage = "Couldn't load budgets. Please try again."
        }
    }

    func addBudget(_ budget: Budget) {
        errorMessage = nil

        do {
            try addBudgetUseCase.execute(budget)
            loadBudgets()
        } catch {
            errorMessage = "Couldn't add budget. Check the amount and make sure this category doesn't already have a budget for this period."
        }
    }

    func updateBudget(_ budget: Budget) {
        errorMessage = nil

        do {
            try updateBudgetUseCase.execute(budget)
            loadBudgets()
        } catch {
            errorMessage = "Couldn't update budget. Please try again."
        }
    }

    func deleteBudget(id: UUID) {
        errorMessage = nil

        do {
            try deleteBudgetUseCase.execute(id: id)
            loadBudgets()
        } catch {
            errorMessage = "Couldn't delete budget. Please try again."
        }
    }
}
