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
    
    @State private var name = ""
    @State private var borrower = ""
    @State private var amount = ""
    @State private var isAmountValid = true
    @State private var tag = ""
    @State private var description = ""
    @State private var date = Date()
    @State private var isPaid : Bool = false
    
    var body : some View {
        NavigationView {
            Form {
                Section(header: Text("Debt Info")) {
                    TextField("Debt Title", text: $name)
                    TextField("Borrower", text: $borrower)
                    
                    VStack(alignment: .leading, spacing: 4) {
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
                    }
                    
                    TextField("Tag (Optional)", text: $tag)
                    TextField("Description (Optional)", text: $description)
                    Toggle("Paid", isOn: $isPaid)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
            }
            .navigationTitle(Text("New Debt"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if let doubleAmount = Double(amount) {
                            let newDebt = Debt(
                                name: name,
                                borrower: borrower,
                                amount: doubleAmount,
                                tag: tag.isEmpty ? nil : tag,
                                description: description.isEmpty ? nil : description,
                                date: date,
                                isPaid: isPaid
                            )
                            viewModel.addDebt(newDebt)
                            dismiss()
                        } else {
                            isAmountValid = false
                        }
                    }.disabled(name.isEmpty || borrower.isEmpty || amount.isEmpty)
                }
            }
        }
    }
}
