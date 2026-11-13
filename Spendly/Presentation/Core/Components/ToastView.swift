//
//  ToastView.swift
//  Spendly
//
//  الإشعار السريع (Toast)
//
//  يظهر لفترة قصيرة ثم يختفي تلقائياً
//  مثل: "تمت إضافة المعاملة ✓"
//

import SwiftUI

// MARK: - ToastView
// الإشعار السريع

struct ToastView: View {
    let message: String
    
    var body: some View {
        HStack(spacing: SpendlySpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.spSuccess)
            Text(message)
                .font(SpendlyFont.body)
                .fontWeight(.medium)
        }
        .foregroundStyle(Color.spBackground)  // نص أبيض على خلفية داكنة
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.vertical, SpendlySpacing.md)
        .background(Color.spForeground)
        .clipShape(RoundedRectangle(cornerRadius: SpendlyShape.toastRadius))
    }
}

// MARK: - Toast Modifier
// modifier يضيف الـ Toast على أي View

struct ToastModifier: ViewModifier {
    
    @Binding var message: String?
    
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            
            // يظهر الـ Toast فقط إذا كان هناك رسالة
            if let message {
                ToastView(message: message)
                    .padding(.top, 16)
                    .padding(.horizontal, 18)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3), value: message != nil)
    }
}

extension View {
    /// أضف الـ Toast على أي View
    func toast(message: Binding<String?>) -> some View {
        modifier(ToastModifier(message: message))
    }
}

// MARK: - SectionHeaderView
// عنوان القسم مع زر "عرض الكل"

struct SectionHeaderView: View {
    let title: String
    var showSeeAll: Bool = false
    var onSeeAll: (() -> Void)?
    
    @Environment(LocalizationManager.self) private var locManager
    
    var body: some View {
        HStack {
            Text(title)
                .font(SpendlyFont.sectionTitle)
                .foregroundStyle(Color.spForeground)
            
            Spacer()
            
            if showSeeAll {
                Button(locManager.localize("general.see_all")) {
                    onSeeAll?()
                }
                .font(SpendlyFont.body)
                .foregroundStyle(Color.spAccent)
            }
        }
    }
}

// MARK: - EmptyStateView
// شاشة فارغة (عندما لا توجد بيانات)

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: SpendlySpacing.sm) {
            Text(icon)
                .font(.system(size: 40))
            Text(title)
                .font(SpendlyFont.sectionTitle)
                .foregroundStyle(Color.spForeground)
            Text(subtitle)
                .font(SpendlyFont.body)
                .foregroundStyle(Color.spMuted)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 50)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview
#Preview {
    VStack {
        ToastView(message: "تمت إضافة المعاملة")
        
        SectionHeaderView(title: "أحدث المعاملات", showSeeAll: true)
            .padding()
        
        EmptyStateView(
            icon: "🧾",
            title: "لا توجد معاملات",
            subtitle: "جرّب بحثًا أو فلترًا آخر."
        )
    }
    .background(Color.spBackground)
}
