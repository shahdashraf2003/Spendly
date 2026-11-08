//
//  HomeView.swift
//  Spendly
//
//  الشاشة الرئيسية لتطبيق Spendly
//
//  تحتوي على:
//  1. رأس الصفحة (التحية + الشهر الحالي)
//  2. بطاقة الرصيد الكلي
//  3. أزرار الإجراءات السريعة
//  4. بطاقة نظرة على الإنفاق (مع شريط تقدم)
//  5. الإنفاق حسب الفئة
//  6. آخر المعاملات
//

import SwiftUI

// MARK: - HomeView

struct HomeView: View {
    
    // MARK: - الخصائص
    
    /// ViewModel الخاص بالشاشة الرئيسية
    @State var viewModel: HomeViewModel
    
    @Environment(LocalizationManager.self) private var locManager
    
    /// هل نافذة إضافة معاملة مفتوحة؟
    @State private var showAddTransaction = false
    
    /// نوع المعاملة عند الإضافة (مصروف أو دخل)
    @State private var addTransactionType: TransactionType = .expense
    
    /// الـ Toast — الإشعار السريع
    @State private var toastMessage: String?
    
    // MARK: - الواجهة الرئيسية
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                
                // ── رأس الصفحة ───────────────────────────────────
                headerSection
                    .padding(.horizontal, SpendlySpacing.xl)
                    .padding(.top, 8)
                
                // ── بطاقة الرصيد ─────────────────────────────────
                balanceCard
                    .padding(.horizontal, SpendlySpacing.xl)
                    .padding(.top, 16)
                
                // ── الإجراءات السريعة ─────────────────────────────
                quickActionsSection
                    .padding(.horizontal, SpendlySpacing.xl)
                    .padding(.top, 14)
                
                // ── نظرة على الإنفاق ─────────────────────────────
                spendingOverviewSection
                    .padding(.horizontal, SpendlySpacing.xl)
                    .padding(.top, 22)
                
                // ── الإنفاق حسب الفئة ────────────────────────────
                categoriesSection
                    .padding(.horizontal, SpendlySpacing.xl)
                    .padding(.top, 22)
                
