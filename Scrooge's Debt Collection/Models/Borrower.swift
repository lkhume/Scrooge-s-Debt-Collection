//
//  Borrower.swift
//  Scrooge's Debt Collection
//
//  Created by Ke Han Luo on 2025-04-14.
//

import Foundation

struct Borrower : Identifiable, Codable, Hashable, Equatable {
    let id : UUID
    var name: String
    
    init(name: String) {
        self.id = UUID()
        self.name = name
    }
    
    static func == (lhs: Borrower, rhs: Borrower) -> Bool {
        lhs.id == rhs.id
    }
}
