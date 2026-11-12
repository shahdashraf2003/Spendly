//
//  HomeView.swift
//  Spendly
//
//  Home screen for the Spendly app.
//
//  Sections:
//  1. Header (greeting + notification bell + avatar)
//  2. Balance card
//  3. Quick actions (Add Expense, Add Income, Analytics)
//  4. Spending overview (progress bar vs. budget)
//  5. Spending by category
//  6. Recent transactions (with See All)
//

import SwiftUI

// MARK: - HomeView

struct HomeView: View {

    // MARK: - Properties

    @State var viewModel: HomeViewModel

    /// Shared TransactionsViewModel — needed for the add-transaction sheet
    @State var transactionsViewModel: TransactionsViewModel

    /// All available categories (provided by ContentView)
    let categories: [Category]

    /// Called when the user taps "See All" in recent transactions → switch to Transactions tab
    var onSeeAll: () -> Void

    /// Called when the user taps the notification bell or avatar → switch to Profile tab
    var onOpenProfile: () -> Void

    @Environment(LocalizationManager.self) private var locManager
    @Environment(SettingsManager.self) private var settingsManager

    // MARK: - Local State

    @State private var showAddTransaction = false
    @State private var addTransactionType: TransactionType = .expense
    @State private var showAnalytics = false
    @State private var toastMessage: String?

    /// Stored user name (shared with ProfileView via AppStorage)
    @AppStorage("spendly_user_name") private var userName = ""

