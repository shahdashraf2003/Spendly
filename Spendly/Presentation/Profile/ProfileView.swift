//
//  ProfileView.swift
//  Spendly
//
//  Profile and Settings screen:
//  - User identity card (avatar + editable name)
//  - Preferences (Currency, Language, Appearance)
//  - Security (Face ID, App Lock)
//  - Notifications (Payment Reminders, Budget Alerts, Monthly Summary)
//  - Data (JSON Export & Import)
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers

// MARK: - ProfileView

struct ProfileView: View {

    // MARK: - Dependencies

    let appContainer: AppContainer
    var onDataImported: () -> Void

    @AppStorage("spendly_user_name") private var userName = ""

    @Environment(LocalizationManager.self) private var locManager
    @Environment(SettingsManager.self) private var settingsManager

    // MARK: - Local State

    @State private var toastMessage: String?

    @State private var showExporter = false
    @State private var exportDocument: SpendlyBackupDocument?
    @State private var showImporter = false

    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showSettingsButtonInAlert = false

    // MARK: - Body

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {

                Text(locManager.localize("profile.title"))
                    .font(SpendlyFont.largeTitle)
                    .padding(.horizontal, SpendlySpacing.xl)
                    .padding(.top, 8)

                userIdentitySection
                    .padding(.top, SpendlySpacing.lg)

                sectionHeader(locManager.localize("profile.preferences"))
                preferencesSection

                sectionHeader(locManager.localize("profile.security"))
                securitySection

                sectionHeader(locManager.localize("profile.notifications"))
                notificationsSection

                sectionHeader(locManager.localize("profile.data"))
                dataSection
                    .padding(.bottom, SpendlySpacing.xxl)
            }
        }
        .background(Color.spBackground)
        .toast(message: $toastMessage)
        .fileExporter(
            isPresented: $showExporter,
            document: exportDocument,
            contentType: .json,
            defaultFilename: appContainer.dataBackupService.defaultExportFilename()
        ) { result in
            switch result {
            case .success:
                showToast(locManager.localize("data.export_success"))
            case .failure:
                presentErrorAlert(
                    title: locManager.localize("profile.export"),
                    message: locManager.localize("data.export_error")
                )
            }
        }
        .fileImporter(
            isPresented: $showImporter,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            handleImportResult(result)
        }
        .alert(alertTitle, isPresented: $showAlert) {
            if showSettingsButtonInAlert {
                Button(locManager.localize("notif.open_settings")) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button(locManager.localize("general.cancel"), role: .cancel) {}
            } else {
                Button(locManager.localize("general.ok"), role: .cancel) {}
            }
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: - User Identity Section

    private var userIdentitySection: some View {
        SpendlyCard {
            HStack(spacing: SpendlySpacing.lg) {
                Circle()
                    .fill(Color.spAccentSurface)
                    .frame(width: 56, height: 56)
                    .overlay(
                        Group {
                            if let initial = userName.first {
                                Text(String(initial).uppercased())
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundStyle(Color.spAccent)
                            } else {
                                Text("👤")
                                    .font(.system(size: 24))
                            }
                        }
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(locManager.localize("profile.your_name"))
                        .font(SpendlyFont.caption)
                        .foregroundStyle(Color.spMuted)

                    TextField(
                        locManager.localize("profile.name_placeholder"),
                        text: $userName
                    )
                    .font(SpendlyFont.bodyLarge)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.spForeground)
                    .submitLabel(.done)
                }
            }
        }
        .padding(.horizontal, SpendlySpacing.xl)
        .padding(.bottom, SpendlySpacing.sm)
    }

    // MARK: - Preferences Section

    private var preferencesSection: some View {
        SpendlyCard(padding: 0) {
            VStack(spacing: 0) {
                settingsRow(label: locManager.localize("profile.currency")) {
                    Menu {
                        ForEach(AppCurrency.allCases) { currency in
                            Button {
                                settingsManager.setCurrency(currency)
                            } label: {
                                if settingsManager.currency == currency {
                                    Label(currency.displayName(using: locManager), systemImage: "checkmark")
                                } else {
                                    Text(currency.displayName(using: locManager))
                                }
                            }
                        }
                    } label: {
                        menuLabel(settingsManager.currencySymbol(using: locManager))
                    }
                }

                Divider().padding(.leading, SpendlySpacing.lg)

                settingsRow(label: locManager.localize("profile.language")) {
                    Menu {
                        ForEach(AppLanguage.allCases, id: \.self) { lang in
                            Button {
                                locManager.setLanguage(lang)
                            } label: {
                                if locManager.language == lang {
                                    Label(lang.displayName, systemImage: "checkmark")
                                } else {
                                    Text(lang.displayName)
                                }
                            }
                        }
                    } label: {
                        menuLabel(locManager.language.displayName)
                    }
                }

                Divider().padding(.leading, SpendlySpacing.lg)

                settingsRow(label: locManager.localize("profile.appearance")) {
                    Menu {
                        ForEach(AppearanceMode.allCases, id: \.self) { mode in
                            Button {
                                settingsManager.setAppearanceMode(mode)
                            } label: {
                                if settingsManager.appearanceMode == mode {
                                    Label(locManager.localize(mode.locKey), systemImage: "checkmark")
                                } else {
                                    Text(locManager.localize(mode.locKey))
                                }
                            }
                        }
                    } label: {
                        menuLabel(locManager.localize(settingsManager.appearanceMode.locKey))
                    }
                }
            }
        }
        .padding(.horizontal, SpendlySpacing.xl)
        .padding(.bottom, SpendlySpacing.sm)
    }

    // MARK: - Security Section

    private var securitySection: some View {
        SpendlyCard(padding: 0) {
            VStack(spacing: 0) {
                settingsRow(label: "🔒 \(locManager.localize("profile.face_id"))") {
                    Toggle("", isOn: faceIDBinding)
                        .tint(Color.spSuccess)
                        .labelsHidden()
                }

                Divider().padding(.leading, SpendlySpacing.lg)

                settingsRow(label: locManager.localize("profile.app_lock")) {
                    Toggle("", isOn: appLockBinding)
                        .tint(Color.spSuccess)
                        .labelsHidden()
                }

                Divider().padding(.leading, SpendlySpacing.lg)

                VStack(alignment: .leading, spacing: 2) {
                    Text(locManager.localize("profile.face_id_title"))
                        .font(SpendlyFont.body)
                        .fontWeight(.semibold)
                    Text(locManager.localize("profile.face_id_desc"))
                        .font(SpendlyFont.caption)
                        .foregroundStyle(Color.spMuted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(SpendlySpacing.lg)
            }
        }
        .padding(.horizontal, SpendlySpacing.xl)
        .padding(.bottom, SpendlySpacing.sm)
    }

    // MARK: - Notifications Section

    private var notificationsSection: some View {
        SpendlyCard(padding: 0) {
            VStack(spacing: 0) {
                settingsRow(label: locManager.localize("profile.notif.payment_reminders")) {
                    Toggle(
                        "",
                        isOn: notificationBinding(
                            for: .paymentReminder,
                            get: { settingsManager.notifPayment },
                            titleKey: "notif.payment.title",
                            bodyKey: "notif.payment.body"
                        )
                    )
                    .tint(Color.spSuccess)
                    .labelsHidden()
                }

                Divider().padding(.leading, SpendlySpacing.lg)

                settingsRow(label: locManager.localize("profile.notif.budget_alerts")) {
                    Toggle(
                        "",
                        isOn: notificationBinding(
                            for: .budgetAlert,
                            get: { settingsManager.notifBudget },
                            titleKey: "notif.budget.title",
                            bodyKey: "notif.budget.body"
                        )
                    )
                    .tint(Color.spSuccess)
                    .labelsHidden()
                }

                Divider().padding(.leading, SpendlySpacing.lg)

                settingsRow(label: locManager.localize("profile.notif.monthly_summary")) {
                    Toggle(
                        "",
                        isOn: notificationBinding(
                            for: .monthlySummary,
                            get: { settingsManager.notifMonthly },
                            titleKey: "notif.monthly.title",
                            bodyKey: "notif.monthly.body"
                        )
                    )
                    .tint(Color.spSuccess)
                    .labelsHidden()
                }
            }
        }
        .padding(.horizontal, SpendlySpacing.xl)
        .padding(.bottom, SpendlySpacing.sm)
    }

    // MARK: - Data Section

    private var dataSection: some View {
        SpendlyCard(padding: 0) {
            VStack(spacing: 0) {
                Button {
                    startExport()
                } label: {
                    settingsRow(label: locManager.localize("profile.export")) {
                        Image(systemName: locManager.language.isRTL ? "chevron.left" : "chevron.right")
                            .font(SpendlyFont.caption)
                            .foregroundStyle(Color.spMuted)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Divider().padding(.leading, SpendlySpacing.lg)

                Button {
                    showImporter = true
                } label: {
                    settingsRow(label: locManager.localize("profile.import")) {
                        Image(systemName: locManager.language.isRTL ? "chevron.left" : "chevron.right")
                            .font(SpendlyFont.caption)
                            .foregroundStyle(Color.spMuted)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, SpendlySpacing.xl)
    }

    // MARK: - Bindings

    private var faceIDBinding: Binding<Bool> {
        Binding(
            get: { settingsManager.faceIDEnabled },
            set: { newValue in
                Task {
                    if let errorKey = await settingsManager.toggleFaceID(
                        newValue,
                        reason: locManager.localize("security.enable_reason")
                    ) {
                        presentErrorAlert(
                            title: locManager.localize("profile.face_id"),
                            message: locManager.localize(errorKey)
                        )
                    }
                }
            }
        )
    }

    private var appLockBinding: Binding<Bool> {
        Binding(
            get: { settingsManager.appLockEnabled },
            set: { newValue in
                Task {
                    if let errorKey = await settingsManager.toggleAppLock(
                        newValue,
                        reason: locManager.localize("security.enable_reason")
                    ) {
                        presentErrorAlert(
                            title: locManager.localize("profile.app_lock"),
                            message: locManager.localize(errorKey)
                        )
                    }
                }
            }
        )
    }

    private func notificationBinding(
        for type: NotificationType,
        get: @escaping () -> Bool,
        titleKey: String,
        bodyKey: String
    ) -> Binding<Bool> {
        Binding(
            get: get,
            set: { newValue in
                Task {
                    let result = await settingsManager.toggleNotification(
                        type,
                        enabled: newValue,
                        title: locManager.localize(titleKey),
                        body: locManager.localize(bodyKey)
                    )

                    switch result {
                    case .enabled:
                        if type == .budgetAlert {
                            appContainer.homeViewModel.loadData()
                            settingsManager.checkBudgetAlerts(
                                budgets: appContainer.homeViewModel.budgets,
                                transactions: appContainer.homeViewModel.allTransactions,
                                categories: appContainer.homeViewModel.categories,
                                locManager: locManager
                            )
                        }
                        showToast(locManager.localize("notif.enabled"))
                    case .disabled:
                        showToast(locManager.localize("notif.disabled"))
                    case .permissionDenied:
                        alertTitle = locManager.localize("notif.permission_denied.title")
                        alertMessage = locManager.localize("notif.permission_denied.message")
                        showSettingsButtonInAlert = true
                        showAlert = true
                    }
                }
            }
        )
    }

    // MARK: - Backup Actions

    private func startExport() {
        do {
            exportDocument = try appContainer.dataBackupService.exportDocument()
            showExporter = true
        } catch {
            presentErrorAlert(
                title: locManager.localize("profile.export"),
                message: locManager.localize("data.export_error")
            )
        }
    }

    private func handleImportResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            do {
                let summary = try appContainer.dataBackupService.importBackup(from: url)

                appContainer.transactionsViewModel.loadTransactions()
                appContainer.budgetsViewModel.loadBudgets()
                appContainer.homeViewModel.loadData()
                onDataImported()

                if summary.isEmpty {
                    showToast(locManager.localize("data.import_nothing_new"))
                } else {
                    showToast(
                        locManager.localize(
                            "data.import_success",
                            args: summary.transactionsAdded,
                            summary.budgetsAdded,
                            summary.categoriesAdded
                        )
                    )
                }
            } catch {
                presentErrorAlert(
                    title: locManager.localize("profile.import"),
                    message: locManager.localize("data.import_error")
                )
            }
        case .failure:
            presentErrorAlert(
                title: locManager.localize("profile.import"),
                message: locManager.localize("data.import_error")
            )
        }
    }

    // MARK: - Helpers

    private func menuLabel(_ value: String) -> some View {
        HStack(spacing: SpendlySpacing.xs) {
            Text(value)
                .foregroundStyle(Color.spMuted)
                .font(SpendlyFont.body)
            Image(systemName: "chevron.up.chevron.down")
                .font(.caption)
                .foregroundStyle(Color.spMuted)
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(SpendlyFont.caption)
            .foregroundStyle(Color.spMuted)
            .padding(.horizontal, SpendlySpacing.xl)
            .padding(.top, SpendlySpacing.lg)
            .padding(.bottom, SpendlySpacing.sm)
    }

    private func settingsRow<Trailing: View>(
        label: String,
        @ViewBuilder trailing: () -> Trailing
    ) -> some View {
        HStack {
            Text(label)
                .font(SpendlyFont.body)
                .foregroundStyle(Color.spForeground)
            Spacer()
            trailing()
        }
        .padding(SpendlySpacing.lg)
    }

    private func showToast(_ message: String) {
        toastMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            if toastMessage == message {
                toastMessage = nil
            }
        }
    }

    private func presentErrorAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showSettingsButtonInAlert = false
        showAlert = true
    }
}
