//
//  CategoryListView.swift
//  TaskFlow
//
//  Categories: create, edit, delete (e.g. Work, Personal, Health).
//

import SwiftUI
import SwiftData

struct CategoryListView: View {

    // MARK: - Environment & Data

    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = CategoryListViewModel()
    @Query(sort: \Category.name) private var categories: [Category]

    @State private var showingAdd = false
    @State private var newName = ""
    @State private var newColorHex: String?
    @State private var newIconName: String?
    @State private var editingCategory: Category?
    @State private var editName = ""
    @State private var editColorHex: String?
    @State private var editIconName: String?

    private static let presetIcons = ["folder.fill", "briefcase.fill", "person.fill", "heart.fill", "star.fill", "book.fill", "house.fill", "tag.fill", "flag.fill"]

    // MARK: - Body

    var body: some View {
        NavigationStack {
            List {
                ForEach(categories) { category in
                    HStack {
                        Image(systemName: category.iconName ?? "folder.fill")
                            .foregroundStyle(TaskFlowTheme.badgeColor(for: category))
                        Text(category.name)
                        Spacer()
                        Button("Edit") {
                            editingCategory = category
                            editName = category.name
                            editColorHex = category.colorHex
                            editIconName = category.iconName
                        }
                        .buttonStyle(.borderless)
                    }
                }
                .onDelete(perform: deleteCategories)
            }
            .navigationTitle("Categories")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                addCategorySheet
            }
            .sheet(item: $editingCategory) { cat in
                editCategorySheet(cat)
            }
            .onAppear {
                viewModel.setModelContext(modelContext)
            }
        }
    }

    // MARK: - Sheets

    private var addCategorySheet: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $newName)
                Section("Color") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(TaskFlowTheme.categoryPresetHexes, id: \.self) { hex in
                                let isSelected = newColorHex == hex
                                Button {
                                    newColorHex = isSelected ? nil : hex
                                } label: {
                                    Circle()
                                        .fill(Color(hex: hex) ?? .gray)
                                        .frame(width: 28, height: 28)
                                        .overlay { if isSelected { Circle().strokeBorder(.white, lineWidth: 3) } }
                                }
                            }
                        }
                    }
                }
                Section("Icon") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 12) {
                        ForEach(Self.presetIcons, id: \.self) { icon in
                            CategoryIconCell(icon: icon, selectedIconName: $newIconName)
                        }
                    }
                }
            }
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingAdd = false
                        newName = ""
                        newColorHex = nil
                        newIconName = nil
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        viewModel.setModelContext(modelContext)
                        try? viewModel.addCategory(name: newName, colorHex: newColorHex, iconName: newIconName)
                        newName = ""
                        newColorHex = nil
                        newIconName = nil
                        showingAdd = false
                    }
                    .disabled(newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func editCategorySheet(_ category: Category) -> some View {
        NavigationStack {
            Form {
                TextField("Name", text: $editName)
                Section("Color") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(TaskFlowTheme.categoryPresetHexes, id: \.self) { hex in
                                let isSelected = editColorHex == hex
                                Button {
                                    editColorHex = isSelected ? nil : hex
                                } label: {
                                    Circle()
                                        .fill(Color(hex: hex) ?? .gray)
                                        .frame(width: 28, height: 28)
                                        .overlay { if isSelected { Circle().strokeBorder(.white, lineWidth: 3) } }
                                }
                            }
                        }
                    }
                }
                Section("Icon") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 12) {
                        ForEach(Self.presetIcons, id: \.self) { icon in
                            CategoryIconCell(icon: icon, selectedIconName: $editIconName)
                        }
                    }
                }
            }
            .navigationTitle("Edit Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { editingCategory = nil }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        try? viewModel.updateCategory(category, name: editName, colorHex: editColorHex, iconName: editIconName)
                        editingCategory = nil
                    }
                    .disabled(editName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    // MARK: - Actions

    private func deleteCategories(at offsets: IndexSet) {
        viewModel.setModelContext(modelContext)
        for index in offsets {
            let cat = categories[index]
            try? viewModel.deleteCategory(cat)
        }
    }
}

// MARK: - Icon cell (own type so each button captures correct icon in closure)
private struct CategoryIconCell: View {
    let icon: String
    @Binding var selectedIconName: String?

    var body: some View {
        let isSelected = selectedIconName == icon
        Button {
            selectedIconName = isSelected ? nil : icon
        } label: {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(isSelected ? TaskFlowTheme.accent : TaskFlowTheme.secondaryLabel)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CategoryListView()
        .modelContainer(for: [Task.self, Category.self], inMemory: true)
}
