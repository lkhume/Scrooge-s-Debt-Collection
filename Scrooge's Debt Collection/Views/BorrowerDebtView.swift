//
//  ContentView.swift
//  Scrooge's Debt Collection
//
//  Created by Ke Han Luo on 2025-02-18.
//

import SwiftUI

extension Debt : Equatable {
    static func ==(lhs: Debt, rhs: Debt) -> Bool {
        lhs.id == rhs.id
    }
}

struct BorrowerDebtView: View {
    @ObservedObject private var viewModel : DebtViewModel
    @State private var showingAddDebt = false
    @State private var editDebt: Debt? = nil
    @State private var expandedSections: Set<DateComponents> = []
    @State private var borrower: Borrower
    
    internal init(viewModel: DebtViewModel, borrower: Borrower) {
        self.viewModel = viewModel
        self.borrower = borrower
    }
    
    var body : some View {
        NavigationView {
            List {
                ForEach(viewModel.sortedMonthSections(for: borrower), id: \.0) { section in
                    DisclosureGroup(
                        isExpanded: Binding(
                            get: { expandedSections.contains(section.0) },
                            set: { isExpanded in
                                if isExpanded {
                                    expandedSections.insert(section.0)
                                } else {
                                    expandedSections.remove(section.0)
                                }
                            }
                        ),
                        content: {
                            ForEach(section.1) { debt in
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text("\(debt.name)").font(.headline)
                                        Spacer()
                                        Text("\(debt.amount, specifier: "%.2f")")
                                            .foregroundColor(debt.isPaid ? .green : .red)
                                    }
                                    if let tag = debt.tag {
                                        Text("Tag: \(tag)")
                                            .font(.caption)
                                    }
                                    if let description = debt.description {
                                        Text(description)
                                            .font(.caption2)
                                    }
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    editDebt = debt
                                }
                            }
                            .onDelete { indexSet in
                                let debtsToDelete = indexSet.map { section.1[$0] }
                                debtsToDelete.forEach(viewModel.removeDebt)
                            }
                        },
                        label: {
                            Text("\(formattedMonth(section.0)) - Total: \(formattedTotal(section.1)) (Unpaid: \(formattedUnpaid(section.1)))")
                                .font(.headline)
                        }
                    )
                }
            }
            .navigationBarTitle("\(borrower.name)'s Debts")
            .toolbar {
                Button(action: {
                    showingAddDebt = true
                }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(item: $editDebt) { debt in
                NewDebtView(viewModel: viewModel, editingDebt: debt, borrower: borrower)
            }
            .sheet(isPresented: $showingAddDebt) {
                NewDebtView(viewModel: viewModel, borrower: borrower)
            }
        }
    }
    
    func formattedMonth(_ components: DateComponents) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        let calendar = Calendar.current
        if let date = calendar.date(from: components) {
            return formatter.string(from: date)
        }
        return "Unknown"
    }
    
    func formattedTotal(_ debts: [Debt]) -> String {
        let total = debts.reduce(0) {
            $0 + $1.amount
        }
        return String(format: "$%.2f", total)
    }
    
    func formattedUnpaid(_ debts: [Debt]) -> String {
        let unpaid = debts.filter { !$0.isPaid }.reduce(0) {
            $0 + $1.amount
        }
        return String(format: "$%.2f", unpaid)
    }
}