    // MARK: - Body

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {

                headerSection
                    .padding(.horizontal, SpendlySpacing.xl)
                    .padding(.top, 8)

                balanceCard
                    .padding(.horizontal, SpendlySpacing.xl)
                    .padding(.top, 16)

                quickActionsSection
                    .padding(.horizontal, SpendlySpacing.xl)
                    .padding(.top, 14)

                spendingOverviewSection
                    .padding(.horizontal, SpendlySpacing.xl)
                    .padding(.top, 22)

                categoriesSection
                    .padding(.horizontal, SpendlySpacing.xl)
                    .padding(.top, 22)

                recentTransactionsSection
                    .padding(.horizontal, SpendlySpacing.xl)
                    .padding(.top, 22)
                    .padding(.bottom, SpendlySpacing.xxl)
            }
        }
        .background(Color.spBackground)
        .toast(message: $toastMessage)
        .task {
            viewModel.loadData()
            settingsManager.checkBudgetAlerts(
                budgets: viewModel.budgets,
                transactions: viewModel.allTransactions,
                categories: viewModel.categories,
                locManager: locManager
            )
        }
        // Add Expense / Add Income sheet
        .sheet(isPresented: $showAddTransaction) {
            AddTransactionSheet(
                viewModel: transactionsViewModel,
                categories: categories,
                initialType: addTransactionType
            ) { message in
                toastMessage = message
                viewModel.loadData()
                settingsManager.checkBudgetAlerts(
                    budgets: viewModel.budgets,
                    transactions: viewModel.allTransactions,
                    categories: viewModel.categories,
                    locManager: locManager
                )
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    toastMessage = nil
                }
            }
            .environment(locManager)
            .environment(settingsManager)
            .layoutDirection(for: locManager)
        }
        // Analytics push navigation
        .navigationDestination(isPresented: $showAnalytics) {
            AnalyticsView(
                transactions: viewModel.allTransactions,
                categories: viewModel.categories
            )
            .environment(locManager)
            .environment(settingsManager)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(Date().formatted(.dateTime.month(.wide).year()))
                    .font(SpendlyFont.caption)
                    .foregroundStyle(Color.spMuted)

                Text(greetingText)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.spForeground)
            }

            Spacer()

            HStack(spacing: 12) {
                // Notification bell → opens Profile tab
                Button {
                    onOpenProfile()
                } label: {
                    Image(systemName: "bell")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.spForeground)
                }

                // Avatar → opens Profile tab, shows initials when name is set
                Button {
                    onOpenProfile()
                } label: {
                    Circle()
                        .fill(Color.spAccentSurface)
                        .frame(width: 38, height: 38)
                        .overlay(avatarContent)
                }
            }
        }
    }

    /// "Good morning, Omar" or just "Good morning!" when no name is set
    private var greetingText: String {
        let prefix = locManager.localize("home.greeting_prefix")
        return userName.isEmpty ? prefix : "\(prefix) \(userName)"
    }

    /// Shows first initial of the name, or the person emoji when no name is stored
    @ViewBuilder
    private var avatarContent: some View {
        if let initial = userName.first {
            Text(String(initial).uppercased())
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color.spAccent)
        } else {
            Text("👤")
                .font(.system(size: 18))
        }
    }

    // MARK: - Balance Card

    private var balanceCard: some View {
        SpendlyCard {
            VStack(alignment: .leading, spacing: 0) {

                Text(locManager.localize("home.balance"))
                    .font(SpendlyFont.caption)
                    .foregroundStyle(Color.spMuted)

                Text(formatAmount(viewModel.netBalance))
                    .font(SpendlyFont.displayLarge)
                    .foregroundStyle(Color.spForeground)
                    .padding(.top, 2)

                HStack(spacing: 0) {
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

    // MARK: - Quick Actions

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
                showAnalytics = true
            }
        }
    }

    // MARK: - Spending Overview

    private var spendingOverviewSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            Text(locManager.localize("home.spending_overview"))
                .font(SpendlyFont.sectionTitle)

            let pct = viewModel.overallSpendingPercentage
            let status = BudgetStatus.from(percentage: pct)

            SpendlyCard {
                VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                    HStack {
                        Text(formatAmount(viewModel.totalExpenses))
                            .font(SpendlyFont.body)
                            .fontWeight(.bold)
                        + Text(" \(locManager.localize("home.of")) \(formatAmount(viewModel.totalBudget))")
                            .font(SpendlyFont.body)
                            .foregroundStyle(Color.spMuted)

                        Spacer()

                        StatusPill(status: status, percentage: pct)
                    }

                    BudgetProgressBar(
                        spent: viewModel.totalExpenses,
                        total: viewModel.totalBudget > 0 ? viewModel.totalBudget : 1
                    )

                    Text("\(formatAmount(viewModel.totalBudget - viewModel.totalExpenses)) \(locManager.localize("home.left"))")
                        .font(SpendlyFont.caption)
                        .foregroundStyle(Color.spMuted)
                }
            }
        }
    }

    // MARK: - Categories Breakdown

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

                    if viewModel.categories.isEmpty {
                        Text(locManager.localize("general.empty_categories"))
                            .font(SpendlyFont.body)
                            .foregroundStyle(Color.spMuted)
                    }
                }
            }
        }
    }

    // MARK: - Recent Transactions

    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            SectionHeaderView(
                title: locManager.localize("home.recent_transactions"),
                showSeeAll: !viewModel.recentTransactions.isEmpty,
                onSeeAll: onSeeAll
            )

            if viewModel.recentTransactions.isEmpty {
                SpendlyCard {
                    EmptyStateView(
                        icon: "🧾",
                        title: locManager.localize("transactions.empty.title"),
                        subtitle: locManager.localize("transactions.empty.no_transactions")
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

    // MARK: - Helpers

    private func formatAmount(_ amount: Decimal) -> String {
        let abs = amount < 0 ? -amount : amount
        let formatted = abs.formatted(.number.precision(.fractionLength(0)))
        return "\(formatted) \(settingsManager.currencySymbol(using: locManager))"
    }

    private func formatSigned(_ amount: Decimal) -> String {
        let sign = amount >= 0 ? "+" : "−"
        let abs = amount < 0 ? -amount : amount
        let formatted = abs.formatted(.number.precision(.fractionLength(0)))
        return "\(sign)\(formatted) \(settingsManager.currencySymbol(using: locManager))"
    }
}
