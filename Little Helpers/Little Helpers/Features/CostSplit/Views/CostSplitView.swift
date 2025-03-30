import SwiftUI

struct CostSplitView: View {
    @StateObject private var viewModel = CostSplitViewModel()
    @State private var showingAddPerson = false
    @State private var showingAddExpense = false
    @State private var showingEditExpense = false
    @State private var showingAddProject = false
    @State private var expenseToEdit: Expense?
    
    var body: some View {
        Group {
            if let project = viewModel.activeProject {
                projectView(project)
            } else {
                ContentUnavailableView("Create a Project", 
                    systemImage: "plus.circle",
                    description: Text("Start by creating a new project to split costs")
                )
                .overlay(alignment: .bottom) {
                    Button(action: { showingAddProject = true }) {
                        Text("New Project")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
            }
        }
        .navigationTitle(viewModel.activeProject?.name ?? "Cost Split")
        .toolbar {
            if !viewModel.projects.isEmpty {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        ForEach(viewModel.projects) { project in
                            Button(project.name) {
                                viewModel.setActiveProject(project)
                            }
                        }
                        Divider()
                        Button("New Project") {
                            showingAddProject = true
                        }
                    } label: {
                        Label("More", systemImage: "folder")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddPerson) {
            NavigationStack {
                AddPersonSheet(viewModel: viewModel, isPresented: $showingAddPerson)
            }
        }
        .sheet(isPresented: $showingAddExpense) {
            if let project = viewModel.activeProject {
                NavigationStack {
                    AddExpenseSheet(viewModel: viewModel, project: project, isPresented: $showingAddExpense)
                }
            }
        }
        .sheet(isPresented: $showingEditExpense) {
            if let project = viewModel.activeProject,
               let expense = expenseToEdit {
                NavigationStack {
                    EditExpenseSheet(
                        viewModel: viewModel,
                        project: project,
                        expense: expense,
                        isPresented: $showingEditExpense
                    )
                }
            }
        }
        .sheet(isPresented: $showingAddProject) {
            NavigationStack {
                AddProjectSheet(viewModel: viewModel, isPresented: $showingAddProject)
            }
        }
    }
    
    @ViewBuilder
    private func projectView(_ project: Project) -> some View {
        List {
            // People Section
            Section("People") {
                ForEach(project.people) { person in
                    Text(person.name)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        viewModel.removePerson(project.people[index])
                    }
                }
                
                Button("Add Person") {
                    showingAddPerson = true
                }
            }
            
            // Expenses Section
            if !project.people.isEmpty {
                Section("Expenses") {
                    ForEach(project.expenses) { expense in
                        ExpenseRow(expense: expense, people: project.people)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    viewModel.removeExpense(expense)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                
                                Button {
                                    expenseToEdit = expense
                                    showingEditExpense = true
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.orange)
                            }
                    }
                    
                    Button("Add Expense") {
                        showingAddExpense = true
                    }
                }
            }
            
            // Settlements Section
            if !viewModel.settlements.isEmpty {
                Section("Settlements") {
                    ForEach(viewModel.settlements) { settlement in
                        SettlementRow(settlement: settlement)
                    }
                }
            }
        }
    }
}

struct ExpenseRow: View {
    let expense: Expense
    let people: [Person]
    
    private var paidByPerson: Person? {
        people.first { $0.id == expense.paidById }
    }
    
    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(expense.title)
                    .font(.headline)
                Spacer()
                Text(String(format: "€%.2f", (expense.amount as NSDecimalNumber).doubleValue))
                    .font(.headline)
            }
            
            HStack {
                Text("Paid by \(paidByPerson?.name ?? "Unknown")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(dateFormatter.string(from: expense.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct SettlementRow: View {
    let settlement: Settlement
    
    var body: some View {
        HStack {
            Text(settlement.fromPerson.name)
            Image(systemName: "arrow.right")
                .foregroundColor(.secondary)
            Text(settlement.toPerson.name)
            Spacer()
            Text(String(format: "€%.2f", (settlement.amount as NSDecimalNumber).doubleValue))
                .bold()
        }
    }
}

struct AddPersonSheet: View {
    @ObservedObject var viewModel: CostSplitViewModel
    @Binding var isPresented: Bool
    @State private var name = ""
    
    var body: some View {
        Form {
            TextField("Name", text: $name)
        }
        .navigationTitle("Add Person")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    isPresented = false
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    if !name.isEmpty {
                        viewModel.addPerson(name: name)
                        isPresented = false
                    }
                }
                .disabled(name.isEmpty)
            }
        }
    }
}

