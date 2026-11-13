//
//  BudgetMapper.swift
//  Spendly
//
//  Created by Shahudaa on 13/10/2026.
//


import Foundation

extension BudgetModel {
	func toDomain() -> Budget? {
		guard let categoryID = category?.id else {
			return nil
		}

		return Budget(
			id: id,
			amount: amount,
			period: period,
			categoryID: categoryID
		)
	}
}
