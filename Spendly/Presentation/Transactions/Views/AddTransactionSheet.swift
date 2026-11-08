//
//  AddTransactionSheet.swift
//  Spendly
//
//  شيت إضافة معاملة جديدة
//
//  يحتوي على:
//  - مفتاح التبديل بين مصروف/دخل
//  - حقل المبلغ الكبير
//  - اختيار الفئة (Chips)
//  - حقل الملاحظة
//  - زر الحفظ
//

import SwiftUI

// MARK: - AddTransactionSheet

struct AddTransactionSheet: View {
    
    // MARK: - الخصائص
    
    @Environment(\.dismiss) private var dismiss
    @Environment(LocalizationManager.self) private var locManager
    
    @State var viewModel: TransactionsViewModel
    let categories: [Category]
    var initialType: TransactionType
    var onSuccess: (String) -> Void
    
    // MARK: - حالة النموذج
    
    @State private var type: TransactionType
    @State private var amountText  = ""
    @State private var selectedCategory: Category?
    @State private var note        = ""
    @State private var date        = Date()
    
    // MARK: - أخطاء التحقق
    
    @State private var amountError   = false
    @State private var categoryError = false
    
    // MARK: - التهيئة
    
    init(
        viewModel: TransactionsViewModel,
        categories: [Category],
        initialType: TransactionType = .expense,
        onSuccess: @escaping (String) -> Void
    ) {
        self.viewModel = viewModel
        self.categories = categories
        self.initialType = initialType
        self.onSuccess = onSuccess
        _type = State(initialValue: initialType)
    }
    
    // MARK: - الفئات المتاحة حسب النوع
    
    private var availableCategories: [Category] {
        categories.filter { $0.type == (type == .expense ? .expense : .income) }
    }
    
    // MARK: - الواجهة
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SpendlySpacing.xl) {
                    
                    // ── مفتاح التبديل مصروف/دخل ──────────────
                    typeSegment
                    
                    // ── حقل المبلغ ───────────────────────────
                    VStack(spacing: SpendlySpacing.xs) {
                        AmountTextField(
                            text: $amountText,
                            hasError: amountError,
                            errorMessage: "⚠ \(locManager.localize("add_transaction.amount_error"))"
                        )
                        .padding(.vertical, SpendlySpacing.sm)
                    }
                    
                    // ── اختيار الفئة ─────────────────────────
                    VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                        Text(locManager.localize("add_transaction.category_label"))
                            .font(SpendlyFont.caption)
                            .foregroundStyle(Color.spMuted)
                        
                        // Chips الفئات
                        FlowLayout(spacing: SpendlySpacing.sm) {
                            ForEach(availableCategories) { cat in
                                CategoryChip(
                                    category: cat,
                                    isSelected: selectedCategory?.id == cat.id
                                ) {
                                    selectedCategory = cat
                                    categoryError = false
                                }
                            }
                        }
                        
                        // رسالة الخطأ
                        if categoryError {
                            Text("⚠ \(locManager.localize("add_transaction.category_error"))")
                                .font(SpendlyFont.caption)
                                .foregroundStyle(Color.spDanger)
                        }
                    }
                    
                    // ── حقل الملاحظة ─────────────────────────
                    VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                        Text(locManager.localize("add_transaction.note_placeholder"))
                            .font(SpendlyFont.caption)
                            .foregroundStyle(Color.spMuted)
                        
                        TextField(locManager.localize("add_transaction.note_placeholder"), text: $note)
                            .font(SpendlyFont.bodyLarge)
                            .padding(SpendlySpacing.md)
                            .background(Color.spCard)
                            .clipShape(RoundedRectangle(cornerRadius: SpendlyShape.iconRadius))
                    }
                    
                    // ── التاريخ ──────────────────────────────
                    VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                        Text(locManager.localize("add_transaction.date_label"))
                            .font(SpendlyFont.caption)
                            .foregroundStyle(Color.spMuted)
                        
                        DatePicker("", selection: $date, displayedComponents: .date)
                            .labelsHidden()
                            .padding(SpendlySpacing.sm)
                            .background(Color.spCard)
                            .clipShape(RoundedRectangle(cornerRadius: SpendlyShape.iconRadius))
                    }
                    
                    // ── زر الحفظ ─────────────────────────────
                    SpendlyButton(locManager.localize("add_transaction.title")) {
                        saveTransaction()
                    }
                    .padding(.top, SpendlySpacing.sm)
                }
                .padding(SpendlySpacing.xl)
            }
            .background(Color.spBackground)
            .navigationTitle(locManager.localize("add_transaction.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(locManager.localize("general.close")) { dismiss() }
                        .foregroundStyle(Color.spAccent)
                }
            }
        }
    }
    
    // MARK: - مفتاح التبديل
    
    private var typeSegment: some View {
        HStack(spacing: 3) {
            ForEach([TransactionType.expense, TransactionType.income], id: \.self) { t in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        type = t
                        selectedCategory = nil
                    }
                } label: {
                    Text(t == .expense ? locManager.localize("add_transaction.type.expense") : locManager.localize("add_transaction.type.income"))
                        .font(SpendlyFont.body)
                        .fontWeight(type == t ? .semibold : .regular)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                        .background(type == t ? Color.spCard : Color.clear)
                        .foregroundStyle(type == t ? Color.spForeground : Color.spMuted)
                        .clipShape(RoundedRectangle(cornerRadius: 9))
                }
            }
        }
        .padding(3)
        .background(Color.spTrack)
        .clipShape(RoundedRectangle(cornerRadius: 11))
    }
    
    // MARK: - حفظ المعاملة
    
    private func saveTransaction() {
        // التحقق من صحة البيانات
        amountError   = !(Decimal(string: amountText) ?? 0 > 0)
        categoryError = (type == .expense && selectedCategory == nil)
        
        guard !amountError && !categoryError else { return }
        
        // إنشاء المعاملة
        let transaction = Transaction(
            amount: Decimal(string: amountText) ?? 0,
            type: type,
            date: date,
            note: note.isEmpty ? nil : note,
            categoryID: selectedCategory?.id
        )
        
        // الحفظ عبر ViewModel
        viewModel.addTransaction(transaction)
        
        dismiss()
        onSuccess(locManager.localize("transactions.added") + " ✓")
    }
}

