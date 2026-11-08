//
//  HomeViewModel.swift
//  Spendly
//
//  ViewModel الشاشة الرئيسية
//
//  مسؤوليته:
//  - جلب الملخص المالي (الرصيد، الدخل، المصروفات)
//  - جلب آخر المعاملات
//  - جلب حالة كل ميزانية
//
//  ملاحظة: يستخدم نفس الـ UseCases الموجودة في AppContainer
//

import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    
    // MARK: - الاعتماديات (Use Cases)
    
    private let fetchTransactionsUseCase: FetchTransactionsUseCase
    private let fetchBudgetsUseCase: FetchBudgetsUseCase
    private let fetchCategoriesUseCase: FetchCategoriesUseCase
    
    // MARK: - البيانات المعروضة
    
    /// آخر 4 معاملات (للصفحة الرئيسية)
    private(set) var recentTransactions: [Transaction] = []
    
    /// كل الميزانيات
    private(set) var budgets: [Budget] = []
    
    /// كل الفئات
    private(set) var categories: [Category] = []
    
    /// هل البيانات قيد التحميل؟
    private(set) var isLoading = false
    
    /// رسالة الخطأ (إن وُجدت)
    private(set) var errorMessage: String?
    
    // MARK: - القيم المحسوبة (Computed Properties)
    
    /// إجمالي الدخل
    var totalIncome: Decimal {
        recentTransactions
            .filter { $0.type == .income }
            .reduce(0) { $0 + $1.amount }
    }
    
    /// إجمالي المصروفات
    var totalExpenses: Decimal {
        recentTransactions
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
    }
    
    /// الرصيد الصافي
    var netBalance: Decimal {
        totalIncome - totalExpenses
    }
    
    /// نسبة الإنفاق الكلي (من الميزانية الكلية)
    var overallSpendingPercentage: Double {
        let totalBudget = budgets.reduce(Decimal(0)) { $0 + $1.amount }
        guard totalBudget > 0 else { return 0 }
        return Double(truncating: (totalExpenses / totalBudget * 100) as NSDecimalNumber)
    }
    
    /// إجمالي الميزانية
    var totalBudget: Decimal {
        budgets.reduce(0) { $0 + $1.amount }
    }
    
    // MARK: - التهيئة
    
    init(
        fetchTransactionsUseCase: FetchTransactionsUseCase,
        fetchBudgetsUseCase: FetchBudgetsUseCase,
        fetchCategoriesUseCase: FetchCategoriesUseCase
    ) {
        self.fetchTransactionsUseCase = fetchTransactionsUseCase
        self.fetchBudgetsUseCase = fetchBudgetsUseCase
        self.fetchCategoriesUseCase = fetchCategoriesUseCase
    }
    
    // MARK: - الدوال
    
    /// احمِل كل البيانات عند فتح الشاشة
    func loadData() {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            // جلب آخر 4 معاملات مرتبة بالتاريخ
            let allTransactions = try fetchTransactionsUseCase.execute()
            recentTransactions = Array(
                allTransactions
                    .sorted { $0.date > $1.date }
                    .prefix(4)
            )
            
            // جلب الميزانيات والفئات
            budgets    = try fetchBudgetsUseCase.execute()
            categories = try fetchCategoriesUseCase.execute()
            
        } catch {
            errorMessage = "Couldn't load data. Please try again."
        }
    }
    
    /// ابحث عن الفئة بمعرّفها
    func category(for id: UUID?) -> Category? {
        guard let id else { return nil }
        return categories.first { $0.id == id }
    }
    
    /// احسب المصروف لفئة معينة
    func spent(for categoryID: UUID) -> Decimal {
        recentTransactions
            .filter { $0.type == .expense && $0.categoryID == categoryID }
            .reduce(0) { $0 + $1.amount }
    }
}
