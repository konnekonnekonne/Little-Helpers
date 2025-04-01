import SwiftUI

struct CostSplitView: View {
    @StateObject private var viewModel = CostSplitViewModel()
    @State private var showingAddProject = false
    
    var body: some View {
        ProjectListView()
            .navigationTitle("Cost Split")
            .toolbar {
                if !viewModel.projects.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingAddProject = true }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddProject) {
                NavigationStack {
                    AddProjectSheet(viewModel: viewModel, isPresented: $showingAddProject)
                }
            }
    }
    
    private var projectsList: some View {
        List {
            ForEach(viewModel.projects) { project in
                NavigationLink(destination: CostSplitProjectView(viewModel: viewModel, project: project)) {
                    VStack(alignment: .leading) {
                        Text(project.name)
                            .font(.headline)
                        if !project.expenses.isEmpty {
                            Text("\(project.expenses.count) expenses")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .onDelete { indexSet in
                indexSet.forEach { index in
                    viewModel.deleteProject(viewModel.projects[index])
                }
            }
        }
        .overlay {
            if viewModel.projects.isEmpty {
                emptyState
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)
            
            Text("No Projects Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start by creating your first project")
                .foregroundColor(.secondary)
            
            Button(action: { showingAddProject = true }) {
                Text("Add New Project")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: 280)
                    .frame(height: 50)
                    .background(Color.accentColor)
                    .cornerRadius(12)
            }
            .padding(.top, 8)
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        CostSplitView()
    }
} 