//
//  TransactionMapper.swift
//  Spendly
//
//  Created by Shahudaa on 13/10/2026.
//


import Foundation

extension TransactionModel {
	func toDomain() -> Transaction {
		Transaction(
			id: id,
			amount: amount,
			type: type,
			date: date,
			note: note,
			categoryID: category?.id
		)
	}
}
