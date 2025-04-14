//
//  BorrowerListView.swift
//  Scrooge's Debt Collection
//
//  Created by Ke Han Luo on 2025-04-14.
//

import SwiftUI

struct BorrowerListView: View {
    @StateObject private var viewModel = DebtViewModel()
    @State private var selectedBorrower: Borrower?
    @State private var selectedNewDebt: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.borrowers) { borrower in
                    NavigationLink(destination: BorrowerDebtView(viewModel: viewModel, borrower: borrower)) {
                        HStack {
                            Text(borrower.name)
                        }
                    }
                }
                .onDelete { indexSet in
                    let borrowersToDelete = indexSet.map{ viewModel.borrowers[$0] }
                    borrowersToDelete.forEach(viewModel.removeBorrower)
                }
            }
            .navigationTitle("Borrower List")
            .toolbar {
                Button(action: {
                    selectedNewDebt = true
                }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $selectedNewDebt) {
                NewDebtView(viewModel: viewModel)
            }
        }
    }
    
    func deleteBorrower(at offsets: IndexSet) {
        offsets.map { viewModel.borrowers[$0] }.forEach { borrower in
            viewModel.removeBorrower(borrower)
        }
    }
}

#Preview {
    BorrowerListView()
}
