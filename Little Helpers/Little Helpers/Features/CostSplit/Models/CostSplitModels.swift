import Foundation

struct Project: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
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
    
    static func == (lhs: Project, rhs: Project) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Person: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Person, rhs: Person) -> Bool {
        lhs.id == rhs.id
    }
}

struct Expense: Identifiable, Codable {
    let id: UUID
    var title: String
    var amount: Double
    var paidBy: Person
    var participants: [Person]
    var date: Date
    
    init(id: UUID = UUID(), title: String, amount: Double, paidBy: Person, participants: [Person], date: Date = Date()) {
        self.id = id
        self.title = title
        self.amount = amount
        self.paidBy = paidBy
        self.participants = participants
        self.date = date
    }
}

struct Settlement: Identifiable {
    let id: UUID
    let fromPerson: Person
    let toPerson: Person
    let amount: Double
    
    init(id: UUID = UUID(), fromPerson: Person, toPerson: Person, amount: Double) {
        self.id = id
        self.fromPerson = fromPerson
        self.toPerson = toPerson
        self.amount = amount
    }
} 