//
//  TransactionRow.swift
//  Spendly
//
//  صف المعاملة — يظهر في قوائم المعاملات
//
//  يحتوي على:
//  - أيقونة الفئة (Category Icon)
//  - اسم المعاملة والفئة والتاريخ
//  - المبلغ (أخضر للدخل، أبيض للمصروف)
//

import SwiftUI

// MARK: - TransactionRow
// يُعرض هذا المكوّن في:
// 1. الصفحة الرئيسية (آخر المعاملات)
// 2. شاشة كل المعاملات

struct TransactionRow: View {
    
    // MARK: - الخصائص
    
    /// بيانات المعاملة (الكيان من طبقة Domain)
    let transaction: Transaction
    
    /// بيانات الفئة المرتبطة بالمعاملة
    let category: Category?
    
    /// هل هناك حدث عند الضغط؟
    var onTap: (() -> Void)?
    
    @Environment(LocalizationManager.self) private var locManager
    @Environment(SettingsManager.self) private var settingsManager
    
    // MARK: - الواجهة
    
    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: SpendlySpacing.md) {
                
                // ── أيقونة الفئة ──────────────────────────────
                CategoryIconView(icon: category?.icon ?? "💸")
                
                // ── اسم المعاملة والتفاصيل ────────────────────
                VStack(alignment: .leading, spacing: 2) {
                    Text(transaction.note ?? category?.localizedName(using: locManager) ?? locManager.localize("general.transaction"))
                        .font(SpendlyFont.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.spForeground)
                        .lineLimit(1)
                    
                    Text(subtitleText)
                        .font(SpendlyFont.caption)
                        .foregroundStyle(Color.spMuted)
                }
                
                Spacer()
                
                // ── المبلغ ────────────────────────────────────
                // أخضر (+) للدخل، طبيعي (-) للمصروف
                Text(amountText)
                    .font(SpendlyFont.body)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        transaction.type == .income ? Color.spSuccess : Color.spForeground
                    )
            }
        }
        .buttonStyle(.plain)  // بدون تأثير الضغط الافتراضي
    }
    
    // MARK: - الحسابات المساعدة
    
    /// نص الفئة والتاريخ
    private var subtitleText: String {
        let catName = category?.localizedName(using: locManager) ?? ""
        let dateStr = transaction.date.formatted(.relative(presentation: .named))
        return catName.isEmpty ? dateStr : "\(catName) · \(dateStr)"
    }
    
    /// نص المبلغ مع الإشارة
    private var amountText: String {
        let sign = transaction.type == .income ? "+" : "−"
        let formatted = transaction.amount.formatted(.number.precision(.fractionLength(0)))
        return "\(sign)\(formatted) \(settingsManager.currencySymbol(using: locManager))"
    }
}

// MARK: - CategoryIconView
// الأيقونة الدائرية للفئة (مستخدمة في TransactionRow وأماكن أخرى)

struct CategoryIconView: View {
    let icon: String
    var size: CGFloat = 40
    
    var body: some View {
        Text(icon)
            .font(.system(size: size * 0.47))    // حجم الإيموجي نسبةً لحجم الحاوية
            .frame(width: size, height: size)
            .background(Color.spAccentSurface)    // الخلفية البرتقالية الفاتحة
            .clipShape(RoundedRectangle(cornerRadius: SpendlyShape.iconRadius))
    }
}

// MARK: - Preview
#Preview("صف معاملة") {
    VStack(spacing: 0) {
        // مصروف
        TransactionRow(
            transaction: Transaction(
                amount: 640,
                type: .expense,
                date: Date(),
                note: "كارفور"
            ),
            category: Category(name: "الطعام", icon: "🍽️", type: .expense)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        
        Divider()
            .padding(.leading, 68)
        
        // دخل
        TransactionRow(
            transaction: Transaction(
                amount: 12000,
                type: .income,
                date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                note: "الراتب"
            ),
            category: Category(name: "الدخل", icon: "💰", type: .income)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    .background(Color.spCard)
    .clipShape(RoundedRectangle(cornerRadius: 20))
    .padding()
    .background(Color.spBackground)
}
