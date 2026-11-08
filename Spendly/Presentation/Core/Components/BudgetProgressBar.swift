//
//  BudgetProgressBar.swift
//  Spendly
//
//  شريط تقدم الميزانية
//
//  يعرض:
//  - شريط ملوّن حسب نسبة الإنفاق
//  - أخضر: أقل من 70%
//  - برتقالي: من 70% إلى 99%
//  - أحمر: 100% وما فوق
//

import SwiftUI

// MARK: - BudgetProgressBar
// يُستخدم في: شاشة الميزانيات + الصفحة الرئيسية

struct BudgetProgressBar: View {
    
    // MARK: - الخصائص
    
    /// المبلغ المصروف
    let spent: Decimal
    
    /// إجمالي الميزانية
    let total: Decimal
    
    /// ارتفاع الشريط (الافتراضي 8 بكسل)
    var height: CGFloat = 8
    
    // MARK: - الحسابات
    
    /// النسبة المئوية للإنفاق (من 0 إلى 100+)
    private var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(truncating: (spent / total * 100) as NSDecimalNumber)
    }
    
    /// النسبة المحدودة بـ 100% (للعرض فقط)
    private var clampedFraction: Double {
        min(percentage / 100, 1.0)
    }
    
    /// حالة الميزانية (تحدد اللون)
    private var status: BudgetStatus {
        BudgetStatus.from(percentage: percentage)
    }
    
    // MARK: - الواجهة
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                
                // ── خلفية الشريط (الرمادية الفاتحة) ──────────
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.spTrack)
                    .frame(height: height)
                
                // ── الشريط المملوء ─────────────────────────────
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(status.color)
                    .frame(
                        width: geo.size.width * clampedFraction,
                        height: height
                    )
                    // حركة ناعمة عند تغير النسبة
                    .animation(.easeInOut(duration: 0.3), value: clampedFraction)
            }
        }
        .frame(height: height)
    }
}

// MARK: - BudgetSummaryCard
// بطاقة ملخص الميزانية الكاملة (الأيقونة + الشريط + الأرقام)
// تُستخدم في شاشة الميزانيات

struct BudgetSummaryCard: View {
    
    // MARK: - الخصائص
    
    let category: Category
    let budget: Budget
    let spent: Decimal
    
    @Environment(LocalizationManager.self) private var locManager
    
    // MARK: - الحسابات
    
    private var percentage: Double {
        guard budget.amount > 0 else { return 0 }
        return Double(truncating: (spent / budget.amount * 100) as NSDecimalNumber)
    }
    
    private var status: BudgetStatus {
        BudgetStatus.from(percentage: percentage)
    }
    
    private var remaining: Decimal {
        budget.amount - spent
    }
    
    // MARK: - الواجهة
    
    var body: some View {
        SpendlyCard {
            VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                
                // ── الصف العلوي: الأيقونة + الاسم + الـ Pill ──
                HStack {
                    CategoryIconView(icon: category.icon)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(category.localizedName(using: locManager))
                            .font(SpendlyFont.body)
                            .fontWeight(.semibold)
                        
                        // المصروف من الإجمالي
                        Text("\(amountText(spent)) / \(amountText(budget.amount))")
                            .font(SpendlyFont.caption)
                            .foregroundStyle(Color.spMuted)
                    }
                    
                    Spacer()
                    
                    // حالة الميزانية (✓ 45% مثلاً)
                    StatusPill(status: status, percentage: percentage)
                }
                
                // ── شريط التقدم ─────────────────────────────────
                BudgetProgressBar(spent: spent, total: budget.amount)
                
                // ── النص التوضيحي في الأسفل ─────────────────────
                HStack {
                    Text(statusText)
                        .font(SpendlyFont.caption)
                        .foregroundStyle(Color.spMuted)
                    
                    Spacer()
                    
                    Text("\(amountText(abs(remaining))) \(locManager.localize("home.left"))")
                        .font(SpendlyFont.caption)
                        .foregroundStyle(Color.spMuted)
                }
            }
        }
    }
    
    // MARK: - الدوال المساعدة
    
    private var statusText: String {
        switch status {
        case .ok:      return locManager.localize("budget.status.ok")
        case .warning: return locManager.localize("budget.status.warning")
        case .over:    return locManager.localize("budget.status.over")
        }
    }
    
    private func amountText(_ amount: Decimal) -> String {
        let formatted = amount.formatted(.number.precision(.fractionLength(0)))
        return "\(formatted) \(locManager.localize("general.currency"))"
    }
    
    private func abs(_ value: Decimal) -> Decimal {
        value < 0 ? -value : value
    }
}

// MARK: - StatusPill
// الـ Pill الصغير الذي يُظهر النسبة والأيقونة (مثل: ✓ 45%)

struct StatusPill: View {
    let status: BudgetStatus
    let percentage: Double
    
    var body: some View {
        HStack(spacing: 3) {
            Text(status.icon)
                .font(SpendlyFont.label)
            Text("\(Int(percentage.clamped(to: 0...999)))%")
                .font(SpendlyFont.label)
        }
        .foregroundStyle(status.color)
        .padding(.horizontal, SpendlySpacing.sm + 1)
        .padding(.vertical, SpendlySpacing.xs - 1)
        .background(status.color.opacity(0.12))
        .clipShape(Capsule())
    }
}

// MARK: - امتداد مساعد
extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

// MARK: - Preview
#Preview("شريط الميزانية") {
    VStack(spacing: 20) {
        // أخضر — ضمن الميزانية
        BudgetSummaryCard(
            category: Category(name: "الطعام", icon: "🍽️", type: .expense),
            budget: Budget(amount: 2000, period: .monthly, categoryID: UUID()),
            spent: 640
        )
        
        // برتقالي — قريب من الحد
        BudgetSummaryCard(
            category: Category(name: "التسوق", icon: "🛍️", type: .expense),
            budget: Budget(amount: 1000, period: .monthly, categoryID: UUID()),
            spent: 780
        )
        
        // أحمر — تجاوز الميزانية
        BudgetSummaryCard(
            category: Category(name: "المواصلات", icon: "🚗", type: .expense),
            budget: Budget(amount: 500, period: .monthly, categoryID: UUID()),
            spent: 650
        )
    }
    .padding()
    .background(Color.spBackground)
}
