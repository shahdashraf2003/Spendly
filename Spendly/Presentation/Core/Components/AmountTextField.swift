//
//  AmountTextField.swift
//  Spendly
//
//  حقل إدخال المبلغ — مخصص للأرقام الكبيرة
//
//  مميزاته:
//  - خط كبير وعريض (46pt)
//  - لوحة مفاتيح عشرية (decimal)
//  - يُعرض في منتصف الشاشة
//  - يقبل فقط الأرقام والنقطة العشرية
//

import SwiftUI

// MARK: - AmountTextField
// حقل إدخال المبلغ

struct AmountTextField: View {
    
    // MARK: - الخصائص
    
    /// النص المُدخَل (مربوط مع ViewModel)
    @Binding var text: String
    
    /// هل يوجد خطأ؟ (يُظهر الحقل باللون الأحمر)
    var hasError: Bool = false
    
    /// رسالة الخطأ
    var errorMessage: String = ""
    
    // MARK: - الواجهة
    
    var body: some View {
        VStack(spacing: SpendlySpacing.xs) {
            
            // ── حقل الإدخال ───────────────────────────────────
            TextField("0", text: $text)
                .font(.system(size: 46, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .keyboardType(.decimalPad)              // لوحة مفاتيح عشرية
                .environment(\.layoutDirection, .leftToRight)  // الأرقام دائماً LTR
                .foregroundStyle(hasError ? Color.spDanger : Color.spForeground)
                .onChange(of: text) { _, newValue in
                    // فلتر: اقبل فقط الأرقام والنقطة
                    text = newValue.filter { $0.isNumber || $0 == "." }
                    // امنع أكثر من نقطة واحدة
                    let dots = text.filter { $0 == "." }.count
                    if dots > 1, let lastDot = text.lastIndex(of: ".") {
                        text.remove(at: lastDot)
                    }
                }
            
            // ── رسالة الخطأ ──────────────────────────────────
            if hasError && !errorMessage.isEmpty {
                Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                    .font(SpendlyFont.caption)
                    .foregroundStyle(Color.spDanger)
            }
        }
    }
}

// MARK: - Preview
#Preview("حقل المبلغ") {
    VStack(spacing: 30) {
        AmountTextField(text: .constant("1250"))
        AmountTextField(text: .constant(""), hasError: true, errorMessage: "أدخل مبلغًا صحيحًا")
    }
    .padding()
    .background(Color.spBackground)
}
