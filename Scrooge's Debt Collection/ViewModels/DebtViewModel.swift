//
//  DebtViewModel.swift
//  Scrooge's Debt Collection
//
//  Created by Ke Han Luo on 2025-04-13.
//

import Foundation


class DebtViewModel : ObservableObject {
    @Published var debts : [Debt] = []
    
    func addDebt(_ debt : Debt) -> Void  {
        debts.append(debt)
    }
    
    func removeDebt(_ debt : Debt) {
        debts.removeAll(where: {$0.id == debt.id})
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
}
