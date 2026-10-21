//
//  DeleteTransactionUseCase.swift
//  Spendly
//
//  Created by Shahudaa on 21/10/2026.
//


import Foundation

final class DeleteTransactionUseCase {
    private let repository: TransactionRepositoryInterface

    init(repository: TransactionRepositoryInterface) {
        self.repository = repository
    }

    func execute(id: UUID) throws {
        try repository.deleteTransaction(id: id)
    }
}
