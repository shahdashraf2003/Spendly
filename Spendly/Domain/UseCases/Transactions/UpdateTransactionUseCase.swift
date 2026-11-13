//
//  UpdateTransactionUseCase.swift
//  Spendly
//
//  Created by Shahudaa on 21/10/2026.
//


import Foundation

final class UpdateTransactionUseCase {
    private let repository: TransactionRepositoryInterface
    init(repository: TransactionRepositoryInterface) {
        self.repository = repository
    }

    func execute(_ transaction: Transaction) throws {
        guard transaction.amount > 0 else {
            throw TransactionValidationError.invalidAmount
        }

        try repository.updateTransaction(transaction)
    }
}
