//
//  InsightsView.swift
//  TaskFlow
//
//  Today/week summary, tasks completed per day chart, productivity by category.
//

import SwiftUI
import SwiftData
import Charts

struct InsightsView: View {

    // MARK: - Data

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Task.createdAt, order: .forward) private var allTasks: [Task]

    // MARK: - Computed

    private var todaySummary: (completed: Int, overdue: Int, dueToday: Int) {
        let cal = Calendar.current
        let startOfToday = cal.startOfDay(for: Date())
        let endOfToday = cal.date(byAdding: .day, value: 1, to: startOfToday)!
        var completed = 0, overdue = 0, dueToday = 0
        for t in allTasks {
            if t.isCompleted, let at = t.completedAt, cal.isDateInToday(at) { completed += 1 }
            if !t.isCompleted, let due = t.dueDate, due < startOfToday { overdue += 1 }
            if !t.isCompleted, let due = t.dueDate, due >= startOfToday, due < endOfToday { dueToday += 1 }
        }
        return (completed, overdue, dueToday)
    }

    private var weekSummary: (completed: Int, total: Int) {
        let cal = Calendar.current
        let startOfWeek = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        var completed = 0
        for t in allTasks {
            guard t.isCompleted, let at = t.completedAt, at >= startOfWeek else { continue }
            completed += 1
        }
        return (completed, allTasks.filter { !$0.isCompleted || (($0.completedAt ?? .distantPast) >= startOfWeek) }.count)
    }

    /// Last 14 days: date -> count of tasks completed that day.
    private var completedPerDay: [(date: Date, count: Int)] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        var result: [(Date, Int)] = []
        for offset in (0..<14).reversed() {
            guard let day = cal.date(byAdding: .day, value: -offset, to: today) else { continue }
            let count = allTasks.filter { t in
                guard t.isCompleted, let at = t.completedAt else { return false }
                return cal.isDate(at, inSameDayAs: day)
            }.count
            result.append((day, count))
        }
        return result
    }

    /// Completion rate by category (category name -> completed count / total).
    private var completionByCategory: [(name: String, completed: Int, total: Int)] {
        var dict: [String: (completed: Int, total: Int)] = [:]
        for t in allTasks {
            let name = t.category?.name ?? "Uncategorized"
            var pair = dict[name] ?? (0, 0)
            pair.total += 1
            if t.isCompleted { pair.completed += 1 }
            dict[name] = pair
        }
        return dict.map { (name: $0.key, completed: $0.value.completed, total: $0.value.total) }.sorted { $0.name < $1.name }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    sectionHeader("Today")
                    todaySummaryCards
                    sectionHeader("This week")
                    weekSummaryCard
                    sectionHeader("Completed per day")
                    completedPerDayChart
                    sectionHeader("By category")
                    categoryProductivityList
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .scrollContentBackground(.hidden)
            .background(TaskFlowTheme.background)
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Subviews

    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(TaskFlowTheme.secondaryLabel)
            .tracking(0.5)
            .padding(.top, 24)
            .padding(.bottom, 8)
    }

    private var todaySummaryCards: some View {
        let s = todaySummary
        return HStack(spacing: 12) {
            summaryCard(value: "\(s.completed)", label: "Completed")
            summaryCard(value: "\(s.overdue)", label: "Overdue", color: TaskFlowTheme.dangerRed)
            summaryCard(value: "\(s.dueToday)", label: "Due today")
        }
    }

    private func summaryCard(value: String, label: String, color: Color = TaskFlowTheme.accent) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(color)
            Text(label)
                .font(.caption)
                .foregroundStyle(TaskFlowTheme.secondaryLabel)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(TaskFlowTheme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var weekSummaryCard: some View {
        let s = weekSummary
        let rate = s.total > 0 ? Int((Double(s.completed) / Double(s.total)) * 100) : 0
        return HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(s.completed) completed")
                    .font(.headline)
                    .foregroundStyle(TaskFlowTheme.label)
                Text("\(rate)% completion rate")
                    .font(.caption)
                    .foregroundStyle(TaskFlowTheme.secondaryLabel)
            }
            Spacer()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(TaskFlowTheme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var completedPerDayChart: some View {
        Chart(completedPerDay, id: \.date) { item in
            BarMark(
                x: .value("Day", item.date),
                y: .value("Completed", item.count)
            )
            .foregroundStyle(TaskFlowTheme.accent)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 2)) { _ in
                AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                AxisGridLine()
            }
        }
        .frame(height: 180)
        .padding(14)
        .background(TaskFlowTheme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var categoryProductivityList: some View {
        VStack(spacing: 4) {
            ForEach(completionByCategory, id: \.name) { item in
                HStack {
                    Text(item.name)
                        .foregroundStyle(TaskFlowTheme.label)
                    Spacer()
                    Text("\(item.completed)/\(item.total)")
                        .foregroundStyle(TaskFlowTheme.secondaryLabel)
                    let pct = item.total > 0 ? Int((Double(item.completed) / Double(item.total)) * 100) : 0
                    Text("\(pct)%")
                        .fontWeight(.medium)
                        .foregroundStyle(TaskFlowTheme.accent)
                        .frame(width: 36, alignment: .trailing)
                }
                .padding(12)
                .background(TaskFlowTheme.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}

#Preview {
    InsightsView()
        .modelContainer(for: [Task.self, Category.self], inMemory: true)
}
