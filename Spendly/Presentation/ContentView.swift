//
//  ContentView.swift
//  Spendly
//
//  الشاشة الجذر — تحتوي على شريط التبويب السفلي (TabBar)
//
//  كيف يعمل:
//  1. TabView يعرض 4 شاشات: الرئيسية، المعاملات، الميزانيات، الملف الشخصي
//  2. زر (+) في المنتصف يفتح شيت إضافة معاملة
//  3. اللغة والثيم تنتقلان عبر Environment لكل الشاشات
//

import SwiftUI

// MARK: - AppTab
// تعداد التبويبات

enum AppTab: Int, CaseIterable {
    case home         = 0
    case transactions = 1
    case budgets      = 2
    case profile      = 3
    
    var locKey: String {
        switch self {
        case .home:         return "tab.home"
        case .transactions: return "tab.transactions"
        case .budgets:      return "tab.budgets"
        case .profile:      return "tab.profile"
        }
    }
    
    var icon: String {
        switch self {
        case .home:         return "house.fill"
        case .transactions: return "list.bullet"
        case .budgets:      return "chart.pie.fill"
        case .profile:      return "person.fill"
        }
    }
}

// MARK: - ContentView

struct ContentView: View {
    
    // MARK: - الخصائص
    
    let appContainer: AppContainer
    
    @Environment(LocalizationManager.self) private var locManager
    
    // MARK: - الحالة
    
    /// التبويب النشط حالياً
    @State private var selectedTab = AppTab.home
    
    /// هل نافذة إضافة معاملة مفتوحة؟
    @State private var showAddSheet = false
    
    /// وضع المظهر (فاتح / داكن / تلقائي)
    @State private var appearanceMode = AppearanceMode.system
    
    /// Toast
    @State private var toastMessage: String?
    
    // MARK: - الفئات (نحملها مرة واحدة)
    @State private var categories: [Category] = []
    
    // MARK: - الواجهة
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            // ── محتوى التبويبات ────────────────────────────
            TabView(selection: $selectedTab) {
                
                // ── الرئيسية ─────────────────────────────
                NavigationStack {
                    HomeView(
                        viewModel: HomeViewModel(
                            fetchTransactionsUseCase: appContainer.fetchTransactionsUseCase,
                            fetchBudgetsUseCase: appContainer.fetchBudgetsUseCase,
                            fetchCategoriesUseCase: appContainer.fetchCategoriesUseCase
                        )
                    )
                }
                .tag(AppTab.home)
                .tabItem {
                    Label(locManager.localize(AppTab.home.locKey), systemImage: AppTab.home.icon)
                }
                
                // ── المعاملات ────────────────────────────
                NavigationStack {
                    TransactionsView(
                        viewModel: appContainer.transactionsViewModel,
                        categories: categories
                    )
                }
                .tag(AppTab.transactions)
                .tabItem {
                    Label(locManager.localize(AppTab.transactions.locKey), systemImage: AppTab.transactions.icon)
                }
                
                // ── الميزانيات ───────────────────────────
                NavigationStack {
                    BudgetsView(
                        budgetsViewModel: appContainer.budgetsViewModel,
                        transactionsViewModel: appContainer.transactionsViewModel,
                        categories: categories
                    )
                }
                .tag(AppTab.budgets)
                .tabItem {
                    Label(locManager.localize(AppTab.budgets.locKey), systemImage: AppTab.budgets.icon)
                }
                
                // ── الملف الشخصي ─────────────────────────
                NavigationStack {
                    ProfileView(colorScheme: $appearanceMode)
                }
                .tag(AppTab.profile)
                .tabItem {
                    Label(locManager.localize(AppTab.profile.locKey), systemImage: AppTab.profile.icon)
                }
            }
            .tint(Color.spAccent)  // لون التبويب النشط
            
            // ── زر + في المنتصف ────────────────────────────
            // يطفو فوق شريط التبويب
            addButton
        }
        .preferredColorScheme(appearanceMode.colorScheme)  // تطبيق الثيم
        .toast(message: $toastMessage)
        .task {
            // جلب الفئات مرة واحدة عند البداية
            categories = (try? appContainer.fetchCategoriesUseCase.execute()) ?? []
        }
        .sheet(isPresented: $showAddSheet) {
            AddTransactionSheet(
                viewModel: appContainer.transactionsViewModel,
                categories: categories
            ) { message in
                toastMessage = message
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    toastMessage = nil
                }
            }
        }
    }
    
    // MARK: - زر الإضافة
    
    private var addButton: some View {
        Button {
            showAddSheet = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.spOnAccent)
                .frame(width: 52, height: 52)
                .background(Color.spAccent)
                .clipShape(Circle())
                .shadow(color: Color.spAccent.opacity(0.4), radius: 8, x: 0, y: 4)
        }
        // ارفع الزر قليلاً فوق شريط التبويب
        .offset(y: -28)
        .ignoresSafeArea(.keyboard)
    }
}