                // ── آخر المعاملات ────────────────────────────────
                recentTransactionsSection
                    .padding(.horizontal, SpendlySpacing.xl)
                    .padding(.top, 22)
                    .padding(.bottom, SpendlySpacing.xxl)
            }
        }
        .background(Color.spBackground)
        .toast(message: $toastMessage)  // إشعار Toast في الأعلى
        .task {
            viewModel.loadData()
        }
        .sheet(isPresented: $showAddTransaction) {
            Text(locManager.localize("general.coming_soon"))
                .padding()
        }
    }
    
    // MARK: - رأس الصفحة
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                // الشهر والسنة
                Text(Date().formatted(.dateTime.month(.wide).year()))
                    .font(SpendlyFont.caption)
                    .foregroundStyle(Color.spMuted)
                
                // التحية
                Text(locManager.localize("home.greeting"))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.spForeground)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                // أيقونة الإشعارات
                Button {
                    // TODO: فتح الإشعارات
                } label: {
                    Image(systemName: "bell")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.spForeground)
                }
                
                // صورة المستخدم
                Circle()
                    .fill(Color.spAccentSurface)
                    .frame(width: 38, height: 38)
                    .overlay(Text("👤").font(.system(size: 18)))
            }
        }
    }
    
    // MARK: - بطاقة الرصيد الكلي
    
    private var balanceCard: some View {
        SpendlyCard {
            VStack(alignment: .leading, spacing: 0) {
                
                // ── الرصيد الكلي ─────────────────────────────────
                Text(locManager.localize("home.balance"))
                    .font(SpendlyFont.caption)
                    .foregroundStyle(Color.spMuted)
                
                Text(formatAmount(viewModel.netBalance))
                    .font(SpendlyFont.displayLarge)
                    .foregroundStyle(Color.spForeground)
                    .padding(.top, 2)
                
                // ── ملخص الدخل والمصروفات ─────────────────────
                HStack(spacing: 0) {
                    // الدخل ↓
                    VStack(alignment: .leading, spacing: 2) {
                        Text("↓ \(locManager.localize("home.income"))")
                            .font(SpendlyFont.caption)
                            .foregroundStyle(Color.spMuted)
                        Text(formatAmount(viewModel.totalIncome))
                            .font(SpendlyFont.body)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.spSuccess)
                    }
                    
                    Spacer()
                    
                    // المصروفات ↑
                    VStack(alignment: .leading, spacing: 2) {
                        Text("↑ \(locManager.localize("home.expenses"))")
                            .font(SpendlyFont.caption)
                            .foregroundStyle(Color.spMuted)
                        Text(formatAmount(viewModel.totalExpenses))
                            .font(SpendlyFont.body)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.spForeground)
                    }
                    
                    Spacer()
                    
                    // الصافي
                    VStack(alignment: .leading, spacing: 2) {
                        Text(locManager.localize("home.net"))
                            .font(SpendlyFont.caption)
                            .foregroundStyle(Color.spMuted)
                        let net = viewModel.totalIncome - viewModel.totalExpenses
                        Text(formatSigned(net))
                            .font(SpendlyFont.body)
                            .fontWeight(.bold)
                            .foregroundStyle(net >= 0 ? Color.spSuccess : Color.spDanger)
                    }
                }
                .padding(.top, 12)
            }
        }
    }
    
    // MARK: - الإجراءات السريعة
    
    private var quickActionsSection: some View {
        HStack(spacing: 10) {
            QuickActionButton(icon: "➖", title: locManager.localize("add_transaction.type.expense")) {
                addTransactionType = .expense
                showAddTransaction = true
            }
            QuickActionButton(icon: "➕", title: locManager.localize("add_transaction.type.income")) {
                addTransactionType = .income
                showAddTransaction = true
            }
            QuickActionButton(icon: "📊", title: locManager.localize("home.analytics")) {
                // TODO: فتح شاشة التحليلات
            }
        }
    }
    
    // MARK: - نظرة على الإنفاق
    
    private var spendingOverviewSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            Text(locManager.localize("home.spending_overview"))
                .font(SpendlyFont.sectionTitle)
            
            let pct = viewModel.overallSpendingPercentage
            let status = BudgetStatus.from(percentage: pct)
            
            SpendlyCard {
                VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                    
                    // المصروف من الإجمالي
                    HStack {
                        Text(formatAmount(viewModel.totalExpenses))
                            .font(SpendlyFont.body)
                            .fontWeight(.bold)
                        + Text(" \(locManager.localize("home.of")) \(formatAmount(viewModel.totalBudget))")
                            .font(SpendlyFont.body)
                            .foregroundStyle(Color.spMuted)
                        
                        Spacer()
                        
                        // الـ Pill
                        StatusPill(status: status, percentage: pct)
                    }
                    
                    // شريط التقدم
                    BudgetProgressBar(
                        spent: viewModel.totalExpenses,
                        total: viewModel.totalBudget > 0 ? viewModel.totalBudget : 1
                    )
                    
                    // المتبقي
                    Text("\(formatAmount(viewModel.totalBudget - viewModel.totalExpenses)) \(locManager.localize("home.left"))")
                        .font(SpendlyFont.caption)
                        .foregroundStyle(Color.spMuted)
                }
            }
        }
    }
    
    // MARK: - الإنفاق حسب الفئة
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            Text(locManager.localize("home.categories_breakdown"))
                .font(SpendlyFont.sectionTitle)
            
            SpendlyCard {
                VStack(spacing: SpendlySpacing.sm) {
                    ForEach(viewModel.categories.filter { $0.type == .expense }) { cat in
                        let amount = viewModel.spent(for: cat.id)
                        HStack {
                            Text(cat.icon)
                                .frame(width: 24)
                            Text(cat.localizedName(using: locManager))
                                .font(SpendlyFont.body)
                                .foregroundStyle(Color.spForeground)
                            Spacer()
                            Text(formatAmount(amount))
                                .font(SpendlyFont.body)
                                .fontWeight(.bold)
                        }
                    }
                    
                    // إذا لم توجد فئات
                    if viewModel.categories.isEmpty {
                        Text(locManager.localize("general.empty_categories"))
                            .font(SpendlyFont.body)
                            .foregroundStyle(Color.spMuted)
                    }
                }
            }
        }
    }
    
    // MARK: - آخر المعاملات
    
    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            SectionHeaderView(
                title: locManager.localize("home.recent_transactions"),
                showSeeAll: !viewModel.recentTransactions.isEmpty
            )
            
            if viewModel.recentTransactions.isEmpty {
                SpendlyCard {
                    EmptyStateView(
                        icon: "🧾",
                        title: locManager.localize("transactions.empty.title"),
                        subtitle: locManager.localize("transactions.empty.subtitle")
                    )
                }
            } else {
                SpendlyCard(padding: 4) {
                    VStack(spacing: 0) {
                        ForEach(Array(viewModel.recentTransactions.enumerated()), id: \.element.id) { index, tx in
                            TransactionRow(
                                transaction: tx,
                                category: viewModel.category(for: tx.categoryID)
                            )
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12)
                            
                            // فاصل بين الصفوف (ليس بعد الأخير)
                            if index < viewModel.recentTransactions.count - 1 {
                                Divider()
                                    .padding(.leading, 68)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - الدوال المساعدة
    
    /// تنسيق المبلغ بالجنيه المصري
    private func formatAmount(_ amount: Decimal) -> String {
        let abs = amount < 0 ? -amount : amount
        let formatted = abs.formatted(.number.precision(.fractionLength(0)))
        return "\(formatted) \(locManager.localize("general.currency"))"
    }
    
    /// تنسيق المبلغ مع الإشارة (+ أو -)
    private func formatSigned(_ amount: Decimal) -> String {
        let sign = amount >= 0 ? "+" : "−"
        let abs = amount < 0 ? -amount : amount
        let formatted = abs.formatted(.number.precision(.fractionLength(0)))
        return "\(sign)\(formatted) \(locManager.localize("general.currency"))"
    }
}