struct AddExpenseSheet: View {
    @ObservedObject var viewModel: CostSplitViewModel
    let project: Project
    @Binding var isPresented: Bool
    @State private var title = ""
    @State private var amount: Decimal = 0
    @State private var paidById: UUID?
    @State private var splitAmongIds = Set<UUID>()
    @State private var splitAmongAll = true
    @State private var amountString = ""
    
    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "de_DE")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    private var isFormValid: Bool {
        !title.isEmpty && amount > 0 && paidById != nil && !splitAmongIds.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                
                Section("Amount") {
                    TextField("0,00", text: $amountString)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.leading)
                        .onChange(of: amountString) { _, newValue in
                            let filtered = newValue.filter { "0123456789,".contains($0) }
                            if filtered != newValue {
                                amountString = filtered
                            }
                            
                            // Convert string to decimal
                            let normalized = filtered.replacingOccurrences(of: ",", with: ".")
                            if let decimal = Decimal(string: normalized) {
                                amount = decimal
                            }
                        }
                }
                
                Picker("Paid by", selection: $paidById) {
                    Text("Select person").tag(nil as UUID?)
                    ForEach(project.people) { person in
                        Text(person.name).tag(person.id as UUID?)
                    }
                }
                
                Section("Split among") {
                    Toggle("Split among all", isOn: $splitAmongAll)
                        .onChange(of: splitAmongAll) { _, newValue in
                            if newValue {
                                splitAmongIds = Set(project.people.map { $0.id })
                            }
                        }
                    
                    if !splitAmongAll {
                        ForEach(project.people) { person in
                            Toggle(person.name, isOn: Binding(
                                get: { splitAmongIds.contains(person.id) },
                                set: { isIncluded in
                                    if isIncluded {
                                        splitAmongIds.insert(person.id)
                                    } else {
                                        splitAmongIds.remove(person.id)
                                        if splitAmongIds.count == project.people.count {
                                            splitAmongAll = true
                                        }
                                    }
                                }
                            ))
                        }
                    }
                }
            }
            .onAppear {
                // Initialize split among all people
                splitAmongIds = Set(project.people.map { $0.id })
            }
            .navigationTitle("Add Expense")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if isFormValid {
                            viewModel.addExpense(
                                title: title,
                                amount: amount,
                                paidById: paidById!,
                                splitAmongIds: splitAmongIds
                            )
                            isPresented = false
                        }
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }
}

struct EditExpenseSheet: View {
    @ObservedObject var viewModel: CostSplitViewModel
    let project: Project
    let expense: Expense
    @Binding var isPresented: Bool
    @State private var title: String
    @State private var amount: Decimal
    @State private var paidById: UUID
    @State private var splitAmongIds: Set<UUID>
    @State private var splitAmongAll: Bool
    
    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "de_DE") // For Euro with comma decimal separator
        return formatter
    }()
    
    init(viewModel: CostSplitViewModel, project: Project, expense: Expense, isPresented: Binding<Bool>) {
        self.viewModel = viewModel
        self.project = project
        self.expense = expense
        self._isPresented = isPresented
        self._title = State(initialValue: expense.title)
        self._amount = State(initialValue: expense.amount)
        self._paidById = State(initialValue: expense.paidById)
        self._splitAmongIds = State(initialValue: expense.splitAmongIds)
        self._splitAmongAll = State(initialValue: expense.splitAmongIds.count == project.people.count)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                
                Section("Amount") {
                    TextField("0,00", value: $amount, formatter: Self.currencyFormatter)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.leading)
                }
                
                Picker("Paid by", selection: $paidById) {
                    ForEach(project.people) { person in
                        Text(person.name).tag(person.id)
                    }
                }
                
                Section("Split among") {
                    Toggle("Split among all", isOn: $splitAmongAll)
                        .onChange(of: splitAmongAll) { _, newValue in
                            if newValue {
                                splitAmongIds = Set(project.people.map { $0.id })
                            }
                        }
                    
                    if !splitAmongAll {
                        ForEach(project.people) { person in
                            Toggle(person.name, isOn: Binding(
                                get: { splitAmongIds.contains(person.id) },
                                set: { isIncluded in
                                    if isIncluded {
                                        splitAmongIds.insert(person.id)
                                    } else {
                                        splitAmongIds.remove(person.id)
                                        if splitAmongIds.count == project.people.count {
                                            splitAmongAll = true
                                        }
                                    }
                                }
                            ))
                        }
                    }
                }
            }
            .navigationTitle("Edit Expense")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if amount > 0 && !splitAmongIds.isEmpty {
                            viewModel.updateExpense(
                                expense,
                                title: title,
                                amount: amount,
                                paidById: paidById,
                                splitAmongIds: splitAmongIds
                            )
                            isPresented = false
                        }
                    }
                    .disabled(title.isEmpty || amount <= 0 || splitAmongIds.isEmpty)
                }
            }
        }
    }
}

struct AddProjectSheet: View {
    @ObservedObject var viewModel: CostSplitViewModel
    @Binding var isPresented: Bool
    @State private var name = ""
    
    var body: some View {
        Form {
            TextField("Project Name", text: $name)
        }
        .navigationTitle("New Project")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    isPresented = false
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Create") {
                    if !name.isEmpty {
                        viewModel.createProject(name: name)
                        isPresented = false
                    }
                }
                .disabled(name.isEmpty)
            }
        }
    }
}

#Preview {
    NavigationView {
        CostSplitView()
    }
} 