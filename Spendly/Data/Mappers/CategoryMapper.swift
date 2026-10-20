//
//  CategoryMapper.swift
//  Spendly
//
//  Created by Shahudaa on 13/10/2026.
//


import Foundation

extension CategoryModel {
	func toDomain() -> Category {
		Category(
			id: id,
			name: name,
			icon: icon,
			type: type
		)
	}
}
