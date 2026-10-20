//
//  TransactionRepository.swift
//  Spendly
//
//  Created by Shahudaa on 13/10/2026.
//



import Foundation

protocol TransactionRepository {
    func fetchTransactions() throws -> [Transaction]
    func fetchTransaction(id: UUID) throws -> Transaction?
    func addTransaction(_ transaction: Transaction) throws
    func updateTransaction(_ transaction: Transaction) throws
    func deleteTransaction(id: UUID) throws
}
