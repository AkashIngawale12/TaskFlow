//
//  HabitWeekdayPicker.swift
//  TaskFlow
//
//  Pick which weekdays a habit repeats (1 = Sunday … 7 = Saturday).
//

import SwiftUI

struct HabitWeekdayPicker: View {

    // MARK: - Properties

    @Binding var selectedWeekdays: Set<Int>

    private let calendar = Calendar.current
    private var shortSymbols: [String] { calendar.shortStandaloneWeekdaySymbols }
    /// Weekday 1 = Sunday; indices 0..<7 map to 1...7.
    private var weekdays: [Int] { (1...7).map { $0 } }

    // MARK: - Body

    var body: some View {
        HStack(spacing: 8) {
            ForEach(weekdays, id: \.self) { w in
                let isSelected = selectedWeekdays.contains(w)
                let label = shortSymbol(symbols: shortSymbols, weekday: w)
                Button {
                    var next = selectedWeekdays
                    if isSelected {
                        next.remove(w)
                    } else {
                        next.insert(w)
                    }
                    selectedWeekdays = next
                } label: {
                    Text(label)
                        .font(.caption)
                        .fontWeight(.medium)
                        .frame(width: 32, height: 32)
                        .background(isSelected ? TaskFlowTheme.accent : TaskFlowTheme.tertiaryBackground)
                        .foregroundStyle(isSelected ? .white : TaskFlowTheme.secondaryLabel)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Private

    private func shortSymbol(symbols: [String], weekday: Int) -> String {
        let index = weekday - 1
        guard symbols.indices.contains(index) else { return "?" }
        return String(symbols[index].prefix(1))
    }
}
