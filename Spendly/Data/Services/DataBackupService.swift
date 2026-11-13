//
//  DataBackupService.swift
//  Spendly
//
//  JSON backup export and import service using existing Domain entities and Use Cases.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

// MARK: - Backup DTOs

nonisolated struct SpendlyBackup: Codable, Sendable {
    let version: Int
    let exportedAt: Date
    let categories: [CategoryBackupDTO]
    let budgets: [BudgetBackupDTO]
    let transactions: [TransactionBackupDTO]
}

nonisolated struct CategoryBackupDTO: Codable, Sendable {
    let id: UUID
    let name: String
    let icon: String
    let type: CategoryType
}

nonisolated struct BudgetBackupDTO: Codable, Sendable {
    let id: UUID
    let amount: Decimal
    let period: BudgetPeriod
    let categoryID: UUID
}

nonisolated struct TransactionBackupDTO: Codable, Sendable {
    let id: UUID
    let amount: Decimal
    let type: TransactionType
    let date: Date
    let note: String?
    let categoryID: UUID?
}

// MARK: - FileDocument

nonisolated struct SpendlyBackupDocument: FileDocument, Sendable {
    static var readableContentTypes: [UTType] { [.json] }

    let data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        guard let fileData = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = fileData
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

// MARK: - Import Summary

struct BackupImportSummary {
    let categoriesAdded: Int
    let budgetsAdded: Int
    let transactionsAdded: Int

    var isEmpty: Bool {
        categoriesAdded == 0 && budgetsAdded == 0 && transactionsAdded == 0
    }
}

// MARK: - DataBackupService

@MainActor
final class DataBackupService {

    private let fetchCategoriesUseCase: FetchCategoriesUseCase
    private let addCategoryUseCase: AddCategoryUseCase
    private let fetchBudgetsUseCase: FetchBudgetsUseCase
    private let addBudgetUseCase: AddBudgetUseCase
    private let fetchTransactionsUseCase: FetchTransactionsUseCase
    private let addTransactionUseCase: AddTransactionUseCase

    init(
        fetchCategoriesUseCase: FetchCategoriesUseCase,
        addCategoryUseCase: AddCategoryUseCase,
        fetchBudgetsUseCase: FetchBudgetsUseCase,
        addBudgetUseCase: AddBudgetUseCase,
        fetchTransactionsUseCase: FetchTransactionsUseCase,
        addTransactionUseCase: AddTransactionUseCase
    ) {
        self.fetchCategoriesUseCase = fetchCategoriesUseCase
        self.addCategoryUseCase = addCategoryUseCase
        self.fetchBudgetsUseCase = fetchBudgetsUseCase
        self.addBudgetUseCase = addBudgetUseCase
        self.fetchTransactionsUseCase = fetchTransactionsUseCase
        self.addTransactionUseCase = addTransactionUseCase
    }

    // MARK: - Export

    func exportDocument() throws -> SpendlyBackupDocument {
        let categories = try fetchCategoriesUseCase.execute()
        let budgets = try fetchBudgetsUseCase.execute()
        let transactions = try fetchTransactionsUseCase.execute()

        let backup = SpendlyBackup(
            version: 1,
            exportedAt: Date(),
            categories: categories.map {
                CategoryBackupDTO(id: $0.id, name: $0.name, icon: $0.icon, type: $0.type)
            },
            budgets: budgets.map {
                BudgetBackupDTO(id: $0.id, amount: $0.amount, period: $0.period, categoryID: $0.categoryID)
            },
            transactions: transactions.map {
                TransactionBackupDTO(
                    id: $0.id,
                    amount: $0.amount,
                    type: $0.type,
                    date: $0.date,
                    note: $0.note,
                    categoryID: $0.categoryID
                )
            }
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(backup)

        return SpendlyBackupDocument(data: data)
    }

    func defaultExportFilename() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "Spendly_Backup_\(formatter.string(from: Date()))"
    }

    // MARK: - Import

    func importBackup(from url: URL) throws -> BackupImportSummary {
        let accessed = url.startAccessingSecurityScopedResource()
        defer {
            if accessed {
                url.stopAccessingSecurityScopedResource()
            }
        }

        let data = try Data(contentsOf: url)
        return try importBackup(fromData: data)
    }

    func importBackup(fromData data: Data) throws -> BackupImportSummary {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let backup = try decoder.decode(SpendlyBackup.self, from: data)

        // 1. Import Categories and build ID remapping table
        let existingCategories = try fetchCategoriesUseCase.execute()
        var existingCategoryIDs = Set(existingCategories.map(\.id))
        var categoryIDMap: [UUID: UUID] = [:]
        var categoriesAdded = 0

        for dto in backup.categories {
            if existingCategoryIDs.contains(dto.id) {
                categoryIDMap[dto.id] = dto.id
                continue
            }

            if let matched = existingCategories.first(where: {
                $0.name.lowercased() == dto.name.lowercased() && $0.type == dto.type
            }) {
                categoryIDMap[dto.id] = matched.id
                continue
            }

            let category = Category(id: dto.id, name: dto.name, icon: dto.icon, type: dto.type)
            try addCategoryUseCase.execute(category)
            existingCategoryIDs.insert(dto.id)
            categoryIDMap[dto.id] = dto.id
            categoriesAdded += 1
        }

        // 2. Import Budgets (skip duplicates by ID or category + period)
        let existingBudgets = try fetchBudgetsUseCase.execute()
        var existingBudgetIDs = Set(existingBudgets.map(\.id))
        var budgetsAdded = 0

        for dto in backup.budgets {
            guard !existingBudgetIDs.contains(dto.id) else { continue }
            let mappedCategoryID = categoryIDMap[dto.categoryID] ?? dto.categoryID
            guard existingCategoryIDs.contains(mappedCategoryID) else { continue }

            let budget = Budget(
                id: dto.id,
                amount: dto.amount,
                period: dto.period,
                categoryID: mappedCategoryID
            )

            do {
                try addBudgetUseCase.execute(budget)
                existingBudgetIDs.insert(dto.id)
                budgetsAdded += 1
            } catch BudgetRepositoryError.duplicateBudget {
                continue
            }
        }

        // 3. Import Transactions (skip duplicates by ID)
        let existingTransactions = try fetchTransactionsUseCase.execute()
        var existingTransactionIDs = Set(existingTransactions.map(\.id))
        var transactionsAdded = 0

        for dto in backup.transactions {
            guard !existingTransactionIDs.contains(dto.id) else { continue }
            let mappedCategoryID: UUID?
            if let originalCatID = dto.categoryID {
                let candidate = categoryIDMap[originalCatID] ?? originalCatID
                mappedCategoryID = existingCategoryIDs.contains(candidate) ? candidate : nil
            } else {
                mappedCategoryID = nil
            }

            let transaction = Transaction(
                id: dto.id,
                amount: dto.amount,
                type: dto.type,
                date: dto.date,
                note: dto.note,
                categoryID: mappedCategoryID
            )

            try addTransactionUseCase.execute(transaction)
            existingTransactionIDs.insert(dto.id)
            transactionsAdded += 1
        }

        return BackupImportSummary(
            categoriesAdded: categoriesAdded,
            budgetsAdded: budgetsAdded,
            transactionsAdded: transactionsAdded
        )
    }
}
