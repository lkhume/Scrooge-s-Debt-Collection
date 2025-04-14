//
//  Debt.swift
//  Scrooge's Debt Collection
//
//  Created by Ke Han Luo on 2025-04-13.
//
import Foundation

struct Debt : Identifiable, Codable {
    let id : UUID
    var name : String
    var borrower : String
    var amount : Double
    var tag : String?
    var description : String?
    var date : Date
    var isPaid : Bool
    
    init(id: UUID = UUID(),
         name: String,
         borrower: String,
         amount: Double,
         tag: String? = nil,
         description: String? = nil,
         date: Date = Date(),
         isPaid: Bool = false)
    {
        self.id = id
        self.name = name
        self.borrower = borrower
        self.amount = amount
        self.tag = tag
        self.description = description
        self.date = date
        self.isPaid = isPaid
    }
}
