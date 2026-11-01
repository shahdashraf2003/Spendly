//
//  SpendlyButton.swift
//  Spendly
//
//  أزرار التطبيق المعيارية
//
//  الأنواع المتاحة:
//  - primary: زر برتقالي كبير (للإجراءات الرئيسية)
//  - secondary: زر شفاف بإطار (للإجراءات الثانوية)
//  - destructive: زر أحمر (للحذف)
//

import SwiftUI

// MARK: - SpendlyButtonStyle
// أنماط الأزرار

enum SpendlyButtonStyle {
    case primary      // برتقالي
    case secondary    // شفاف بإطار
    case destructive  // أحمر
}

// MARK: - SpendlyButton
// الزر القياسي للتطبيق

struct SpendlyButton: View {
    
    // MARK: - الخصائص
    
    let title: String
    let style: SpendlyButtonStyle
    var isLoading: Bool
    let action: () -> Void
    
    // MARK: - التهيئة
    
    init(
        _ title: String,
        style: SpendlyButtonStyle = .primary,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.isLoading = isLoading
        self.action = action
    }
    
    // MARK: - الألوان حسب النمط
    
    private var backgroundColor: Color {
        switch style {
        case .primary:     return .spAccent
        case .secondary:   return .clear
        case .destructive: return .spDanger
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary:     return .spOnAccent
        case .secondary:   return .spAccent
        case .destructive: return .white
        }
    }
    
    private var strokeColor: Color {
        switch style {
        case .secondary: return .spAccent
        default:         return .clear
        }
    }
    
    // MARK: - الواجهة
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: SpendlySpacing.sm) {
                if isLoading {
                    ProgressView()
                        .tint(foregroundColor)
                        .scaleEffect(0.8)
                }
                Text(title)
                    .font(SpendlyFont.bodyLarge)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(backgroundColor)
            .foregroundStyle(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: SpendlyShape.buttonRadius))
            .overlay(
                RoundedRectangle(cornerRadius: SpendlyShape.buttonRadius)
                    .strokeBorder(strokeColor, lineWidth: 1.5)
            )
        }
        .disabled(isLoading)
    }
}

// MARK: - QuickActionButton
// أزرار الإجراءات السريعة في الصفحة الرئيسية (شبكة 3 أزرار)

struct QuickActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: SpendlySpacing.xs) {
                Text(icon)
                    .font(.system(size: 22))
                Text(title)
                    .font(SpendlyFont.label)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, SpendlySpacing.md)
            .background(Color.spCard)
            .foregroundStyle(Color.spForeground)
            .clipShape(RoundedRectangle(cornerRadius: SpendlyShape.buttonRadius))
        }
    }
}

// MARK: - Preview
#Preview("الأزرار") {
    VStack(spacing: 12) {
        SpendlyButton("إضافة معاملة") {}
        SpendlyButton("إلغاء", style: .secondary) {}
        SpendlyButton("حذف", style: .destructive) {}
        SpendlyButton("جاري الحفظ...", isLoading: true) {}
        
        HStack {
            QuickActionButton(icon: "➖", title: "إضافة\nمصروف") {}
            QuickActionButton(icon: "➕", title: "إضافة\nدخل") {}
            QuickActionButton(icon: "📊", title: "التحليلات") {}
        }
    }
    .padding()
    .background(Color.spBackground)
}
