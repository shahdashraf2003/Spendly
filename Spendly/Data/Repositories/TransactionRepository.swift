//
//  TransactionRepositoryError.swift
//  Spendly
//
//  Created by Shahudaa on 20/10/2026.
//


import Foundation

enum TransactionRepositoryError: Error {
	case transactionNotFound
	case categoryNotFound
}

final class TransactionRepository: TransactionRepositoryInterface {
	private let localDataSource: TransactionLocalDataSource

	init(localDataSource: TransactionLocalDataSource) {
		self.localDataSource = localDataSource
	}

	func fetchTransactions() throws -> [Transaction] {
		let models = try localDataSource.fetchTransactions()
		return models.map { $0.toDomain() }
	}

	func fetchTransaction(id: UUID) throws -> Transaction? {
		guard let model = try localDataSource.fetchTransaction(id: id) else {
			return nil
		}

		return model.toDomain()
	}

	func addTransaction(_ transaction: Transaction) throws {
		let category = try resolveCategory(id: transaction.categoryID)

		let model = TransactionModel(
			id: transaction.id,
			amount: transaction.amount,
			type: transaction.type,
			date: transaction.date,
			note: transaction.note,
			category: category
		)

		localDataSource.insert(model)
		try localDataSource.saveChanges()
	}

	func updateTransaction(_ transaction: Transaction) throws {
		guard let model = try localDataSource.fetchTransaction(id: transaction.id) else {
			throw TransactionRepositoryError.transactionNotFound
		}

		let category = try resolveCategory(id: transaction.categoryID)

		model.amount = transaction.amount
		model.type = transaction.type
		model.date = transaction.date
		model.note = transaction.note
		model.category = category

		try localDataSource.saveChanges()
	}

	func deleteTransaction(id: UUID) throws {
		guard let model = try localDataSource.fetchTransaction(id: id) else {
			return
		}

		localDataSource.delete(model)
		try localDataSource.saveChanges()
	}

	private func resolveCategory(id: UUID?) throws -> CategoryModel? {
		guard let id else {
			return nil
		}

		guard let category = try localDataSource.fetchCategory(id: id) else {
			throw TransactionRepositoryError.categoryNotFound
		}

		return category
	}
}
