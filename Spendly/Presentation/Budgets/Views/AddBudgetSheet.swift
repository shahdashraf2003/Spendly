//
//  AddBudgetSheet.swift
//  Spendly
//
//  شيت إضافة ميزانية جديدة
//
//  يحتوي على:
//  - حقل المبلغ الكبير مع رمز العملة
//  - اختيار الفئة (expense فقط) بشكل Chips
//  - Segmented picker لفترة الميزانية (أسبوعية / شهرية / سنوية)
//  - زر الحفظ مع التحقق من الصحة
//  - رسائل خطأ واضحة
//

import SwiftUI

// MARK: - AddBudgetSheet

struct AddBudgetSheet: View {

    // MARK: - الخصائص

    @Environment(\.dismiss) private var dismiss
    @Environment(LocalizationManager.self) private var locManager

    @State var viewModel: AddBudgetViewModel
    var onSuccess: (String) -> Void

    // MARK: - الواجهة

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SpendlySpacing.xl) {

                    // ── المبلغ ────────────────────────────────────
                    amountSection

                    // ── الفئة ─────────────────────────────────────
                    categorySection

                    // ── فترة الميزانية ────────────────────────────
                    periodSection

                    // ── رسالة الخطأ العامة ─────────────────────────
                    if let error = viewModel.errorMessage {
                        Text("⚠ \(locManager.localize(error))")
                            .font(SpendlyFont.caption)
                            .foregroundStyle(Color.spDanger)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // ── زر الحفظ ──────────────────────────────────
                    SpendlyButton(locManager.localize("general.save"), isLoading: viewModel.isLoading) {
                        viewModel.saveBudget()
                    }
                    .padding(.top, SpendlySpacing.sm)
                }
                .padding(SpendlySpacing.xl)
            }
            .background(Color.spBackground)
            .navigationTitle(locManager.localize("add_budget.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(locManager.localize("general.close")) { dismiss() }
                        .foregroundStyle(Color.spAccent)
                }
            }
            .task {
                viewModel.loadCategories()
            }
            .onChange(of: viewModel.didSaveSuccessfully) { _, saved in
                if saved {
                    dismiss()
                    onSuccess(locManager.localize("add_budget.added"))
                }
            }
        }
        .layoutDirection(for: locManager)
    }

    // MARK: - حقل المبلغ

    @ViewBuilder
    private var amountSection: some View {
        @Bindable var vm = viewModel

        VStack(spacing: SpendlySpacing.xs) {
            HStack(spacing: SpendlySpacing.sm) {
                Text(locManager.localize("general.currency"))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.spMuted)

                TextField("0.00", text: $vm.amountText)
                    .font(.system(size: 46, weight: .bold, design: .rounded))
                    .keyboardType(.decimalPad)
                    .environment(\.layoutDirection, .leftToRight)
                    .foregroundStyle(viewModel.amountError ? Color.spDanger : Color.spForeground)
                    .onChange(of: vm.amountText) { _, newValue in
                        // Allow digits and a single decimal point only
                        vm.amountText = newValue.filter { $0.isNumber || $0 == "." }
                        let dots = vm.amountText.filter { $0 == "." }.count
                        if dots > 1, let lastDot = vm.amountText.lastIndex(of: ".") {
                            vm.amountText.remove(at: lastDot)
                        }
                    }
            }
            .frame(maxWidth: .infinity)

            if viewModel.amountError {
                Label(locManager.localize("add_budget.amount_error"), systemImage: "exclamationmark.triangle.fill")
                    .font(SpendlyFont.caption)
                    .foregroundStyle(Color.spDanger)
            }

            Rectangle()
                .frame(height: 1)
                .foregroundStyle(viewModel.amountError ? Color.spDanger : Color.spSeparator)
                .padding(.top, SpendlySpacing.xs)
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
    }

    // MARK: - قسم الفئة

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            Text(locManager.localize("add_budget.category_label"))
                .font(SpendlyFont.caption)
                .foregroundStyle(Color.spMuted)

            if viewModel.expenseCategories.isEmpty && !viewModel.isLoading {
                Text(locManager.localize("general.empty_categories"))
                    .font(SpendlyFont.body)
                    .foregroundStyle(Color.spMuted)
                    .padding(.vertical, SpendlySpacing.xs)
            } else {
                FlowLayout(spacing: SpendlySpacing.sm) {
                    ForEach(viewModel.expenseCategories) { category in
                        CategoryChip(
                            category: category,
                            isSelected: viewModel.selectedCategory?.id == category.id
                        ) {
                            viewModel.selectedCategory = category
                        }
                    }
                }
            }

            if viewModel.categoryError {
                Text("⚠ \(locManager.localize("add_budget.category_error"))")
                    .font(SpendlyFont.caption)
                    .foregroundStyle(Color.spDanger)
            }
        }
    }

    // MARK: - قسم الفترة

    @ViewBuilder
    private var periodSection: some View {
        @Bindable var vm = viewModel

        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            Text(locManager.localize("add_budget.period_label"))
                .font(SpendlyFont.caption)
                .foregroundStyle(Color.spMuted)

            Picker("", selection: $vm.selectedPeriod) {
                Text(locManager.localize("add_budget.period.weekly")).tag(BudgetPeriod.weekly)
                Text(locManager.localize("add_budget.period.monthly")).tag(BudgetPeriod.monthly)
                Text(locManager.localize("add_budget.period.yearly")).tag(BudgetPeriod.yearly)
            }
            .pickerStyle(.segmented)
        }
    }
}
