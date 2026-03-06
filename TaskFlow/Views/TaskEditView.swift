//
//  TaskEditView.swift
//  TaskFlow
//
//  Add/Edit task matching mockup: back row, detail fields in cards, Save/Delete.
//

import SwiftUI
import SwiftData

struct TaskEditView: View {

    // MARK: - Environment & Data

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: TaskEditViewModel
    @Query(sort: \Category.name) private var categories: [Category]
    @Query(sort: \Tag.name) private var tags: [Tag]

    init(task: Task?) {
        _viewModel = StateObject(wrappedValue: TaskEditViewModel(task: task))
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    backRow

                    VStack(alignment: .leading, spacing: 20) {
                        detailField(label: "Title") {
                            TextField("Title", text: $viewModel.title)
                        }
                        detailField(label: "Notes") {
                            TextField("Notes", text: $viewModel.notes, axis: .vertical)
                                .lineLimit(3...6)
                        }
                        detailField(label: "Set due date") {
                            Toggle("", isOn: $viewModel.hasDueDate)
                                .labelsHidden()
                        }
                        if viewModel.hasDueDate {
                            detailField(label: "Due date") {
                                DatePicker("", selection: $viewModel.dueDate, displayedComponents: [.date, .hourAndMinute])
                                    .labelsHidden()
                            }
                        }
                        detailField(label: "Category") {
                            Picker("", selection: $viewModel.category) {
                                Text("None").tag(nil as Category?)
                                ForEach(categories) { cat in
                                    Text(cat.name).tag(cat as Category?)
                                }
                            }
                            .labelsHidden()
                            .pickerStyle(.menu)
                        }
                        detailField(label: "Priority") {
                            Picker("", selection: $viewModel.priority) {
                                ForEach(Priority.allCases, id: \.self) { p in
                                    Text(p.displayName).tag(p)
                                }
                            }
                            .pickerStyle(.segmented)
                            .labelsHidden()
                        }
                        detailField(label: "Reminder") {
                            Picker("", selection: $viewModel.reminderOption) {
                                ForEach(ReminderOption.allCases) { opt in
                                    Text(opt.label).tag(opt)
                                }
                            }
                            .labelsHidden()
                            .pickerStyle(.menu)
                        }
                        .disabled(!viewModel.hasDueDate)
                        detailField(label: "Tags") {
                            TagsMultiSelectView(selectedTags: $viewModel.selectedTags, allTags: tags, modelContext: modelContext)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    detailActions
                        .padding(.horizontal, 20)
                        .padding(.top, 32)
                        .padding(.bottom, 40)
                }
            }
            .scrollContentBackground(.hidden)
            .background(TaskFlowTheme.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                viewModel.setModelContext(modelContext)
            }
            .onChange(of: viewModel.reminderOption) { _, newOption in
                if viewModel.hasDueDate && newOption != .none {
                    NotificationService.requestAuthorizationInBackground()
                }
            }
        }
    }

    // MARK: - Subviews

    private var backRow: some View {
        Button {
            dismiss()
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                Text("Back to list")
            }
            .font(.body)
            .fontWeight(.regular)
            .foregroundStyle(TaskFlowTheme.accent)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 24)
    }

    // MARK: - Private Helpers

    private func detailField<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(TaskFlowTheme.secondaryLabel)
            content()
                .font(.body)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(TaskFlowTheme.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    private var detailActions: some View {
        HStack(spacing: 12) {
            Button("Save") {
                _Concurrency.Task { @MainActor in
                    if viewModel.hasDueDate && viewModel.reminderOption != .none {
                        _ = await NotificationService.requestAuthorization()
                    }
                    viewModel.setModelContext(modelContext)
                    try? viewModel.save()
                    dismiss()
                }
            }
            .font(.body)
            .fontWeight(.medium)
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(TaskFlowTheme.accent)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .disabled(viewModel.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            if viewModel.isEditing {
                Button("Delete") {
                    viewModel.setModelContext(modelContext)
                    try? viewModel.deleteTask()
                    dismiss()
                }
                .font(.body)
                .fontWeight(.medium)
                .foregroundStyle(TaskFlowTheme.dangerRed)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(TaskFlowTheme.dangerRed.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

#Preview {
    TaskEditView(task: nil)
        .modelContainer(for: [Task.self, Category.self], inMemory: true)
}
