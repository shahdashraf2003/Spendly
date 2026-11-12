//
//  SettingsManager.swift
//  Spendly
//
//  Centralized manager for persisted user preferences, security lock, and local notifications.
//

import Foundation
import LocalAuthentication
import Observation
import UserNotifications

// MARK: - AppCurrency

enum AppCurrency: String, CaseIterable, Identifiable {
    case egp = "EGP"
    case usd = "USD"
    case eur = "EUR"
    case sar = "SAR"
    case aed = "AED"
    case gbp = "GBP"

    var id: String { rawValue }

    var locKey: String {
        switch self {
        case .egp: return "currency.egp"
        case .usd: return "currency.usd"
        case .eur: return "currency.eur"
        case .sar: return "currency.sar"
        case .aed: return "currency.aed"
        case .gbp: return "currency.gbp"
        }
    }

    func symbol(for language: AppLanguage) -> String {
        switch self {
        case .egp: return language == .arabic ? "ج.م" : "EGP"
        case .usd: return "$"
        case .eur: return "€"
        case .sar: return language == .arabic ? "ر.س" : "SAR"
        case .aed: return language == .arabic ? "د.إ" : "AED"
        case .gbp: return "£"
        }
    }

    func displayName(using locManager: LocalizationManager) -> String {
        "\(rawValue) · \(locManager.localize(locKey))"
    }
}

// MARK: - NotificationType

enum NotificationType: String {
    case paymentReminder = "spendly_notif_payment"
    case budgetAlert     = "spendly_notif_budget"
    case monthlySummary  = "spendly_notif_monthly"
}

enum NotificationToggleResult {
    case enabled
    case disabled
    case permissionDenied
}

// MARK: - SettingsManager

@MainActor
@Observable
final class SettingsManager {

    // MARK: - Storage Keys

    private enum Keys {
        static let currency        = "spendly_currency"
        static let appearanceMode  = "appearance_mode"
        static let faceIDEnabled   = "face_id_enabled"
        static let appLockEnabled  = "app_lock_enabled"
        static let notifPayment    = "notif_payment"
        static let notifBudget     = "notif_budget"
        static let notifMonthly    = "notif_monthly"
        static let alertedBudgets  = "spendly_alerted_budgets"
    }

    private let defaults: UserDefaults

    // MARK: - Persisted Settings

    private(set) var currency: AppCurrency
    private(set) var appearanceMode: AppearanceMode
    private(set) var faceIDEnabled: Bool
    private(set) var appLockEnabled: Bool
    private(set) var notifPayment: Bool
    private(set) var notifBudget: Bool
    private(set) var notifMonthly: Bool

    // MARK: - Runtime Security State

    private(set) var isUnlocked: Bool

    // MARK: - Init

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        if let rawCurrency = defaults.string(forKey: Keys.currency),
           let savedCurrency = AppCurrency(rawValue: rawCurrency) {
            self.currency = savedCurrency
        } else {
            self.currency = .egp
        }

        if let rawAppearance = defaults.string(forKey: Keys.appearanceMode),
           let savedAppearance = AppearanceMode(rawValue: rawAppearance) {
            self.appearanceMode = savedAppearance
        } else {
            self.appearanceMode = .system
        }

