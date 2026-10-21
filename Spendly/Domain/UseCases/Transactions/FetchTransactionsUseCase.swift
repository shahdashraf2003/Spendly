//
//  FetchTransactionsUseCase.swift
//  Spendly
//
//  Created by Shahudaa on 21/10/2026.
//


import Foundation

final class FetchTransactionsUseCase {
	private let repository: TransactionRepositoryInterface

    init(repository: TransactionRepositoryInterface) {
        self.repository = repository
    }

    func execute() throws -> [Transaction] {
        try repository.fetchTransactions()
    }
}
