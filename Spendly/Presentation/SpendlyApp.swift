//
//  SpendlyApp.swift
//  Spendly
//
//  Created by Shahudaa on 04/10/2026.
//

import SwiftUI
import SwiftData
import UserNotifications

// MARK: - Foreground Notification Delegate
// Without this, iOS silently drops notifications while the app is open.
// This tells iOS to show banner + sound even when Spendly is in the foreground.
class SpendlyNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
}

@main
struct SpendlyApp: App {
    @State private var locManager = LocalizationManager()
    @State private var settingsManager = SettingsManager()
    private let notificationDelegate = SpendlyNotificationDelegate()

    init() {
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }

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
            AppRootView()
                .environment(locManager)
                .environment(settingsManager)
                .layoutDirection(for: locManager)
                .id(locManager.language)
        }
        .modelContainer(sharedModelContainer)
    }
}
