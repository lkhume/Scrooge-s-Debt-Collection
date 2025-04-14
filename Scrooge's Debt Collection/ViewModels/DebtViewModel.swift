//
//  DebtViewModel.swift
//  Scrooge's Debt Collection
//
//  Created by Ke Han Luo on 2025-04-13.
//

import Foundation


class DebtViewModel : ObservableObject {
    @Published var debts : [Debt] = []
    @Published var borrowers : [Borrower] = []
    
    private let saveKey = "storedDebts"
    
    init() {
        loadDebts()
    }
    
    func addDebt(_ debt : Debt) -> Void  {
        debts.append(debt)
    }
    
    func removeDebt(_ debt : Debt) {
        debts.removeAll(where: {$0.id == debt.id})
    }
    
    func removeBorrower(_ borrower : Borrower) {
        borrowers.removeAll(where: {$0.id == borrower.id})
    }
    
    func setPaid(_ debt : Debt) {
        guard let index = debts.firstIndex(where: { $0.id == debt.id }) else {
            return
        }
        debts[index].isPaid = true
    }
    
    func debts(forMonth month: Date) -> [Debt] {
        let calendar = Calendar.current
        return debts.filter { calendar.isDate($0.date, equalTo: month, toGranularity: .month)}
    }
    
    func saveDebts() {
        if let encoded = try? JSONEncoder().encode(debts) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    func loadDebts() {
        if let savedData = UserDefaults.standard.data(forKey: saveKey) {
            if let decodedDebts = try? JSONDecoder().decode([Debt].self, from: savedData) {
                debts = decodedDebts
            }
        }
    }
    
    func totalOwed(by borrower: Borrower) -> Double {
        debts.filter {
            !$0.isPaid && $0.borrower.id == borrower.id
        }
        .reduce(0) {
            $0 + $1.amount
        }
    }
    
    func debts(for borrower: Borrower) -> [Debt] {
        return debts.filter {
            $0.borrower.id == borrower.id
        }
    }
    
    func debtsGroupedByMonth(for borrower: Borrower) -> [DateComponents : [Debt]] {
        let calendar = Calendar.current
        let filtered = debts(for: borrower)
        let grouped = Dictionary(grouping: filtered) { debt in
            calendar.dateComponents([.year, .month], from: debt.date)
        }
        return grouped
    }
    
    func sortedMonthSections(for borrower: Borrower) -> [(DateComponents, [Debt])] {
        debtsGroupedByMonth(for: borrower)
            .sorted {a, b in
                let calendar = Calendar.current
                let aDate = calendar.date(from: a.key)!
                let bDate = calendar.date(from: b.key)!
                return aDate < bDate
            }
    }
}
