import Foundation

struct Project: Identifiable, Codable {
    let id: UUID
    var name: String
    var people: [Person]
    var expenses: [Expense]
    var lastAccessed: Date
    
    init(id: UUID = UUID(), name: String, people: [Person] = [], expenses: [Expense] = [], lastAccessed: Date = Date()) {
        self.id = id
        self.name = name
        self.people = people
        self.expenses = expenses
        self.lastAccessed = lastAccessed
    }
}

struct Person: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}

struct Expense: Identifiable, Codable {
    let id: UUID
    var title: String
    var amount: Decimal
    var paidById: UUID
    var splitAmongIds: Set<UUID>
    var date: Date
    
    init(id: UUID = UUID(), title: String, amount: Decimal, paidById: UUID, splitAmongIds: Set<UUID>, date: Date = Date()) {
        self.id = id
        self.title = title
        self.amount = amount
        self.paidById = paidById
        self.splitAmongIds = splitAmongIds
        self.date = date
    }
}

struct Settlement: Identifiable {
    let id: UUID
    let fromPerson: Person
    let toPerson: Person
    let amount: Decimal
    
    init(id: UUID = UUID(), fromPerson: Person, toPerson: Person, amount: Decimal) {
        self.id = id
        self.fromPerson = fromPerson
        self.toPerson = toPerson
        self.amount = amount
    }
} 