//
//  TagsMultiSelectView.swift
//  TaskFlow
//
//  Multi-select tags for a task; optional add new tag.
//

import SwiftUI
import SwiftData

struct TagsMultiSelectView: View {

    // MARK: - Properties

    @Binding var selectedTags: [Tag]
    var allTags: [Tag]
    var modelContext: ModelContext?

    @State private var newTagName = ""
    @State private var showingAddTag = false

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            FlowLayout(spacing: 8) {
                ForEach(allTags) { tag in
                    let isSelected = selectedTags.contains(where: { $0.id == tag.id })
                    Button {
                        if isSelected {
                            selectedTags.removeAll { $0.id == tag.id }
                        } else {
                            selectedTags.append(tag)
                        }
                    } label: {
                        HStack(spacing: 4) {
                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                            }
                            Text(tag.name)
                                .font(.subheadline)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(isSelected ? TaskFlowTheme.accent.opacity(0.2) : TaskFlowTheme.tertiaryBackground)
                        .foregroundStyle(isSelected ? TaskFlowTheme.accent : TaskFlowTheme.label)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            Button {
                showingAddTag = true
            } label: {
                Label("Add tag", systemImage: "plus.circle")
                    .font(.subheadline)
                    .foregroundStyle(TaskFlowTheme.accent)
            }
            .sheet(isPresented: $showingAddTag) {
                addTagSheet
            }
        }
    }

    // MARK: - Sheets

    private var addTagSheet: some View {
        NavigationStack {
            Form {
                TextField("Tag name", text: $newTagName)
            }
            .navigationTitle("New Tag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showingAddTag = false; newTagName = "" }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let trimmed = newTagName.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty, let ctx = modelContext else { showingAddTag = false; return }
                        let tag = Tag(name: trimmed)
                        ctx.insert(tag)
                        try? ctx.save()
                        selectedTags.append(tag)
                        newTagName = ""
                        showingAddTag = false
                    }
                    .disabled(newTagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
