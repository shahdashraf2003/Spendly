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
    @State private var amountText = ""
    @State private var selectedCategory: Category?
    @State private var note = ""
    @State private var date = Date()

    // MARK: - أخطاء التحقق

    @State private var amountError = false
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



    private var availableCategories: [Category] {
        categories.filter { $0.type == (type == .expense ? .expense : .income) }
    }

    // MARK: - الواجهة

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SpendlySpacing.xl) {

                    typeSegment

                   \
                    AmountTextField(
                        text: $amountText,
                        hasError: amountError,
                        errorMessage: "⚠ \(locManager.localize("add_transaction.amount_error"))"
                    )
                    .padding(.vertical, SpendlySpacing.sm)


                    categorySection


                    TransactionFormField(label: locManager.localize("add_transaction.note_placeholder")) {
                        TextField(locManager.localize("add_transaction.note_placeholder"), text: $note)
                            .font(SpendlyFont.bodyLarge)
                            .environment(\.layoutDirection, locManager.language.layoutDirection)
                            .padding(SpendlySpacing.md)
                            .background(Color.spCard)
                            .clipShape(RoundedRectangle(cornerRadius: SpendlyShape.iconRadius))
                    }


                    TransactionFormField(label: locManager.localize("add_transaction.date_label")) {
                        DatePicker("", selection: $date, displayedComponents: .date)
                            .labelsHidden()
                            .padding(SpendlySpacing.sm)
                            .background(Color.spCard)
                            .clipShape(RoundedRectangle(cornerRadius: SpendlyShape.iconRadius))
                    }


                    SpendlyButton(locManager.localize("general.save")) {
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
        .layoutDirection(for: locManager)
    }



    private var categorySection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            Text(locManager.localize("add_transaction.category_label"))
                .font(SpendlyFont.caption)
                .foregroundStyle(Color.spMuted)
                .frame(maxWidth: .infinity, alignment: .leading)

            if availableCategories.isEmpty {
                Text(locManager.localize("general.empty_categories"))
                    .font(SpendlyFont.body)
                    .foregroundStyle(Color.spMuted)
                    .padding(.vertical, SpendlySpacing.xs)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
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
            }


            if categoryError {
                Text("⚠ \(locManager.localize("add_transaction.category_error"))")
                    .font(SpendlyFont.caption)
                    .foregroundStyle(Color.spDanger)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }


    private var typeSegment: some View {
        HStack(spacing: 3) {
            ForEach([TransactionType.expense, TransactionType.income], id: \.self) { t in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        type = t
                        selectedCategory = nil
                    }
                } label: {
                    Text(t == .expense
                         ? locManager.localize("add_transaction.type.expense")
                         : locManager.localize("add_transaction.type.income"))
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

   
    private func saveTransaction() {
        amountError = !(Decimal(string: amountText) ?? 0 > 0)
        categoryError = (type == .expense && selectedCategory == nil)

        guard !amountError && !categoryError else { return }

        let transaction = Transaction(
            amount: Decimal(string: amountText) ?? 0,
            type: type,
            date: date,
            note: note.isEmpty ? nil : note,
            categoryID: selectedCategory?.id
        )

        viewModel.addTransaction(transaction)
        dismiss()
        onSuccess(locManager.localize("transactions.added") + " ✓")
    }
}
