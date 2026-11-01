//
//  TransactionsView.swift
//  Spendly
//
//  شاشة كل المعاملات
//
//  الميزات:
//  - بحث نصي في الوقت الفعلي
//  - فلتر (الكل / دخل / مصروف)
//  - تجميع المعاملات حسب التاريخ
//  - الضغط على معاملة يفتح تفاصيلها
//  - حذف المعاملة بالسحب
//

import SwiftUI

// MARK: - TransactionFilter
// خيارات الفلتر

enum TransactionFilter: String, CaseIterable {
    case all     = "all"
    case income  = "income"
    case expense = "expense"
    
    var title: String {
        switch self {
        case .all:     return "الكل"
        case .income:  return "الدخل"
        case .expense: return "المصروف"
        }
    }
}

// MARK: - TransactionsView

struct TransactionsView: View {
    
    // MARK: - الخصائص
    
    @State var viewModel: TransactionsViewModel
    
    /// قائمة الفئات (نحتاجها لعرض اسم الفئة بجانب المعاملة)
    let categories: [Category]
    
    /// حالة البحث والفلتر
    @State private var searchText   = ""
    @State private var activeFilter = TransactionFilter.all
    
    /// المعاملة المختارة (لعرض التفاصيل)
    @State private var selectedTransaction: Transaction?
    
    /// هل نافذة إضافة معاملة مفتوحة؟
    @State private var showAddSheet = false
    
    /// نوع المعاملة الجديدة
    @State private var addType: TransactionType = .expense
    
    /// Toast
    @State private var toastMessage: String?
    
    // MARK: - المعاملات المفلتَرة
    
    private var filteredTransactions: [Transaction] {
        viewModel.transactions
            .filter { tx in
                // فلتر النوع
                let typeMatch: Bool
                switch activeFilter {
                case .all:     typeMatch = true
                case .income:  typeMatch = tx.type == .income
                case .expense: typeMatch = tx.type == .expense
                }
                
                // فلتر البحث النصي
                let searchMatch: Bool
                if searchText.isEmpty {
                    searchMatch = true
                } else {
                    let note = tx.note?.lowercased() ?? ""
                    let catName = category(for: tx.categoryID)?.name.lowercased() ?? ""
                    searchMatch = note.contains(searchText.lowercased()) ||
                                  catName.contains(searchText.lowercased())
                }
                
                return typeMatch && searchMatch
            }
            .sorted { $0.date > $1.date }
    }
    
    /// تجميع المعاملات حسب التاريخ
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
        
        // إعادة البناء بالترتيب
        return groups.map { (label, _) in
            (label, seenDates[label]!)
        }
    }
    
    // MARK: - الواجهة
    
    var body: some View {
        VStack(spacing: 0) {
            
            // ── العنوان + البحث + الفلتر ──────────────────────
            headerSection
            
            // ── قائمة المعاملات ────────────────────────────────
            if filteredTransactions.isEmpty {
                emptyState
            } else {
                transactionsList
            }
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    toastMessage = nil
                }
            }
        }
        .sheet(item: $selectedTransaction) { tx in
            TransactionDetailSheet(
                transaction: tx,
                category: category(for: tx.categoryID)
            ) {
                viewModel.deleteTransaction(id: tx.id)
                toastMessage = "تم حذف المعاملة"
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    toastMessage = nil
                }
            }
        }
    }
    
    // MARK: - رأس الصفحة
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            // عنوان الصفحة
            Text("المعاملات")
                .font(SpendlyFont.largeTitle)
                .padding(.horizontal, SpendlySpacing.xl)
                .padding(.top, 8)
            
            // حقل البحث
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.spMuted)
                TextField("بحث...", text: $searchText)
                    .font(SpendlyFont.body)
            }
            .padding(SpendlySpacing.md)
            .background(Color.spCard)
            .clipShape(RoundedRectangle(cornerRadius: SpendlyShape.iconRadius))
            .padding(.horizontal, SpendlySpacing.xl)
            
            // أزرار الفلتر (Chips)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: SpendlySpacing.sm) {
                    ForEach(TransactionFilter.allCases, id: \.self) { filter in
                        FilterChip(
                            title: filter.title,
                            isSelected: activeFilter == filter
                        ) {
                            activeFilter = filter
                        }
                    }
                }
                .padding(.horizontal, SpendlySpacing.xl)
            }
        }
        .padding(.bottom, SpendlySpacing.sm)
    }
    
    // MARK: - قائمة المعاملات
    
    private var transactionsList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                ForEach(groupedTransactions, id: \.0) { (dateLabel, transactions) in
                    Section {
                        SpendlyCard(padding: 4) {
                            VStack(spacing: 0) {
                                ForEach(Array(transactions.enumerated()), id: \.element.id) { idx, tx in
                                    TransactionRow(
                                        transaction: tx,
                                        category: category(for: tx.categoryID)
                                    ) {
                                        selectedTransaction = tx
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 12)
                                    
                                    if idx < transactions.count - 1 {
                                        Divider().padding(.leading, 68)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, SpendlySpacing.xl)
                        .padding(.bottom, SpendlySpacing.sm)
                        
                    } header: {
                        Text(dateLabel)
                            .font(SpendlyFont.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.spMuted)
                            .padding(.horizontal, SpendlySpacing.xl)
                            .padding(.vertical, SpendlySpacing.sm)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.spBackground)
                    }
                }
            }
            .padding(.bottom, SpendlySpacing.xxl)
        }
    }
    
    // MARK: - حالة الفراغ
    
    private var emptyState: some View {
        Spacer()
            .frame(maxHeight: .infinity)
            .overlay {
                EmptyStateView(
                    icon: "🧾",
                    title: "لا توجد معاملات",
                    subtitle: searchText.isEmpty ? "اضغط + لإضافة أول معاملة" : "جرّب بحثًا آخر"
                )
            }
    }
    
    // MARK: - الدوال المساعدة
    
    private func category(for id: UUID?) -> Category? {
        guard let id else { return nil }
        return categories.first { $0.id == id }
    }
    
    private func dateLabel(for date: Date, calendar: Calendar) -> String {
        if calendar.isDateInToday(date)     { return "اليوم" }
        if calendar.isDateInYesterday(date) { return "أمس" }
        return date.formatted(.dateTime.weekday(.short).day().month(.abbreviated))
    }
}

// MARK: - FilterChip
// زر الفلتر الصغير

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(SpendlyFont.body)
                .padding(.horizontal, 14)
                .padding(.vertical, SpendlySpacing.sm)
                .background(isSelected ? Color.spAccent : Color.spCard)
                .foregroundStyle(isSelected ? Color.spOnAccent : Color.spForeground)
                .clipShape(Capsule())
        }
    }
}
