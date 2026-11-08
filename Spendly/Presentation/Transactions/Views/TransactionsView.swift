//
//  TransactionsView.swift
//  Spendly
//
//  شاشة المعاملات — عرض + بحث + فلتر
//

import SwiftUI

// MARK: - TransactionFilter

enum TransactionFilter: String, CaseIterable {
    case all     = "all"
    case income  = "income"
    case expense = "expense"

    var locKey: String {
        switch self {
        case .all:     return "transactions.filter.all"
        case .income:  return "transactions.filter.income"
        case .expense: return "transactions.filter.expense"
        }
    }
}

// MARK: - TransactionsView

struct TransactionsView: View {


    @State var viewModel: TransactionsViewModel
    @Environment(LocalizationManager.self) private var locManager


    let categories: [Category]


    @State private var searchText = ""
    @State private var activeFilter = TransactionFilter.all
    @State private var selectedTransaction: Transaction?
    @State private var showAddSheet = false
    @State private var addType: TransactionType = .expense
    @State private var toastMessage: String?



    private var filteredTransactions: [Transaction] {
        viewModel.transactions
            .filter { tx in

                let typeMatch: Bool = switch activeFilter {
                case .all:     true
                case .income:  tx.type == .income
                case .expense: tx.type == .expense
                }


                let searchMatch: Bool
                if searchText.isEmpty {
                    searchMatch = true
                } else {
                    let note    = tx.note?.lowercased() ?? ""
                    let catName = category(for: tx.categoryID)?.name.lowercased() ?? ""
                    searchMatch = note.contains(searchText.lowercased())
                                  || catName.contains(searchText.lowercased())
                }

                return typeMatch && searchMatch
            }
            .sorted { $0.date > $1.date }
    }


    private var groupedTransactions: [(String, [Transaction])] {
        let calendar = Calendar.current
        var groups: [(String, [Transaction])] = []
        var seenDates: [String: [Transaction]] = [:]

        for tx in filteredTransactions {
            let label = dateLabel(for: tx.date, calendar: calendar)
            if seenDates[label] == nil {
                seenDates[label] = []
                groups.append((label, []))
            }
            seenDates[label]!.append(tx)
        }

        return groups.map { (label, _) in (label, seenDates[label]!) }
    }



    var body: some View {
        VStack(spacing: 0) {
            headerSection
            listOrEmptyState
        }
        .background(Color.spBackground)
        .toast(message: $toastMessage)
        .task { viewModel.loadTransactions() }

        .sheet(isPresented: $showAddSheet) {
            AddTransactionSheet(
                viewModel: viewModel,
                categories: categories,
                initialType: addType
            ) { message in
                toastMessage = message
                clearToast()
            }
            .environment(locManager)
            .layoutDirection(for: locManager)
        }

        .sheet(item: $selectedTransaction) { tx in
            TransactionDetailSheet(
                transaction: tx,
                category: category(for: tx.categoryID)
            ) {
                viewModel.deleteTransaction(id: tx.id)
                toastMessage = locManager.localize("transactions.deleted")
                clearToast()
            }
            .environment(locManager)
            .layoutDirection(for: locManager)
        }
    }


    private var headerSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            Text(locManager.localize("transactions.title"))
                .font(SpendlyFont.largeTitle)
                .padding(.horizontal, SpendlySpacing.xl)
                .padding(.top, 8)

            if !viewModel.transactions.isEmpty {
                searchBar
                filterBar
            }
        }
        .padding(.bottom, SpendlySpacing.sm)
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.spMuted)
            TextField(locManager.localize("transactions.search"), text: $searchText)
                .font(SpendlyFont.body)
        }
        .padding(SpendlySpacing.md)
        .background(Color.spCard)
        .clipShape(RoundedRectangle(cornerRadius: SpendlyShape.iconRadius))
        .padding(.horizontal, SpendlySpacing.xl)
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: SpendlySpacing.sm) {
                ForEach(TransactionFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: locManager.localize(filter.locKey),
                        isSelected: activeFilter == filter
                    ) {
                        activeFilter = filter
                    }
                }
            }
            .padding(.horizontal, SpendlySpacing.xl)
        }
    }

    @ViewBuilder
    private var listOrEmptyState: some View {
        if filteredTransactions.isEmpty {
            VStack {
                Spacer()
                EmptyStateView(
                    icon: "🧾",
                    title: locManager.localize("transactions.empty.title"),
                    subtitle: viewModel.transactions.isEmpty
                        ? locManager.localize("transactions.empty.no_transactions")
                        : locManager.localize("transactions.empty.subtitle")
                )
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            transactionsList
        }
    }



    private var transactionsList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                ForEach(groupedTransactions, id: \.0) { (label, txs) in
                    Section {
                        transactionGroup(txs)
                            .padding(.horizontal, SpendlySpacing.xl)
                            .padding(.bottom, SpendlySpacing.sm)
                    } header: {
                        dateSectionHeader(label)
                    }
                }
            }
            .padding(.bottom, SpendlySpacing.xxl)
        }
    }

    private func transactionGroup(_ txs: [Transaction]) -> some View {
        SpendlyCard(padding: 4) {
            VStack(spacing: 0) {
                ForEach(Array(txs.enumerated()), id: \.element.id) { idx, tx in
                    TransactionRow(
                        transaction: tx,
                        category: category(for: tx.categoryID)
                    ) {
                        selectedTransaction = tx
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)

                    if idx < txs.count - 1 {
                        Divider().padding(.leading, 68)
                    }
                }
            }
        }
    }

    private func dateSectionHeader(_ label: String) -> some View {
        Text(label)
            .font(SpendlyFont.caption)
            .fontWeight(.semibold)
            .foregroundStyle(Color.spMuted)
            .padding(.horizontal, SpendlySpacing.xl)
            .padding(.vertical, SpendlySpacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.spBackground)
    }

    // MARK: - Helpers

    private func category(for id: UUID?) -> Category? {
        guard let id else { return nil }
        return categories.first { $0.id == id }
    }

    private func dateLabel(for date: Date, calendar: Calendar) -> String {
        if calendar.isDateInToday(date)     { return locManager.localize("transactions.today") }
        if calendar.isDateInYesterday(date) { return locManager.localize("transactions.yesterday") }
        return date.formatted(.dateTime.weekday(.short).day().month(.abbreviated))
    }


    private func clearToast() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            toastMessage = nil
        }
    }
}
