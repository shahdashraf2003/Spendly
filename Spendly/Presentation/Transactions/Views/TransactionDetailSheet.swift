//
//  TransactionDetailSheet.swift
//  Spendly


import SwiftUI

struct TransactionDetailSheet: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(LocalizationManager.self) private var locManager

    let transaction: Transaction
    let category: Category?
    let onDelete: () -> Void

    @State private var showDeleteAlert = false



    var body: some View {
        NavigationStack {
            VStack(spacing: SpendlySpacing.xl) {


                heroSection


                detailsCard
                    .padding(.horizontal, SpendlySpacing.xl)

                Spacer()


                SpendlyButton(locManager.localize("transactions.delete_button"), style: .destructive) {
                    showDeleteAlert = true
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

            .alert(locManager.localize("transactions.delete_confirm.title"), isPresented: $showDeleteAlert) {
                Button(locManager.localize("transactions.delete_confirm.confirm"), role: .destructive) {
                    onDelete()
                    dismiss()
                }
                Button(locManager.localize("general.cancel"), role: .cancel) {}
            } message: {
                Text(locManager.localize("transactions.delete_confirm.message"))
            }
        }
        .layoutDirection(for: locManager)
    }



    private var heroSection: some View {
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
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, SpendlySpacing.lg)
    }


    private var detailsCard: some View {
        SpendlyCard {
            VStack(spacing: 0) {
                TransactionDetailRow(
                    label: locManager.localize("add_transaction.category_label"),
                    value: category?.localizedName(using: locManager) ?? "—"
                )

                Divider()

                TransactionDetailRow(
                    label: locManager.localize("add_transaction.date_label"),
                    value: transaction.date.formatted(.dateTime.day().month(.wide).year())
                )

                if let note = transaction.note, !note.isEmpty {
                    Divider()
                    TransactionDetailRow(
                        label: locManager.localize("add_transaction.note_placeholder"),
                        value: note
                    )
                }
            }
        }
    }

    private var signedAmount: String {
        let sign = transaction.type == .income ? "+" : "−"
        let formatted = transaction.amount.formatted(.number.precision(.fractionLength(0)))
        return "\(sign)\(formatted) \(locManager.localize("general.currency"))"
    }
}
