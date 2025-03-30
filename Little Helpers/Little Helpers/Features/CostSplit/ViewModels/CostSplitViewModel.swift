import Foundation
import SwiftUI

@MainActor
class CostSplitViewModel: ObservableObject {
    @Published var projects: [Project] = []
    @Published var lastVisitedProjectId: UUID?
    
    private let storageKey = "costSplitData"
    
    init() {
        loadProjects()
        loadLastVisitedProject()
    }
    
    // MARK: - Project Management
    
    func createProject(name: String) {
        let project = Project(name: name)
        addProject(project)
    }
    
    func getProject(id: UUID) -> Project? {
        projects.first { $0.id == id }
    }
    
    func addProject(_ project: Project) {
        projects.append(project)
        saveProjects()
        setLastVisitedProject(project)
    }
    
    func updateProject(_ project: Project) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index] = project
            saveProjects()
        }
    }
    
    func deleteProject(_ project: Project) {
        projects.removeAll { $0.id == project.id }
        saveProjects()
        // If we deleted the last visited project, clear it
        if lastVisitedProjectId == project.id {
            lastVisitedProjectId = nil
            saveLastVisitedProject()
        }
    }
    
    // Alias for deleteProject to maintain API compatibility
    func removeProject(_ project: Project) {
        deleteProject(project)
    }
    
    // MARK: - Last Visited Project
    
    func setLastVisitedProject(_ project: Project) {
        lastVisitedProjectId = project.id
        saveLastVisitedProject()
    }
    
    var lastVisitedProject: Project? {
        guard let id = lastVisitedProjectId else { return nil }
        return projects.first { $0.id == id }
    }
    
    // MARK: - Data Management
    
    private func loadProjects() {
        if let data = UserDefaults.standard.data(forKey: "costSplitProjects"),
           let decoded = try? JSONDecoder().decode([Project].self, from: data) {
            projects = decoded
        }
    }
    
    private func saveProjects() {
        if let encoded = try? JSONEncoder().encode(projects) {
            UserDefaults.standard.set(encoded, forKey: "costSplitProjects")
        }
    }
    
    private func loadLastVisitedProject() {
        if let uuidString = UserDefaults.standard.string(forKey: "lastVisitedCostSplitProject") {
            lastVisitedProjectId = UUID(uuidString: uuidString)
        }
    }
    
    private func saveLastVisitedProject() {
        UserDefaults.standard.set(lastVisitedProjectId?.uuidString, forKey: "lastVisitedCostSplitProject")
    }
    
    // MARK: - People Management
    
    func addPerson(name: String, to project: Project) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            let person = Person(name: name)
            projects[index].people.append(person)
            saveProjects()
        }
    }
    
    func removePerson(_ person: Person, from project: Project) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index].people.removeAll { $0.id == person.id }
            // Also remove this person from expenses
            projects[index].expenses = projects[index].expenses.filter { expense in
                expense.paidBy.id != person.id && !expense.participants.contains(where: { $0.id == person.id })
            }
            saveProjects()
        }
    }
    
    // MARK: - Expense Management
    
    func addExpense(title: String, amount: Double, paidBy: Person, participants: [Person], date: Date, to project: Project) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            let expense = Expense(
                title: title,
                amount: amount,
                paidBy: paidBy,
                participants: participants,
                date: date
            )
            projects[index].expenses.append(expense)
            saveProjects()
        }
    }
    
    func removeExpense(_ expense: Expense, from project: Project) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index].expenses.removeAll { $0.id == expense.id }
            saveProjects()
        }
    }
    
    func updateExpense(_ expense: Expense, title: String, amount: Double, paidBy: Person, participants: [Person], date: Date, in project: Project) {
        if let projectIndex = projects.firstIndex(where: { $0.id == project.id }),
           let expenseIndex = projects[projectIndex].expenses.firstIndex(where: { $0.id == expense.id }) {
            let updatedExpense = Expense(
                id: expense.id,
                title: title,
                amount: amount,
                paidBy: paidBy,
                participants: participants,
                date: date
            )
            projects[projectIndex].expenses[expenseIndex] = updatedExpense
            saveProjects()
        }
    }
    
    func getSettlements(for project: Project) -> [Settlement] {
        var balances: [UUID: Double] = [:]
        
        // Calculate initial balances
        for expense in project.expenses {
            let paidBy = expense.paidBy
            let splitAmount = expense.amount / Double(expense.participants.count)
            
            // Add the full amount to the payer's balance
            balances[paidBy.id, default: 0] += expense.amount
            
            // Subtract each person's share
            for person in expense.participants {
                balances[person.id, default: 0] -= splitAmount
            }
        }
        
        var settlements: [Settlement] = []
        let people = project.people
        
        // Create settlements for negative balances
        while !balances.isEmpty {
            guard let maxDebt = balances.min(by: { $0.value < $1.value }),
                  let maxCredit = balances.max(by: { $0.value < $1.value }),
                  let debtor = people.first(where: { $0.id == maxDebt.key }),
                  let creditor = people.first(where: { $0.id == maxCredit.key })
            else { break }
            
            let amount = min(abs(maxDebt.value), maxCredit.value)
            if amount > 0 {
                settlements.append(Settlement(
                    fromPerson: debtor,
                    toPerson: creditor,
                    amount: amount
                ))
            }
            
            // Update balances
            balances[maxDebt.key]! += amount
            balances[maxCredit.key]! -= amount
            
            // Remove settled balances
            if balances[maxDebt.key]!.isZero {
                balances.removeValue(forKey: maxDebt.key)
            }
            if balances[maxCredit.key]!.isZero {
                balances.removeValue(forKey: maxCredit.key)
            }
        }
        
        return settlements
    }
}

// MARK: - Helper Structures

private struct CostSplitData: Codable {
    let people: [Person]
    let expenses: [Expense]
} 