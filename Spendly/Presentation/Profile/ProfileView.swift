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
    case system = "تلقائي"
    case light  = "فاتح"
    case dark   = "داكن"
    
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
    
    // MARK: - الواجهة
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                
                // ── عنوان الصفحة ─────────────────────────────
                Text("حسابي")
                    .font(SpendlyFont.largeTitle)
                    .padding(.horizontal, SpendlySpacing.xl)
                    .padding(.top, 8)
                
                // ── قسم التفضيلات ─────────────────────────────
                sectionHeader("التفضيلات")
                preferencesSection
                
                // ── قسم الأمان ────────────────────────────────
                sectionHeader("الأمان")
                securitySection
                
                // ── قسم الإشعارات ─────────────────────────────
                sectionHeader("الإشعارات")
                notificationsSection
                
                // ── قسم البيانات ──────────────────────────────
                sectionHeader("البيانات")
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
                settingsRow(label: "العملة") {
                    Text("ج.م").foregroundStyle(Color.spMuted).font(SpendlyFont.body)
                }
                
                Divider().padding(.leading, SpendlySpacing.lg)
                
                settingsRow(label: "اللغة") {
                    Text("العربية").foregroundStyle(Color.spMuted).font(SpendlyFont.body)
                }
                
                Divider().padding(.leading, SpendlySpacing.lg)
                
                // مفتاح المظهر
                settingsRow(label: "المظهر") {
                    Menu {
                        ForEach(AppearanceMode.allCases, id: \.self) { mode in
                            Button(mode.rawValue) {
                                colorScheme = mode
                            }
                        }
                    } label: {
                        HStack(spacing: SpendlySpacing.xs) {
                            Text(colorScheme.rawValue)
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
                settingsRow(label: "🔒 Face ID") {
                    Toggle("", isOn: $faceIDEnabled)
                        .tint(Color.spSuccess)
                        .labelsHidden()
                }
                
                Divider().padding(.leading, SpendlySpacing.lg)
                
                settingsRow(label: "قفل التطبيق") {
                    Toggle("", isOn: $appLockEnabled)
                        .tint(Color.spSuccess)
                        .labelsHidden()
                }
                
                Divider().padding(.leading, SpendlySpacing.lg)
                
                // نص توضيحي
                VStack(alignment: .leading, spacing: 2) {
                    Text("احمِ أموالك")
                        .font(SpendlyFont.body)
                        .fontWeight(.semibold)
                    Text("استخدم Face ID للحفاظ على خصوصية معلوماتك المالية.")
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
                settingsRow(label: "تذكير الدفعات") {
                    Toggle("", isOn: $notifPayment).tint(Color.spSuccess).labelsHidden()
                }
                Divider().padding(.leading, SpendlySpacing.lg)
                
                settingsRow(label: "تنبيهات الميزانية") {
                    Toggle("", isOn: $notifBudget).tint(Color.spSuccess).labelsHidden()
                }
                Divider().padding(.leading, SpendlySpacing.lg)
                
                settingsRow(label: "الملخص الشهري") {
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
                settingsRow(label: "تصدير البيانات") {
                    Image(systemName: "chevron.left")
                        .font(SpendlyFont.caption)
                        .foregroundStyle(Color.spMuted)
                }
                Divider().padding(.leading, SpendlySpacing.lg)
                
                settingsRow(label: "استيراد البيانات") {
                    Image(systemName: "chevron.left")
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
