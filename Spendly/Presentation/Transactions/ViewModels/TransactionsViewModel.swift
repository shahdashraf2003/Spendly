//
//  TransactionsViewModel.swift
//  Spendly
//
//  Created by Shahudaa on 27/10/2026.
//


import Foundation
import Observation

@MainActor
@Observable
final class TransactionsViewModel {
    private let fetchTransactionsUseCase: FetchTransactionsUseCase
    private let addTransactionUseCase: AddTransactionUseCase
    private let updateTransactionUseCase: UpdateTransactionUseCase
    private let deleteTransactionUseCase: DeleteTransactionUseCase

    private(set) var transactions: [Transaction] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    init(
        fetchTransactionsUseCase: FetchTransactionsUseCase,
        addTransactionUseCase: AddTransactionUseCase,
        updateTransactionUseCase: UpdateTransactionUseCase,
        deleteTransactionUseCase: DeleteTransactionUseCase
    ) {
        self.fetchTransactionsUseCase = fetchTransactionsUseCase
        self.addTransactionUseCase = addTransactionUseCase
        self.updateTransactionUseCase = updateTransactionUseCase
        self.deleteTransactionUseCase = deleteTransactionUseCase
    }

    func loadTransactions() {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            transactions = try fetchTransactionsUseCase.execute()
        } catch {
            errorMessage = "Couldn't load transactions. Please try again."
        }
    }

    func addTransaction(_ transaction: Transaction) {
        errorMessage = nil

        do {
            try addTransactionUseCase.execute(transaction)
            loadTransactions()
        } catch {
            errorMessage = "Couldn't add transaction. Please try again."
        }
    }

    func updateTransaction(_ transaction: Transaction) {
        errorMessage = nil

        do {
            try updateTransactionUseCase.execute(transaction)
            loadTransactions()
        } catch {
            errorMessage = "Couldn't update transaction. Please try again."
        }
    }

    func deleteTransaction(id: UUID) {
        errorMessage = nil

        do {
            try deleteTransactionUseCase.execute(id: id)
            loadTransactions()
        } catch {
            errorMessage = "Couldn't delete transaction. Please try again."
        }
    }
}