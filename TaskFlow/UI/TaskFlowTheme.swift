//
//  TaskFlowTheme.swift
//  TaskFlow
//
//  Colors and styling matching the TaskFlow UI mockup (dark theme with light adaptive).
//

import SwiftUI

enum TaskFlowTheme {
    // MARK: - Semantic colors (adapt to light/dark)

    static var background: Color {
        Color(uiColor: .systemBackground)
    }

    static var secondaryBackground: Color {
        Color(uiColor: .secondarySystemBackground)
    }

    static var tertiaryBackground: Color {
        Color(uiColor: .tertiarySystemBackground)
    }

    static var label: Color {
        Color(uiColor: .label)
    }

    static var secondaryLabel: Color {
        Color(uiColor: .secondaryLabel)
    }

    /// Accent blue from mockup (#0a84ff)
    static let accent = Color(red: 10/255, green: 132/255, blue: 255/255)

    /// Green for completed / Personal badge (#34c759)
    static let completedGreen = Color(red: 52/255, green: 199/255, blue: 89/255)

    /// Red for high priority / overdue / delete (#ff3b30)
    static let dangerRed = Color(red: 255/255, green: 59/255, blue: 48/255)

    /// Orange for Health badge (#ff9f0a)
    static let healthOrange = Color(red: 255/255, green: 159/255, blue: 10/255)

    /// Personal badge green (#30d158)
    static let personalGreen = Color(red: 48/255, green: 209/255, blue: 88/255)

    // MARK: - Category badge colors (by name, matching mockup)

    static func badgeColor(forCategoryName name: String) -> Color {
        switch name.lowercased() {
        case "work": return accent
        case "personal": return personalGreen
        case "health": return healthOrange
        default: return secondaryLabel
        }
    }

    static func badgeBackground(forCategoryName name: String) -> Color {
        badgeColor(forCategoryName: name).opacity(0.2)
    }

    /// Category color: use custom hex if set, else fallback to name.
    static func badgeColor(for category: Category?) -> Color {
        guard let cat = category else { return secondaryLabel }
        if let hex = cat.colorHex, let color = Color(hex: hex) { return color }
        return badgeColor(forCategoryName: cat.name)
    }
    static func badgeBackground(for category: Category?) -> Color {
        badgeColor(for: category).opacity(0.2)
    }

    /// Preset colors for category picker (hex).
    static let categoryPresetHexes = ["0A84FF", "30D158", "FF9F0A", "FF3B30", "AF52DE", "5AC8FA", "FF2D55", "8E8E93"]
}

// MARK: - Color+Hex

extension Color {
    init?(hex: String) {
        let s = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard s.count == 6 else { return nil }
        let r = Double(Int(s.prefix(2), radix: 16) ?? 0) / 255
        let g = Double(Int(s.dropFirst(2).prefix(2), radix: 16) ?? 0) / 255
        let b = Double(Int(s.suffix(2), radix: 16) ?? 0) / 255
        self.init(red: r, green: g, blue: b)
    }
}
