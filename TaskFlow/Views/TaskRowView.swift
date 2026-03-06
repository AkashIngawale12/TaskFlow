//
//  TaskRowView.swift
//  TaskFlow
//
//  Task row card: checkbox, title, category badge, tags, due/overdue.
//

import SwiftUI
import SwiftData

struct TaskRowView: View {

    // MARK: - Properties

    @Bindable var task: Task
    var onTap: () -> Void
    var onToggle: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .center, spacing: 12) {
                Button(action: onToggle) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(TaskFlowTheme.secondaryLabel, lineWidth: 2)
                            .frame(width: 22, height: 22)
                        if task.isCompleted {
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

                VStack(alignment: .leading, spacing: 2) {
                    Text(task.title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(task.isCompleted ? TaskFlowTheme.secondaryLabel : TaskFlowTheme.label)
                        .strikethrough(task.isCompleted)
                    HStack(spacing: 8) {
                        if let cat = task.category {
                            HStack(spacing: 4) {
                                Image(systemName: cat.iconName ?? "folder.fill")
                                    .font(.caption2)
                                Text(cat.name)
                                    .font(.caption)
                            }
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(TaskFlowTheme.badgeBackground(for: cat))
                            .foregroundStyle(TaskFlowTheme.badgeColor(for: cat))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        if let taskTags = task.tags, !taskTags.isEmpty {
                            ForEach(taskTags) { tag in
                                Text("#\(tag.name)")
                                    .font(.caption2)
                                    .foregroundStyle(TaskFlowTheme.secondaryLabel)
                            }
                        }
                        if task.isCompleted {
                            Text("Completed")
                                .font(.caption)
                                .foregroundStyle(TaskFlowTheme.secondaryLabel)
                        } else if let due = task.dueDate {
                            Text(task.isOverdue ? "Overdue" : due.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(task.isOverdue ? TaskFlowTheme.dangerRed : TaskFlowTheme.secondaryLabel)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(TaskFlowTheme.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .opacity(task.isCompleted ? 0.8 : 1)
        }
        .buttonStyle(.plain)
    }
}
