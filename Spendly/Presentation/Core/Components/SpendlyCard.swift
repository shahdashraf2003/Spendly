//
//  SpendlyCard.swift
//  Spendly
//
//  المكوّن الأساسي: البطاقة البيضاء المستديرة
//
//  كيف تستخدمه:
//  SpendlyCard {
//      Text("محتوى البطاقة")
//  }
//
//  أو بمحاذاة مخصصة:
//  SpendlyCard(padding: 0) {
//      // محتوى بدون padding
//  }
//

import SwiftUI

// MARK: - SpendlyCard
// البطاقة الرئيسية في التطبيق
// تُستخدم في كل الشاشات لتغليف المحتوى

struct SpendlyCard<Content: View>: View {
    
    // MARK: - الخصائص
    
    /// المحتوى الداخلي (أي View تضعها داخل البطاقة)
    let content: Content
    
    /// المسافة الداخلية (Padding) — الافتراضي 16
    var padding: CGFloat
    
    /// هل البطاقة لها ظل؟
    var hasShadow: Bool
    
    // MARK: - التهيئة
    
    init(
        padding: CGFloat = SpendlySpacing.lg,
        hasShadow: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.hasShadow = hasShadow
        self.content = content()
    }
    
    // MARK: - الواجهة
    
    var body: some View {
        content
            .padding(padding)
            .background(Color.spCard)               // خلفية البطاقة
            .clipShape(RoundedRectangle(cornerRadius: SpendlyShape.cardRadius))  // زوايا مستديرة
            .shadow(
                color: hasShadow ? .black.opacity(0.05) : .clear,
                radius: 3,
                x: 0,
                y: 1
            )
    }
}

// MARK: - Preview
#Preview("بطاقة عادية") {
    SpendlyCard {
        VStack(alignment: .leading, spacing: 8) {
            Text("عنوان البطاقة")
                .font(SpendlyFont.sectionTitle)
            Text("نص توضيحي داخل البطاقة")
                .font(SpendlyFont.body)
                .foregroundStyle(Color.spMuted)
        }
    }
    .padding()
    .background(Color.spBackground)
}
