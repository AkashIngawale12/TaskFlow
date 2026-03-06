//
//  HabitRowView.swift
//  TaskFlow
//
//  Habit row card: checkbox (done today), name, repeat days, streak. Toggle disabled when not scheduled today.
//

import SwiftUI
import SwiftData

struct HabitRowView: View {

    // MARK: - Properties

    @Bindable var habit: Habit
    var onToggle: () -> Void

    private var isDoneToday: Bool { HabitStreak.isDoneToday(habit) }
    private var streakCount: Int { HabitStreak.streak(for: habit) }
    private var isScheduledToday: Bool { habit.isScheduledToday }
    private var repeatLabel: String { HabitRowView.repeatDescription(for: habit) }

    // MARK: - Body

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isScheduledToday ? TaskFlowTheme.secondaryLabel : TaskFlowTheme.secondaryLabel.opacity(0.5), lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if isDoneToday {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(TaskFlowTheme.completedGreen)
                            .frame(width: 22, height: 22)
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(!isScheduledToday)

            VStack(alignment: .leading, spacing: 2) {
                Text(habit.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(isScheduledToday ? TaskFlowTheme.label : TaskFlowTheme.secondaryLabel)
                HStack(spacing: 6) {
                    Text(repeatLabel)
                        .font(.caption)
                        .foregroundStyle(TaskFlowTheme.secondaryLabel)
                    if streakCount > 0 {
                        Text("•")
                            .font(.caption)
                            .foregroundStyle(TaskFlowTheme.secondaryLabel)
                        Text("\(streakCount) day streak")
                            .font(.caption)
                            .foregroundStyle(TaskFlowTheme.secondaryLabel)
                    }
                }
                if !isScheduledToday {
                    Text("Not scheduled today")
                        .font(.caption2)
                        .foregroundStyle(TaskFlowTheme.secondaryLabel)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(TaskFlowTheme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.bottom, 4)
        .opacity(isScheduledToday ? 1 : 0.85)
    }

    // MARK: - Private

    /// "Every day" or "Mon, Wed, Fri" style.
    private static func repeatDescription(for habit: Habit) -> String {
        if habit.repeatWeekdays.isEmpty {
            return "Every day"
        }
        let cal = Calendar.current
        let symbols = cal.shortStandaloneWeekdaySymbols
        let sorted = habit.repeatWeekdays.sorted()
        let names = sorted.compactMap { w -> String? in
            guard (1...7).contains(w), symbols.indices.contains(w - 1) else { return nil }
            return symbols[w - 1]
        }
        return names.joined(separator: ", ")
    }
}
