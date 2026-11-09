//
//  BudgetsView.swift
//  Spendly
//
//  شاشة الميزانيات
//
//  تعرض:
//  - ملخص إجمالي (ميزانية كلية / مصروف / متبقي)
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

    @Environment(LocalizationManager.self) private var locManager
    
    // MARK: - الحسابات
    
    /// إجمالي كل الميزانيات
    private var totalBudget: Decimal {
        budgetsViewModel.budgets.reduce(0) { $0 + $1.amount }
    }
    
    /// إجمالي المصروف الفعلي عبر كل الميزانيات
    private var totalSpent: Decimal {
        budgetsViewModel.budgets.reduce(Decimal(0)) { sum, budget in
            sum + spentForCategory(budget.categoryID)
        }
    }
    
    /// المتبقي
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
                
                // ── البطاقة الإجمالية ─────────────────────────
                summaryCard
                    .padding(.horizontal, SpendlySpacing.xl)
                    .padding(.top, 16)
                
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
    
    // MARK: - قائمة الميزانيات
    
    private var budgetsList: some View {
        VStack(spacing: SpendlySpacing.sm) {
            if budgetsViewModel.budgets.isEmpty {
                SpendlyCard {
                    EmptyStateView(
                        icon: "💰",
                        title: locManager.localize("budgets.empty.title"),
                        subtitle: locManager.localize("budgets.empty.subtitle")
                    )
                }
                .padding(.horizontal, SpendlySpacing.xl)
            } else {
                ForEach(budgetsViewModel.budgets) { budget in
                    if let cat = category(for: budget.categoryID) {
                        BudgetSummaryCard(
                            category: cat,
                            budget: budget,
                            spent: spentForCategory(budget.categoryID)
                        )
                        .padding(.horizontal, SpendlySpacing.xl)
                    }
                }
            }
        }
    }
    
    // MARK: - الدوال المساعدة
    
    private func category(for id: UUID) -> Category? {
        categories.first { $0.id == id }
    }
    
    private func spentForCategory(_ categoryID: UUID) -> Decimal {
        transactionsViewModel.transactions
            .filter { $0.type == .expense && $0.categoryID == categoryID }
            .reduce(0) { $0 + $1.amount }
    }
    
    private func formatAmount(_ amount: Decimal) -> String {
        let abs = amount < 0 ? -amount : amount
        return "\(abs.formatted(.number.precision(.fractionLength(0)))) \(locManager.localize("general.currency"))"
    }
}