        let lockEnabled = defaults.bool(forKey: Keys.appLockEnabled)
        self.faceIDEnabled = defaults.bool(forKey: Keys.faceIDEnabled)
        self.appLockEnabled = lockEnabled
        self.notifPayment = defaults.bool(forKey: Keys.notifPayment)
        self.notifBudget = defaults.bool(forKey: Keys.notifBudget)
        self.notifMonthly = defaults.bool(forKey: Keys.notifMonthly)
        self.isUnlocked = !lockEnabled
    }

    // MARK: - Preferences

    func setCurrency(_ newCurrency: AppCurrency) {
        currency = newCurrency
        defaults.set(newCurrency.rawValue, forKey: Keys.currency)
    }

    func setAppearanceMode(_ mode: AppearanceMode) {
        appearanceMode = mode
        defaults.set(mode.rawValue, forKey: Keys.appearanceMode)
    }

    func currencySymbol(using locManager: LocalizationManager) -> String {
        currency.symbol(for: locManager.language)
    }

    // MARK: - Security & Biometrics

    func lockIfNeeded() {
        if appLockEnabled {
            isUnlocked = false
        }
    }

    func unlock(reason: String) async -> String? {
        let policy: LAPolicy = faceIDEnabled
            ? .deviceOwnerAuthenticationWithBiometrics
            : .deviceOwnerAuthentication

        let result = await evaluateAuthentication(policy: policy, reason: reason)
        switch result {
        case .success:
            isUnlocked = true
            return nil
        case .unavailable:
            // Fallback to device passcode when biometrics are unavailable
            let fallback = await evaluateAuthentication(policy: .deviceOwnerAuthentication, reason: reason)
            if case .success = fallback {
                isUnlocked = true
                return nil
            }
            return "security.biometric_unavailable"
        case .cancelled:
            return nil
        case .failed:
            return "security.auth_failed"
        }
    }

    func toggleAppLock(_ enabled: Bool, reason: String) async -> String? {
        if !enabled {
            appLockEnabled = false
            defaults.set(false, forKey: Keys.appLockEnabled)
            isUnlocked = true
            return nil
        }

        let policy: LAPolicy = faceIDEnabled
            ? .deviceOwnerAuthenticationWithBiometrics
            : .deviceOwnerAuthentication

        let result = await evaluateAuthentication(policy: policy, reason: reason)
        switch result {
        case .success:
            appLockEnabled = true
            defaults.set(true, forKey: Keys.appLockEnabled)
            isUnlocked = true
            return nil
        case .unavailable:
            return "security.biometric_unavailable"
        case .cancelled:
            return nil
        case .failed:
            return "security.auth_failed"
        }
    }

    func toggleFaceID(_ enabled: Bool, reason: String) async -> String? {
        if !enabled {
            faceIDEnabled = false
            defaults.set(false, forKey: Keys.faceIDEnabled)
            return nil
        }

        let result = await evaluateAuthentication(
            policy: .deviceOwnerAuthenticationWithBiometrics,
            reason: reason
        )

        switch result {
        case .success:
            faceIDEnabled = true
            defaults.set(true, forKey: Keys.faceIDEnabled)
            return nil
        case .unavailable:
            return "security.biometric_unavailable"
        case .cancelled:
            return nil
        case .failed:
            return "security.auth_failed"
        }
    }

    private enum AuthOutcome {
        case success
        case unavailable
        case cancelled
        case failed
    }

    private func evaluateAuthentication(policy: LAPolicy, reason: String) async -> AuthOutcome {
        let context = LAContext()
        var authError: NSError?

        guard context.canEvaluatePolicy(policy, error: &authError) else {
            return .unavailable
        }

        do {
            let success = try await context.evaluatePolicy(policy, localizedReason: reason)
            return success ? .success : .failed
        } catch let error as LAError {
            switch error.code {
            case .userCancel, .systemCancel, .appCancel:
                return .cancelled
            case .biometryNotAvailable, .biometryNotEnrolled, .passcodeNotSet:
                return .unavailable
            default:
                return .failed
            }
        } catch {
            return .failed
        }
    }

    // MARK: - Notifications

    func toggleNotification(
        _ type: NotificationType,
        enabled: Bool,
        title: String,
        body: String
    ) async -> NotificationToggleResult {
        let center = UNUserNotificationCenter.current()

        if !enabled {
            center.removePendingNotificationRequests(withIdentifiers: [type.rawValue])
            setNotificationFlag(type, enabled: false)
            return .disabled
        }

        let granted = await requestNotificationAuthorization(center: center)
        guard granted else {
            setNotificationFlag(type, enabled: false)
            return .permissionDenied
        }

        scheduleNotification(type, title: title, body: body, center: center)
        setNotificationFlag(type, enabled: true)
        return .enabled
    }

    func checkBudgetAlerts(
        budgets: [Budget],
        transactions: [Transaction],
        categories: [Category],
        locManager: LocalizationManager
    ) {
        guard notifBudget else { return }

        let calendar = Calendar.current
        let now = Date()
        var alerted = Set(defaults.stringArray(forKey: Keys.alertedBudgets) ?? [])
        var updated = false

        for budget in budgets {
            guard budget.amount > 0 else { continue }
            let start = windowStart(for: budget.period, calendar: calendar, now: now)
            let spent = transactions
                .filter { $0.type == .expense && $0.categoryID == budget.categoryID && $0.date >= start }
                .reduce(Decimal(0)) { $0 + $1.amount }

            let percentage = Int(truncating: (spent / budget.amount * 100) as NSDecimalNumber)
            guard percentage >= 80 else { continue }

            let alertKey = "\(budget.id.uuidString)_\(Int(start.timeIntervalSince1970))"
            guard !alerted.contains(alertKey) else { continue }

            let categoryName = categories.first { $0.id == budget.categoryID }?.localizedName(using: locManager) ?? ""
            let content = UNMutableNotificationContent()
            content.title = locManager.localize("notif.budget.title")
            content.body = locManager.localize("notif.budget.body", args: percentage, categoryName)
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(
                identifier: "\(NotificationType.budgetAlert.rawValue)_\(alertKey)",
                content: content,
                trigger: trigger
            )
            UNUserNotificationCenter.current().add(request)

            alerted.insert(alertKey)
            updated = true
        }

        if updated {
            defaults.set(Array(alerted), forKey: Keys.alertedBudgets)
        }
    }

    private func setNotificationFlag(_ type: NotificationType, enabled: Bool) {
        switch type {
        case .paymentReminder:
            notifPayment = enabled
            defaults.set(enabled, forKey: Keys.notifPayment)
        case .budgetAlert:
            notifBudget = enabled
            defaults.set(enabled, forKey: Keys.notifBudget)
        case .monthlySummary:
            notifMonthly = enabled
            defaults.set(enabled, forKey: Keys.notifMonthly)
        }
    }

    private func requestNotificationAuthorization(center: UNUserNotificationCenter) async -> Bool {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .badge, .sound])) ?? false
        case .denied:
            return false
        @unknown default:
            return false
        }
    }

    private func scheduleNotification(
        _ type: NotificationType,
        title: String,
        body: String,
        center: UNUserNotificationCenter
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger: UNNotificationTrigger
        switch type {
        case .paymentReminder:
            var dateComponents = DateComponents()
            dateComponents.hour = 20
            dateComponents.minute = 0
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        case .monthlySummary:
            var dateComponents = DateComponents()
            dateComponents.day = 1
            dateComponents.hour = 9
            dateComponents.minute = 0
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        case .budgetAlert:
            // Budget alerts are dispatched dynamically when spending reaches 80% or more
            return
        }

        center.removePendingNotificationRequests(withIdentifiers: [type.rawValue])
        let request = UNNotificationRequest(identifier: type.rawValue, content: content, trigger: trigger)
        center.add(request)
    }

    private func windowStart(for period: BudgetPeriod, calendar: Calendar, now: Date) -> Date {
        switch period {
        case .weekly:  return calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        case .monthly: return calendar.dateInterval(of: .month, for: now)?.start ?? now
        case .yearly:  return calendar.dateInterval(of: .year, for: now)?.start ?? now
        }
    }
}
