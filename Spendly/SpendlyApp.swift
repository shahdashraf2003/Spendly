//
//  SpendlyApp.swift
//  Spendly
//
//  Created by Shahudaa on 04/10/2026.
//

import SwiftUI
import SwiftData

@main
struct SpendlyApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            CategoryModel.self,
            TransactionModel.self,
            BudgetModel.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
