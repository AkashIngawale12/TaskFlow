//
//  CategoryListViewModel.swift
//  TaskFlow
//
//  MVVM: Category CRUD for the categories management screen.
//

import Foundation
import SwiftData

@MainActor
final class CategoryListViewModel: ObservableObject {

    // MARK: - Private

    private var modelContext: ModelContext?

    // MARK: - Public Methods

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    func addCategory(name: String, colorHex: String? = nil, iconName: String? = nil) throws {
        guard let context = modelContext else { return }
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let category = Category(name: trimmed, colorHex: colorHex, iconName: iconName)
        context.insert(category)
        try context.save()
    }

    func deleteCategory(_ category: Category) throws {
        guard let context = modelContext else { return }
        context.delete(category)
        try context.save()
    }

    func updateCategory(_ category: Category, name: String, colorHex: String? = nil, iconName: String? = nil) throws {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        category.name = trimmed
        category.colorHex = colorHex
        category.iconName = iconName
        try modelContext?.save()
    }
}