// MARK: - CategoryChip
// زر اختيار الفئة

struct CategoryChip: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void
    
    @Environment(LocalizationManager.self) private var locManager
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: SpendlySpacing.xs) {
                Text(category.icon)
                Text(category.localizedName(using: locManager))
                    .font(SpendlyFont.body)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, SpendlySpacing.sm)
            .background(isSelected ? Color.spAccent : Color.spCard)
            .foregroundStyle(isSelected ? Color.spOnAccent : Color.spForeground)
            .clipShape(Capsule())
        }
    }
}

// MARK: - FlowLayout
// تخطيط متدفق للـ Chips (تنتقل للسطر التالي عند الامتلاء)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.reduce(0) { $0 + ($1.first?.sizeThatFits(.unspecified).height ?? 0) } +
                     CGFloat(max(0, rows.count - 1)) * spacing
        return CGSize(width: proposal.width ?? 0, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            let rowHeight = row.first?.sizeThatFits(.unspecified).height ?? 0
            for subview in row {
                let size = subview.sizeThatFits(.unspecified)
                subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
                x += size.width + spacing
            }
            y += rowHeight + spacing
        }
    }
    
    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [[LayoutSubview]] {
        var rows: [[LayoutSubview]] = [[]]
        var currentWidth: CGFloat = 0
        let maxWidth = proposal.width ?? .infinity
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentWidth + size.width > maxWidth && !rows.last!.isEmpty {
                rows.append([subview])
                currentWidth = size.width + spacing
            } else {
                rows[rows.count - 1].append(subview)
                currentWidth += size.width + spacing
            }
        }
        return rows
    }
}

// MARK: - TransactionDetailSheet
// تفاصيل معاملة موجودة (للعرض والحذف)

struct TransactionDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LocalizationManager.self) private var locManager
    
    let transaction: Transaction
    let category: Category?
    let onDelete: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: SpendlySpacing.xl) {
                
                // ── الأيقونة والمبلغ ───────────────────────────
                VStack(spacing: SpendlySpacing.sm) {
                    CategoryIconView(icon: category?.icon ?? "💸", size: 60)
                    
                    Text(signedAmount)
                        .font(SpendlyFont.displayLarge)
                        .foregroundStyle(
                            transaction.type == .income ? Color.spSuccess : Color.spForeground
                        )
                    
                    Text(transaction.note ?? category?.localizedName(using: locManager) ?? locManager.localize("general.transaction"))
                        .font(SpendlyFont.body)
                        .foregroundStyle(Color.spMuted)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, SpendlySpacing.lg)
                
                // ── التفاصيل ─────────────────────────────────
                SpendlyCard {
                    VStack(spacing: 0) {
                        detailRow(label: locManager.localize("add_transaction.category_label"), value: category?.localizedName(using: locManager) ?? "—")
                        Divider()
                        detailRow(
                            label: locManager.localize("add_transaction.date_label"),
                            value: transaction.date.formatted(.dateTime.day().month(.wide).year())
                        )
                        if let note = transaction.note, !note.isEmpty {
                            Divider()
                            detailRow(label: locManager.localize("add_transaction.note_placeholder"), value: note)
                        }
                    }
                }
                .padding(.horizontal, SpendlySpacing.xl)
                
                Spacer()
                
                // ── زر الحذف ─────────────────────────────────
                SpendlyButton(locManager.localize("transactions.delete_button"), style: .destructive) {
                    onDelete()
                    dismiss()
                }
                .padding(.horizontal, SpendlySpacing.xl)
                .padding(.bottom, SpendlySpacing.xxl)
            }
            .background(Color.spBackground)
            .navigationTitle(locManager.localize("transactions.detail_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(locManager.localize("general.close")) { dismiss() }
                        .foregroundStyle(Color.spAccent)
                }
            }
        }
    }
    
    private var signedAmount: String {
        let sign = transaction.type == .income ? "+" : "−"
        let formatted = transaction.amount.formatted(.number.precision(.fractionLength(0)))
        return "\(sign)\(formatted) \(locManager.localize("general.currency"))"
    }
    
    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(SpendlyFont.body)
                .foregroundStyle(Color.spMuted)
            Spacer()
            Text(value)
                .font(SpendlyFont.body)
                .fontWeight(.semibold)
        }
        .padding(.vertical, SpendlySpacing.md)
    }
}
