//
//  CategoriesViewModel.swift
//  Spendly
//
//  Created by Shahudaa on 27/10/2026.
//


import Foundation
import Observation

@MainActor
@Observable
final class CategoriesViewModel {
    private let fetchCategoriesUseCase: FetchCategoriesUseCase
    private let addCategoryUseCase: AddCategoryUseCase
    private let updateCategoryUseCase: UpdateCategoryUseCase
    private let deleteCategoryUseCase: DeleteCategoryUseCase

    private(set) var categories: [Category] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    init(
        fetchCategoriesUseCase: FetchCategoriesUseCase,
        addCategoryUseCase: AddCategoryUseCase,
        updateCategoryUseCase: UpdateCategoryUseCase,
        deleteCategoryUseCase: DeleteCategoryUseCase
    ) {
        self.fetchCategoriesUseCase = fetchCategoriesUseCase
        self.addCategoryUseCase = addCategoryUseCase
        self.updateCategoryUseCase = updateCategoryUseCase
        self.deleteCategoryUseCase = deleteCategoryUseCase
    }

    func loadCategories() {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            categories = try fetchCategoriesUseCase.execute()
        } catch {
            errorMessage = "Couldn't load categories. Please try again."
        }
    }

    func addCategory(_ category: Category) {
        errorMessage = nil

        do {
            try addCategoryUseCase.execute(category)
            loadCategories()
        } catch {
            errorMessage = "Couldn't add category. Please try again."
        }
    }

    func updateCategory(_ category: Category) {
        errorMessage = nil

        do {
            try updateCategoryUseCase.execute(category)
            loadCategories()
        } catch {
            errorMessage = "Couldn't update category. Please try again."
        }
    }

    func deleteCategory(id: UUID) {
        errorMessage = nil

        do {
            try deleteCategoryUseCase.execute(id: id)
            loadCategories()
        } catch {
            errorMessage = "Couldn't delete category. Please try again."
        }
    }
}