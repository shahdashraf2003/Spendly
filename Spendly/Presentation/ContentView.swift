//
//  ContentView.swift
//  Spendly
//

import SwiftUI


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

    
    let appContainer: AppContainer
    
    @Environment(LocalizationManager.self) private var locManager

    @State private var selectedTab = AppTab.home
    @State private var showAddSheet = false
    @State private var appearanceMode = AppearanceMode.system
    @State private var toastMessage: String?
    @State private var categories: [Category] = []
    

    var body: some View {
        ZStack(alignment: .bottom) {

            TabView(selection: $selectedTab) {

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
                

                NavigationStack {
                    ProfileView(colorScheme: $appearanceMode)
                }
                .tag(AppTab.profile)
                .tabItem {
                    Label(locManager.localize(AppTab.profile.locKey), systemImage: AppTab.profile.icon)
                }
            }
            .tint(Color.spAccent)

            addButton
        }
        .preferredColorScheme(appearanceMode.colorScheme)
        .toast(message: $toastMessage)
        .task {
            loadCategories()
        }
        .sheet(isPresented: $showAddSheet) {
            AddTransactionSheet(
                viewModel: appContainer.transactionsViewModel,
                categories: categories.isEmpty ? ((try? appContainer.fetchCategoriesUseCase.execute()) ?? []) : categories
            ) { message in
                toastMessage = message
                loadCategories()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    toastMessage = nil
                }
            }
            .environment(locManager)
            .layoutDirection(for: locManager)
        }
    }
    
    private func loadCategories() {
        categories = (try? appContainer.fetchCategoriesUseCase.execute()) ?? []
    }

    private var addButton: some View {
        Button {
            loadCategories()
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

        .offset(y: -28)
        .ignoresSafeArea(.keyboard)
    }
}
