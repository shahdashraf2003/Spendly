//
//  BudgetsView.swift
//  Spendly
//
//  شاشة الميزانيات
//
//  تعرض:
//  - فلتر الفترة الزمنية (أسبوعي / شهري / سنوي)
//  - ملخص إجمالي (ميزانية كلية / مصروف / متبقي) للفترة المختارة
//  - بطاقة لكل ميزانية مع شريط التقدم
//  - زر إضافة ميزانية جديدة
//

import SwiftUI

// MARK: - BudgetsView

struct BudgetsView: View {

    // MARK: - الخصائص

    @State var budgetsViewModel: BudgetsViewModel
    @State var transactionsViewModel: TransactionsViewModel
    let categories: [Category]
    let appContainer: AppContainer

    @State private var showAddBudget = false
    @State private var toastMessage: String?

    /// الفترة الزمنية المختارة للفلترة — شهري افتراضياً
    @State private var selectedPeriod: BudgetPeriod = .monthly

    /// Budget pending confirmation before deletion
    @State private var budgetToDelete: Budget?

    @Environment(LocalizationManager.self) private var locManager
    @Environment(SettingsManager.self) private var settingsManager

    // MARK: - الميزانيات المفلترة

    /// الميزانيات المطابقة للفترة المختارة فقط
    private var filteredBudgets: [Budget] {
        budgetsViewModel.budgets.filter { $0.period == selectedPeriod }
    }

    // MARK: - الحسابات (على الميزانيات المفلترة فقط)

    private var totalBudget: Decimal {
        filteredBudgets.reduce(0) { $0 + $1.amount }
    }

    private var totalSpent: Decimal {
        filteredBudgets.reduce(Decimal(0)) { sum, budget in
            sum + spentForCategory(budget.categoryID)
        }
    }

    private var totalRemaining: Decimal {
        totalBudget - totalSpent
    }

