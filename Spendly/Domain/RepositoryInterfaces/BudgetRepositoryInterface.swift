//
//  BudgetRepository.swift
//  Spendly
//
//  Created by Shahudaa on 20/10/2026.
//


import Foundation

protocol BudgetRepositoryInterface {
    func fetchBudgets() throws -> [Budget]
    func fetchBudget(id: UUID) throws -> Budget?
    func addBudget(_ budget: Budget) throws
    func updateBudget(_ budget: Budget) throws
    func deleteBudget(id: UUID) throws
}
