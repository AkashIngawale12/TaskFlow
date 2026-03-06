//
//  TaskListView.swift
//  TaskFlow
//
//  Home: Task list matching UI mockup — dark-style cards, filter chips, FAB.
//

import SwiftUI
import SwiftData

struct TaskListView: View {

    // MARK: - Environment & Data

    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = TaskListViewModel()
    @Query(sort: \Category.name) private var categories: [Category]

    @State private var showingAddTask = false
    @State private var taskToEdit: Task?

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        filterChips
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        
                        if filteredTasks.isEmpty {
                            ContentUnavailableView(
                                "No Tasks",
                                systemImage: "checklist",
                                description: Text("Add a task or change filters.")
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                        } else {
                            ForEach(groupedSections, id: \.name) { section in
                                sectionHeader(section.name)
                                taskCardList(tasks: section.tasks)
                            }
                        }
                    }
                    .padding(.bottom, 100)
                }
                .scrollContentBackground(.hidden)
                .background(TaskFlowTheme.background)
                
                fabButton
            }
            .navigationTitle("Tasks")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            viewModel.selectedCategoryId = nil
                        } label: {
                            HStack {
                                Text("All categories")
                                if viewModel.selectedCategoryId == nil {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        if !categories.isEmpty {
                            Divider()
                            ForEach(categories) { category in
                                Button {
                                    viewModel.selectedCategoryId = category.id
                                } label: {
                                    HStack {
                                        Text(category.name)
                                        if viewModel.selectedCategoryId == category.id {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text("Filter")
                            if viewModel.selectedCategoryId != nil {
                                Image(systemName: "line.3.horizontal.decrease.circle.fill")
                                    .font(.caption)
                            }
                        }
                        .foregroundStyle(TaskFlowTheme.accent)
                        .fontWeight(.medium)
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                TaskEditView(task: nil)
            }
            .sheet(item: $taskToEdit) { task in
                TaskEditView(task: task)
            }
            .onAppear {
                viewModel.setModelContext(modelContext)
            }
        }
    }

    // MARK: - Subviews

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(TaskFilter.allCases) { f in
                    Button {
                        viewModel.filter = f
                    } label: {
                        Text(f.rawValue)
                            .font(.subheadline)
                            .fontWeight(viewModel.filter == f ? .medium : .regular)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(viewModel.filter == f ? TaskFlowTheme.accent : TaskFlowTheme.secondaryBackground)
                            .foregroundStyle(viewModel.filter == f ? .white : TaskFlowTheme.secondaryLabel)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(TaskFlowTheme.secondaryLabel)
            .tracking(0.5)
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 8)
    }

    private func taskCardList(tasks: [Task]) -> some View {
        VStack(spacing: 4) {
            ForEach(tasks, id: \.id) { task in
                TaskRowView(task: task) {
                    taskToEdit = task
                } onToggle: {
                    toggleComplete(task)
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private var fabButton: some View {
        Button {
            showingAddTask = true
        } label: {
            Image(systemName: "plus")
                .font(.title.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(TaskFlowTheme.accent)
                .clipShape(Circle())
                .shadow(color: TaskFlowTheme.accent.opacity(0.4), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .padding(.trailing, 36)
        .padding(.bottom, 32)
    }

    // MARK: - Computed

    private var filteredTasks: [Task] {
        // Fetch all tasks (or by completed) then filter in-memory so Today/Overdue use current date.
        let basePredicate = viewModel.predicateForFetch()
        let descriptor = FetchDescriptor<Task>(
            predicate: basePredicate,
            sortBy: [SortDescriptor(\.dueDate, order: .forward)]
        )
        var tasks = (try? modelContext.fetch(descriptor)) ?? []
        // Apply Today/Overdue/All filter in memory (avoids SwiftData predicate date capture issues).
        tasks = viewModel.applyFilterToTasks(tasks)
        if let cid = viewModel.selectedCategoryId {
            tasks = tasks.filter { $0.category?.id == cid }
        }
        return tasks
    }

    private var groupedSections: [(name: String, tasks: [Task])] {
        var result: [(name: String, tasks: [Task])] = []
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var dict: [String: [Task]] = [:]

        for task in filteredTasks {
            let key: String
            if task.isCompleted {
                key = "Completed"
            } else if let due = task.dueDate {
                if calendar.isDateInToday(due) {
                    key = "Today"
                } else if due < today {
                    key = "Overdue"
                } else {
                    key = "Upcoming"
                }
            } else {
                key = "Upcoming"
            }
            dict[key, default: []].append(task)
        }
        let order = ["Today", "Overdue", "Upcoming", "Completed"]
        for name in order {
            if let tasks = dict[name], !tasks.isEmpty {
                result.append((name, tasks))
            }
        }
        return result
    }

    // MARK: - Actions

    private func toggleComplete(_ task: Task) {
        task.isCompleted.toggle()
        task.completedAt = task.isCompleted ? Date() : nil
        try? modelContext.save()
    }
}

#Preview {
    TaskListView()
        .modelContainer(for: [Task.self, Category.self], inMemory: true)
}