    // MARK: - الواجهة

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {

                // ── عنوان الصفحة ─────────────────────────────
                Text(locManager.localize("budgets.title"))
                    .font(SpendlyFont.largeTitle)
                    .padding(.horizontal, SpendlySpacing.xl)
                    .padding(.top, 8)

                // ── فلتر الفترة ───────────────────────────────
                periodPicker
                    .padding(.horizontal, SpendlySpacing.xl)
                    .padding(.top, SpendlySpacing.lg)

                // ── البطاقة الإجمالية ─────────────────────────
                summaryCard
                    .padding(.horizontal, SpendlySpacing.xl)
                    .padding(.top, SpendlySpacing.md)

                // ── قائمة الميزانيات ──────────────────────────
                budgetsList
                    .padding(.top, SpendlySpacing.xl)

                // ── زر إضافة ميزانية ─────────────────────────
                SpendlyButton("＋ \(locManager.localize("budgets.add"))") {
                    showAddBudget = true
                }
                .padding(.horizontal, SpendlySpacing.xl)
                .padding(.top, SpendlySpacing.sm)
                .padding(.bottom, SpendlySpacing.xxl)
            }
        }
        .background(Color.spBackground)
        .task { budgetsViewModel.loadBudgets() }
        .toast(message: $toastMessage)
        .sheet(isPresented: $showAddBudget) {
            AddBudgetSheet(viewModel: appContainer.makeAddBudgetViewModel()) { message in
                toastMessage = message
                budgetsViewModel.loadBudgets()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    toastMessage = nil
                }
            }
            .environment(locManager)
            .environment(settingsManager)
        }
        // Delete confirmation alert
        .alert(locManager.localize("budget.delete.title"), isPresented: Binding(
            get: { budgetToDelete != nil },
            set: { if !$0 { budgetToDelete = nil } }
        )) {
            Button(locManager.localize("budget.delete.confirm"), role: .destructive) {
                if let budget = budgetToDelete {
                    budgetsViewModel.deleteBudget(id: budget.id)
                    budgetToDelete = nil
                    toastMessage = locManager.localize("budget.delete.success")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        toastMessage = nil
                    }
                }
            }
            Button(locManager.localize("general.cancel"), role: .cancel) {
                budgetToDelete = nil
            }
        } message: {
            if let budget = budgetToDelete,
               let cat = category(for: budget.categoryID) {
                Text(locManager.localize("budget.delete.message", args: cat.localizedName(using: locManager)))
            }
        }
    }

    // MARK: - فلتر الفترة الزمنية

    private var periodPicker: some View {
        HStack(spacing: 3) {
            ForEach([BudgetPeriod.weekly, .monthly, .yearly], id: \.self) { period in
                Button {
                    selectedPeriod = period
                } label: {
                    Text(periodLabel(period))
                        .font(SpendlyFont.body)
                        .fontWeight(selectedPeriod == period ? .semibold : .regular)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                        .background(selectedPeriod == period ? Color.spCard : Color.clear)
                        .foregroundStyle(selectedPeriod == period ? Color.spForeground : Color.spMuted)
                        .clipShape(RoundedRectangle(cornerRadius: 9))
                }
            }
        }
        .padding(3)
        .background(Color.spTrack)
        .clipShape(RoundedRectangle(cornerRadius: 11))
    }

    private func periodLabel(_ period: BudgetPeriod) -> String {
        switch period {
        case .weekly:  return locManager.localize("add_budget.period.weekly")
        case .monthly: return locManager.localize("add_budget.period.monthly")
        case .yearly:  return locManager.localize("add_budget.period.yearly")
        }
    }

    // MARK: - البطاقة الإجمالية

    private var summaryCard: some View {
        SpendlyCard {
            HStack {
                summaryItem(label: locManager.localize("budgets.total"), value: totalBudget, color: .spForeground)
                Spacer()
                summaryItem(label: locManager.localize("budgets.spent"), value: totalSpent, color: .spForeground)
                Spacer()
                summaryItem(label: locManager.localize("budgets.remaining"), value: totalRemaining, color: .spSuccess)
            }
        }
    }

    private func summaryItem(label: String, value: Decimal, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(SpendlyFont.caption)
                .foregroundStyle(Color.spMuted)
            Text(formatAmount(value))
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(color)
        }
    }

    // MARK: - قائمة الميزانيات (مفلترة)

    private var budgetsList: some View {
        VStack(spacing: SpendlySpacing.sm) {
            if filteredBudgets.isEmpty {
                SpendlyCard {
                    EmptyStateView(
                        icon: "💰",
                        title: locManager.localize("budgets.empty.title"),
                        subtitle: locManager.localize("budgets.empty.subtitle")
                    )
                }
                .padding(.horizontal, SpendlySpacing.xl)
            } else {
                ForEach(filteredBudgets) { budget in
                    if let cat = category(for: budget.categoryID) {
                        BudgetSummaryCard(
                            category: cat,
                            budget: budget,
                            spent: spentForCategory(budget.categoryID)
                        )
                        .padding(.horizontal, SpendlySpacing.xl)
                        // Long-press context menu to delete (swipeActions requires List)
                        .contextMenu {
                            Button(role: .destructive) {
                                budgetToDelete = budget
                            } label: {
                                Label(locManager.localize("budget.delete.confirm"), systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - الدوال المساعدة

    private func category(for id: UUID) -> Category? {
        categories.first { $0.id == id }
    }

    /// بداية نافذة الوقت للفترة المختارة (بداية الأسبوع / الشهر / السنة الحالية)
    private func windowStart(for period: BudgetPeriod) -> Date {
        let calendar = Calendar.current
        let now = Date()
        switch period {
        case .weekly:  return calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        case .monthly: return calendar.dateInterval(of: .month, for: now)?.start ?? now
        case .yearly:  return calendar.dateInterval(of: .year, for: now)?.start ?? now
        }
    }

    /// المصروف الفعلي لفئة معينة ضمن نافذة الوقت للفترة المختارة
    private func spentForCategory(_ categoryID: UUID) -> Decimal {
        let start = windowStart(for: selectedPeriod)
        return transactionsViewModel.transactions
            .filter {
                $0.type == .expense &&
                $0.categoryID == categoryID &&
                $0.date >= start
            }
            .reduce(0) { $0 + $1.amount }
    }

    private func formatAmount(_ amount: Decimal) -> String {
        let abs = amount < 0 ? -amount : amount
        return "\(abs.formatted(.number.precision(.fractionLength(0)))) \(settingsManager.currencySymbol(using: locManager))"
    }
}
