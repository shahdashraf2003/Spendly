//
//  SpendlyTests.swift
//  SpendlyTests
//
//  Unit tests for SettingsManager, AppCurrency, and DataBackupService.
//

import Foundation
import SwiftData
import Testing
@testable import Spendly

@MainActor
struct SpendlyTests {

    @Test func settingsManagerPersistsCurrencyAndAppearance() {
        let suiteName = "SpendlyTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let manager = SettingsManager(defaults: defaults)
        #expect(manager.currency == .egp)
        #expect(manager.appearanceMode == .system)
        #expect(manager.isUnlocked == true)

        manager.setCurrency(.usd)
        manager.setAppearanceMode(.dark)

        let reloaded = SettingsManager(defaults: defaults)
        #expect(reloaded.currency == .usd)
        #expect(reloaded.appearanceMode == .dark)
    }

    @Test func appCurrencySymbolsMatchLanguage() {
        #expect(AppCurrency.egp.symbol(for: .english) == "EGP")
        #expect(AppCurrency.egp.symbol(for: .arabic) == "ج.م")
        #expect(AppCurrency.usd.symbol(for: .english) == "$")
        #expect(AppCurrency.eur.symbol(for: .english) == "€")
        #expect(AppCurrency.sar.symbol(for: .arabic) == "ر.س")
        #expect(AppCurrency.aed.symbol(for: .arabic) == "د.إ")
        #expect(AppCurrency.gbp.symbol(for: .english) == "£")
    }

    @Test func dataBackupExportAndImportRoundTrip() throws {
        // Source in-memory container
        let schema = Schema([CategoryModel.self, TransactionModel.self, BudgetModel.self])
        let sourceConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let sourceContainer = try ModelContainer(for: schema, configurations: [sourceConfig])
        let sourceApp = AppContainer(modelContext: sourceContainer.mainContext)

        let food = Category(name: "Food", icon: "🍽️", type: .expense)
        try sourceApp.addCategoryUseCase.execute(food)
        try sourceApp.addBudgetUseCase.execute(Budget(amount: 1500, period: .monthly, categoryID: food.id))
        try sourceApp.addTransactionUseCase.execute(
            Transaction(amount: 250, type: .expense, date: Date(), note: "Lunch", categoryID: food.id)
        )

        let document = try sourceApp.dataBackupService.exportDocument()

        // Destination in-memory container
        let destConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let destContainer = try ModelContainer(for: schema, configurations: [destConfig])
        let destApp = AppContainer(modelContext: destContainer.mainContext)

        let firstSummary = try destApp.dataBackupService.importBackup(fromData: document.data)
        #expect(firstSummary.categoriesAdded == 1)
        #expect(firstSummary.budgetsAdded == 1)
        #expect(firstSummary.transactionsAdded == 1)

        // Importing the exact same backup a second time skips duplicates
        let secondSummary = try destApp.dataBackupService.importBackup(fromData: document.data)
        #expect(secondSummary.isEmpty)

        let importedBudgets = try destApp.fetchBudgetsUseCase.execute()
        let importedTransactions = try destApp.fetchTransactionsUseCase.execute()
        #expect(importedBudgets.count == 1)
        #expect(importedBudgets.first?.amount == 1500)
        #expect(importedTransactions.count == 1)
        #expect(importedTransactions.first?.note == "Lunch")
    }
}
