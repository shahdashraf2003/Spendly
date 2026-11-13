//
//  CategoryRepository.swift
//  Spendly
//
//  Created by Shahudaa on 20/10/2026.
//


import Foundation

protocol CategoryRepositoryInterface {
    func fetchCategories() throws -> [Category]
    func fetchCategory(id: UUID) throws -> Category?
    func addCategory(_ category: Category) throws
    func updateCategory(_ category: Category) throws
    func deleteCategory(id: UUID) throws
}
