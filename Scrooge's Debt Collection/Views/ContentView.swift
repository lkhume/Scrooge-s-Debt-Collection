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

struct ContentView: View {
    @StateObject private var viewModel = DebtViewModel()
    @State private var showingAddDebt = false
    @State private var editDebt: Debt? = nil
    
    var body : some View {
        NavigationView {
            List {
                ForEach(viewModel.sortedMonthSections, id: \.0) { section in
                    Section(header: Text("\(formattedMonth(section.0)) - Total: \(formattedTotal(section.1)) (Unpaid: \(formattedUnpaid(section.1)))")) {
                        ForEach(section.1) { debt in
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("\(debt.name)").font(.headline)
                                    Spacer()
                                    Text("\(debt.amount, specifier: "%.2f")")
                                        .foregroundColor(debt.isPaid ? .green : .red)
                                }
                                Text("Borrower: \(debt.borrower)")
                                    .font(.subheadline)
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
                    }
                }
            }
            .navigationBarTitle("Scrooge's Debts")
            .toolbar {
                Button(action: {
                    showingAddDebt = true
                }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(item: $editDebt) { debt in
                NewDebtView(viewModel: viewModel, editingDebt: debt)
            }
            .sheet(isPresented: $showingAddDebt) {
                NewDebtView(viewModel: viewModel)
            }
        }
    }
    
    func deleteDebt(at offsets: IndexSet) {
        offsets.map { viewModel.debts[$0] }.forEach { debt in
            viewModel.removeDebt(debt)
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

#Preview {
    ContentView()
}
