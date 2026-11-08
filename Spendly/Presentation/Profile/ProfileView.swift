//
//  ProfileView.swift
//  Spendly
//
//  شاشة الملف الشخصي والإعدادات
//
//  تحتوي على:
//  - التفضيلات (العملة، اللغة، المظهر)
//  - الأمان (Face ID، قفل التطبيق)
//  - الإشعارات (تذكيرات الدفع، تنبيهات الميزانية)
//  - البيانات (تصدير، استيراد)
//

import SwiftUI

// MARK: - AppearanceMode
// وضع المظهر

enum AppearanceMode: String, CaseIterable {
    case system = "system"
    case light  = "light"
    case dark   = "dark"
    
    var locKey: String {
        switch self {
        case .system: return "profile.appearance.system"
        case .light:  return "profile.appearance.light"
        case .dark:   return "profile.appearance.dark"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}

// MARK: - ProfileView

struct ProfileView: View {
    
    // MARK: - الحالة
    
    @AppStorage("appearance_mode") private var appearanceModeRaw = AppearanceMode.system.rawValue
    @AppStorage("face_id_enabled") private var faceIDEnabled = true
    @AppStorage("app_lock_enabled") private var appLockEnabled = false
    @AppStorage("notif_payment")  private var notifPayment  = true
    @AppStorage("notif_budget")   private var notifBudget   = true
    @AppStorage("notif_monthly")  private var notifMonthly  = false
    
    @Binding var colorScheme: AppearanceMode
    
    @Environment(LocalizationManager.self) private var locManager
    
    // MARK: - الواجهة
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                
                // ── عنوان الصفحة ─────────────────────────────
                Text(locManager.localize("profile.title"))
                    .font(SpendlyFont.largeTitle)
                    .padding(.horizontal, SpendlySpacing.xl)
                    .padding(.top, 8)
                
                // ── قسم التفضيلات ─────────────────────────────
                sectionHeader(locManager.localize("profile.preferences"))
                preferencesSection
                
                // ── قسم الأمان ────────────────────────────────
                sectionHeader(locManager.localize("profile.security"))
                securitySection
                
                // ── قسم الإشعارات ─────────────────────────────
                sectionHeader(locManager.localize("profile.notifications"))
                notificationsSection
                
                // ── قسم البيانات ──────────────────────────────
                sectionHeader(locManager.localize("profile.data"))
                dataSection
                    .padding(.bottom, SpendlySpacing.xxl)
            }
        }
        .background(Color.spBackground)
    }
    
    // MARK: - قسم التفضيلات
    
    private var preferencesSection: some View {
        SpendlyCard(padding: 0) {
            VStack(spacing: 0) {
                settingsRow(label: locManager.localize("profile.currency")) {
                    Text(locManager.localize("general.currency")).foregroundStyle(Color.spMuted).font(SpendlyFont.body)
                }
                
                Divider().padding(.leading, SpendlySpacing.lg)
                
                settingsRow(label: locManager.localize("profile.language")) {
                    Menu {
                        ForEach(AppLanguage.allCases, id: \.self) { lang in
                            Button(lang.displayName) {
                                locManager.setLanguage(lang)
                            }
                        }
                    } label: {
                        HStack(spacing: SpendlySpacing.xs) {
                            Text(locManager.language.displayName)
                                .foregroundStyle(Color.spMuted)
                                .font(SpendlyFont.body)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.caption)
                                .foregroundStyle(Color.spMuted)
                        }
                    }
                }
                
                Divider().padding(.leading, SpendlySpacing.lg)
                
                // مفتاح المظهر
                settingsRow(label: locManager.localize("profile.appearance")) {
                    Menu {
                        ForEach(AppearanceMode.allCases, id: \.self) { mode in
                            Button(locManager.localize(mode.locKey)) {
                                colorScheme = mode
                            }
                        }
                    } label: {
                        HStack(spacing: SpendlySpacing.xs) {
                            Text(locManager.localize(colorScheme.locKey))
                                .foregroundStyle(Color.spMuted)
                                .font(SpendlyFont.body)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.caption)
                                .foregroundStyle(Color.spMuted)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, SpendlySpacing.xl)
        .padding(.bottom, SpendlySpacing.sm)
    }
    
    // MARK: - قسم الأمان
    
    private var securitySection: some View {
        SpendlyCard(padding: 0) {
            VStack(spacing: 0) {
                settingsRow(label: "🔒 \(locManager.localize("profile.face_id"))") {
                    Toggle("", isOn: $faceIDEnabled)
                        .tint(Color.spSuccess)
                        .labelsHidden()
                }
                
                Divider().padding(.leading, SpendlySpacing.lg)
                
                settingsRow(label: locManager.localize("profile.app_lock")) {
                    Toggle("", isOn: $appLockEnabled)
                        .tint(Color.spSuccess)
                        .labelsHidden()
                }
                
                Divider().padding(.leading, SpendlySpacing.lg)
                
                // نص توضيحي
                VStack(alignment: .leading, spacing: 2) {
                    Text(locManager.localize("profile.face_id_title"))
                        .font(SpendlyFont.body)
                        .fontWeight(.semibold)
                    Text(locManager.localize("profile.face_id_desc"))
                        .font(SpendlyFont.caption)
                        .foregroundStyle(Color.spMuted)
                }
                .padding(SpendlySpacing.lg)
            }
        }
        .padding(.horizontal, SpendlySpacing.xl)
        .padding(.bottom, SpendlySpacing.sm)
    }
    
    // MARK: - قسم الإشعارات
    
    private var notificationsSection: some View {
        SpendlyCard(padding: 0) {
            VStack(spacing: 0) {
                settingsRow(label: locManager.localize("profile.notif.payment_reminders")) {
                    Toggle("", isOn: $notifPayment).tint(Color.spSuccess).labelsHidden()
                }
                Divider().padding(.leading, SpendlySpacing.lg)
                
                settingsRow(label: locManager.localize("profile.notif.budget_alerts")) {
                    Toggle("", isOn: $notifBudget).tint(Color.spSuccess).labelsHidden()
                }
                Divider().padding(.leading, SpendlySpacing.lg)
                
                settingsRow(label: locManager.localize("profile.notif.monthly_summary")) {
                    Toggle("", isOn: $notifMonthly).tint(Color.spSuccess).labelsHidden()
                }
            }
        }
        .padding(.horizontal, SpendlySpacing.xl)
        .padding(.bottom, SpendlySpacing.sm)
    }
    
    // MARK: - قسم البيانات
    
    private var dataSection: some View {
        SpendlyCard(padding: 0) {
            VStack(spacing: 0) {
                settingsRow(label: locManager.localize("profile.export")) {
                    Image(systemName: locManager.language.isRTL ? "chevron.left" : "chevron.right")
                        .font(SpendlyFont.caption)
                        .foregroundStyle(Color.spMuted)
                }
                Divider().padding(.leading, SpendlySpacing.lg)
                
                settingsRow(label: locManager.localize("profile.import")) {
                    Image(systemName: locManager.language.isRTL ? "chevron.left" : "chevron.right")
                        .font(SpendlyFont.caption)
                        .foregroundStyle(Color.spMuted)
                }
            }
        }
        .padding(.horizontal, SpendlySpacing.xl)
    }
    
    // MARK: - الدوال المساعدة
    
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
}
