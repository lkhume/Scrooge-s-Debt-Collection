//
//  NewDebtView.swift
//  Scrooge's Debt Collection
//
//  Created by Ke Han Luo on 2025-04-13.
//

import SwiftUI

struct NewDebtView : View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var viewModel : DebtViewModel
    private var editingDebt : Debt?
    
    var fixedBorrower : Borrower?
    
    @State private var name = ""
    @State private var amount = ""
    @State private var tag = ""
    @State private var description = ""
    @State private var date = Date()
    @State private var isPaid : Bool = false
    @State private var splitEvenly : Bool = false
    @State private var selectedBorrowers : [Borrower] = []
    @State private var borrowerInput : String = ""
    @State private var isAmountValid : Bool = true

    init(viewModel: DebtViewModel, editingDebt: Debt? = nil, borrower: Borrower? = nil) {
        self.viewModel = viewModel
        self.editingDebt = editingDebt
        self.fixedBorrower = borrower
    }
    
    var body : some View {
        NavigationView {
            Form {
                Section(header: Text("Debt Info")) {
                    TextField("Debt Title", text: $name)
                    TextField("Amount ($USD)", text: $amount, onEditingChanged: { isEditing in
                        if isEditing {
                            isAmountValid = true
                        }
                    })
                    .keyboardType(.decimalPad)
                    .foregroundColor(isAmountValid ? Color.primary : Color.red)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(isAmountValid ? Color.clear : Color.red, lineWidth: 1)
                    )
                    if !isAmountValid {
                        Text("Invalid Format - please enter a number")
                            .foregroundColor(Color.red)
                            .font(.caption)
                    }
                    
                    TextField("Tag (Optional)", text: $tag)
                    TextField("Description (Optional)", text: $description)
                    Toggle("Paid", isOn: $isPaid)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                Section(header: Text("Borrowers")) {
                    if let locked = fixedBorrower {
                        HStack {
                            borrowerToken(locked)
                        }
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(selectedBorrowers) { borrower in
                                    borrowerToken(borrower)
                                }
                                
                                TextField("Add borrower...", text: $borrowerInput, onCommit: {
                                    handleBorrowerInput()
                                })
                                .autocapitalization(.words)
                                .textFieldStyle(PlainTextFieldStyle())
                                .frame(width: 150)
                                .disabled(fixedBorrower != nil)
                            }
                        }
                        
                        // Suggestions
                        let filtered = viewModel.borrowers.filter {
                            $0.name.lowercased().contains(borrowerInput.lowercased()) &&
                            !selectedBorrowers.contains($0)
                        }
                        if !filtered.isEmpty {
                            ForEach(filtered, id: \.id) { suggestion in
                                Button(action: {
                                    selectedBorrowers.append(suggestion)
                                    borrowerInput = ""
                                }) {
                                    Text(suggestion.name)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        
                        Toggle("Split Evenly", isOn: $splitEvenly).disabled(selectedBorrowers.count < 2)
                    }
                }
            }
            .navigationTitle(Text(editingDebt == nil ? "New Debt" : "Edit Debt"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(editingDebt == nil ? "Add" : "Save") {
                        addDebt()
                    }.disabled(name.isEmpty || (fixedBorrower == nil && selectedBorrowers.isEmpty) || amount.isEmpty)
                }
            }.onAppear {
                if let debt = editingDebt {
                    name = debt.name
                    selectedBorrowers = [debt.borrower]
                    amount = String(format: "%.2f", debt.amount)
                    tag = debt.tag ?? ""
                    description = debt.description ?? ""
                    date = debt.date
                    isPaid = debt.isPaid
                } else if let borrower = fixedBorrower {
                    selectedBorrowers = [borrower]
                }
            }
        }
    }
    
    func handleBorrowerInput() {
        let trimmed = borrowerInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            return
        }
        
        if let existing = viewModel.borrowers.first(where: { $0.name.lowercased() == trimmed.lowercased() }) {
            if !selectedBorrowers.contains(existing) {
                selectedBorrowers.append(existing)
            }
        } else {
            let newBorrower = Borrower(name: trimmed)
            viewModel.borrowers.append(newBorrower)
            selectedBorrowers.append(newBorrower)
        }
        
        DispatchQueue.main.async {
            borrowerInput = ""
        }
    }
    
    func addDebt() {
        guard let totalAmount = Double(amount), !selectedBorrowers.isEmpty else {
            isAmountValid = false
            return
        }
        
        let perBorrowerAmount : Double = splitEvenly ? totalAmount / Double(selectedBorrowers.count) : totalAmount
        
        for borrower in selectedBorrowers {
            let newDebt = Debt(
                id: editingDebt?.id ?? UUID(),
                name: name,
                borrower: borrower,
                amount: perBorrowerAmount,
                tag: tag.isEmpty ? nil : tag,
                description: description.isEmpty ? nil : description,
                date: date,
                isPaid: isPaid
            )
            if let oldDebt = editingDebt {
                viewModel.removeDebt(oldDebt)
            }
            viewModel.addDebt(newDebt)
        }
        
        dismiss()
    }
    
    func borrowerToken(_ borrower: Borrower) -> some View {
        HStack {
            Text(borrower.name)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            if fixedBorrower == nil {
                Button(action: {
                    selectedBorrowers.removeAll { $0 == borrower }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
            }
        }
    }
}
