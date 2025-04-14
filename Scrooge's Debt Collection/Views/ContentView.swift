//
//  ContentView.swift
//  Scrooge's Debt Collection
//
//  Created by Ke Han Luo on 2025-02-18.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = DebtViewModel()
    @State private var showingAddDebt = false
    
    var body : some View {
        NavigationView {
            List {
                ForEach(viewModel.debts, id: \.id) { debt in
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
            .sheet(isPresented: $showingAddDebt) {
                NewDebtView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}
