import Foundation
import SwiftUI

@MainActor
class CostSplitViewModel: ObservableObject {
    @Published var projects: [Project] = []
    @Published var activeProject: Project?
    @Published var settlements: [Settlement] = []
    
    private let storageKey = "costSplitData"
    private let activeProjectKey = "costSplitActiveProject"
    
    init() {
        loadData()
    }
    
    // MARK: - Project Management
    
    func createProject(name: String) {
        let project = Project(name: name)
        projects.append(project)
        setActiveProject(project)
        saveData()
    }
    
    func setActiveProject(_ project: Project) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index].lastAccessed = Date()
            activeProject = projects[index]
            calculateSettlements()
            saveData()
            UserDefaults.standard.set(project.id.uuidString, forKey: activeProjectKey)
        }
    }
    
    // MARK: - Data Management
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: storageKey) {
            do {
                projects = try JSONDecoder().decode([Project].self, from: data)
                
                // Load last active project
                if let activeProjectId = UserDefaults.standard.string(forKey: activeProjectKey),
                   let uuid = UUID(uuidString: activeProjectId),
                   let project = projects.first(where: { $0.id == uuid }) {
                    setActiveProject(project)
                } else if let lastProject = projects.max(by: { $0.lastAccessed < $1.lastAccessed }) {
                    setActiveProject(lastProject)
                }
            } catch {
                print("Error loading data: \(error)")
            }
        }
    }
    
    private func saveData() {
        do {
            let encoded = try JSONEncoder().encode(projects)
            UserDefaults.standard.set(encoded, forKey: storageKey)
        } catch {
            print("Error saving data: \(error)")
        }
    }
    
    // MARK: - People Management
    
    func addPerson(name: String) {
        guard var project = activeProject else { return }
        let person = Person(name: name)
        project.people.append(person)
        updateActiveProject(project)
    }
    
    func removePerson(_ person: Person) {
        guard var project = activeProject else { return }
        project.people.removeAll { $0.id == person.id }
        project.expenses.removeAll { expense in
            expense.paidById == person.id || expense.splitAmongIds.contains(person.id)
        }
        updateActiveProject(project)
    }
    
    // MARK: - Expense Management
    
    func addExpense(title: String, amount: Decimal, paidById: UUID, splitAmongIds: Set<UUID>) {
        guard var project = activeProject else { return }
        let expense = Expense(
            title: title,
            amount: amount,
            paidById: paidById,
            splitAmongIds: splitAmongIds
        )
        project.expenses.append(expense)
        updateActiveProject(project)
    }
    
    func removeExpense(_ expense: Expense) {
        guard var project = activeProject else { return }
        project.expenses.removeAll { $0.id == expense.id }
        updateActiveProject(project)
    }
    
    func updateExpense(_ expense: Expense, title: String, amount: Decimal, paidById: UUID, splitAmongIds: Set<UUID>) {
        guard var project = activeProject else { return }
        if let index = project.expenses.firstIndex(where: { $0.id == expense.id }) {
            let updatedExpense = Expense(
                id: expense.id,
                title: title,
                amount: amount,
                paidById: paidById,
                splitAmongIds: splitAmongIds,
                date: expense.date
            )
            project.expenses[index] = updatedExpense
            updateActiveProject(project)
        }
    }
    
    private func updateActiveProject(_ project: Project) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            var updatedProject = project
            updatedProject.lastAccessed = Date()
            projects[index] = updatedProject
            activeProject = updatedProject
            calculateSettlements()
            saveData()
        }
    }
    
    // MARK: - Settlement Calculation
    
    private func calculateSettlements() {
        guard let project = activeProject else {
            settlements = []
            return
        }
        
        var balances: [UUID: Decimal] = [:]
        
        // Initialize balances for all people
        for person in project.people {
            balances[person.id] = 0
        }
        
        // Calculate initial balances
        for expense in project.expenses {
            // Add full amount to payer's balance
            balances[expense.paidById, default: 0] += expense.amount
            
            // Subtract split amount from each participant's balance
            let splitAmount = expense.amount / Decimal(expense.splitAmongIds.count)
            for participantId in expense.splitAmongIds {
                balances[participantId, default: 0] -= splitAmount
            }
        }
        
        // Create settlements
        var newSettlements: [Settlement] = []
        var debtors: [(UUID, Decimal)] = balances.filter { $0.value < 0 }
            .map { ($0.key, abs($0.value)) }
            .sorted { $0.1 > $1.1 }
        var creditors: [(UUID, Decimal)] = balances.filter { $0.value > 0 }
            .map { ($0.key, $0.value) }
            .sorted { $0.1 > $1.1 }
        
        while !debtors.isEmpty && !creditors.isEmpty {
            var (debtorId, debtAmount) = debtors.removeLast()
            var (creditorId, creditAmount) = creditors.removeLast()
            
            let settlementAmount = min(debtAmount, creditAmount)
            
            if let debtor = project.people.first(where: { $0.id == debtorId }),
               let creditor = project.people.first(where: { $0.id == creditorId }) {
                newSettlements.append(Settlement(
                    fromPerson: debtor,
                    toPerson: creditor,
                    amount: settlementAmount
                ))
            }
            
            debtAmount -= settlementAmount
            creditAmount -= settlementAmount
            
            if debtAmount > 0 {
                debtors.append((debtorId, debtAmount))
                debtors.sort { $0.1 > $1.1 }
            }
            if creditAmount > 0 {
                creditors.append((creditorId, creditAmount))
                creditors.sort { $0.1 > $1.1 }
            }
        }
        
        settlements = newSettlements
    }
}

// MARK: - Helper Structures

private struct CostSplitData: Codable {
    let people: [Person]
    let expenses: [Expense]
} 