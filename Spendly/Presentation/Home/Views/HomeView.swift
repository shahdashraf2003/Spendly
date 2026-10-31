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
        // ── Sheet إضافة معاملة ───────────────────────────────────
        .sheet(isPresented: $showAddTransaction) {
            Text("شيت إضافة معاملة — سيأتي في الخطوة القادمة")
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
                Text("صباح الخير، عمر 👋")
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
                Text("الرصيد الإجمالي")
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
                        Text("↓ الدخل")
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
                        Text("↑ المصروفات")
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
                        Text("الصافي")
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
            QuickActionButton(icon: "➖", title: "مصروف") {
                addTransactionType = .expense
                showAddTransaction = true
            }
            QuickActionButton(icon: "➕", title: "دخل") {
                addTransactionType = .income
                showAddTransaction = true
            }
            QuickActionButton(icon: "📊", title: "التحليلات") {
                // TODO: فتح شاشة التحليلات
            }
        }
    }
    
    // MARK: - نظرة على الإنفاق
    
    private var spendingOverviewSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            Text("نظرة على الإنفاق")
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
                        + Text(" من \(formatAmount(viewModel.totalBudget))")
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
                    Text("\(formatAmount(viewModel.totalBudget - viewModel.totalExpenses)) متبقي")
                        .font(SpendlyFont.caption)
                        .foregroundStyle(Color.spMuted)
                }
            }
        }
    }
    
    // MARK: - الإنفاق حسب الفئة
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            Text("الإنفاق حسب الفئة")
                .font(SpendlyFont.sectionTitle)
            
            SpendlyCard {
                VStack(spacing: SpendlySpacing.sm) {
                    ForEach(viewModel.categories.filter { $0.type == .expense }) { cat in
                        let amount = viewModel.spent(for: cat.id)
                        HStack {
                            Text(cat.icon)
                                .frame(width: 24)
                            Text(cat.name)
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
                        Text("لا توجد فئات بعد")
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
                title: "أحدث المعاملات",
                showSeeAll: !viewModel.recentTransactions.isEmpty
            )
            
            if viewModel.recentTransactions.isEmpty {
                SpendlyCard {
                    EmptyStateView(
                        icon: "🧾",
                        title: "لا توجد معاملات",
                        subtitle: "اضغط + لإضافة أول معاملة"
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
        return "\(formatted) ج.م"
    }
    
    /// تنسيق المبلغ مع الإشارة (+ أو -)
    private func formatSigned(_ amount: Decimal) -> String {
        let sign = amount >= 0 ? "+" : "−"
        let abs = amount < 0 ? -amount : amount
        let formatted = abs.formatted(.number.precision(.fractionLength(0)))
        return "\(sign)\(formatted) ج.م"
    }
}


