//
//  HabitListView.swift
//  TaskFlow
//
//  Habits list with "Done today" and streak display.
//

import SwiftUI
import SwiftData

struct HabitListView: View {

    // MARK: - Environment & Data

    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = HabitListViewModel()
    @Query(sort: \Habit.name) private var habits: [Habit]

    @State private var showingAdd = false
    @State private var newName = ""
    @State private var newRepeatWeekdays: Set<Int> = Set(1...7)
    @State private var newReminderEnabled = false
    @State private var newReminderTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var editingHabit: Habit?
    @State private var editName = ""
    @State private var editRepeatWeekdays: Set<Int> = Set(1...7)
    @State private var editReminderEnabled = false
    @State private var editReminderTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if habits.isEmpty {
                        ContentUnavailableView(
                            "No Habits",
                            systemImage: "repeat",
                            description: Text("Add a habit to track daily.")
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                    } else {
                        sectionHeader("Today")
                        ForEach(habits) { habit in
                            HabitRowView(
                                habit: habit,
                                onToggle: { try? viewModel.toggleCheckIn(for: habit) }
                            )
                            .padding(.horizontal, 20)
                            .contextMenu {
                                Button {
                                    editName = habit.name
                                    editRepeatWeekdays = habit.repeatWeekdays.isEmpty ? Set(1...7) : Set(habit.repeatWeekdays)
                                    if let t = habit.reminderTime {
                                        editReminderEnabled = true
                                        editReminderTime = t
                                    } else {
                                        editReminderEnabled = false
                                        editReminderTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
                                    }
                                    editingHabit = habit
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                Button(role: .destructive) {
                                    try? viewModel.deleteHabit(habit)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 40)
            }
            .scrollContentBackground(.hidden)
            .background(TaskFlowTheme.background)
            .navigationTitle("Habits")
            .navigationBarTitleDisplayMode(.large)
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
                addHabitSheet
            }
            .sheet(item: $editingHabit) { habit in
                editHabitSheet(habit: habit)
            }
            .onAppear {
                viewModel.setModelContext(modelContext)
            }
        }
    }

    // MARK: - Subviews

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

    // MARK: - Sheets

    private var addHabitSheet: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Habit name", text: $newName)
                }
                Section("Repeat on") {
                    HabitWeekdayPicker(selectedWeekdays: $newRepeatWeekdays)
                    Text("Leave all selected for every day.")
                        .font(.caption)
                        .foregroundStyle(TaskFlowTheme.secondaryLabel)
                }
                Section("Reminder") {
                    Toggle("Remind me", isOn: $newReminderEnabled)
                        .onChange(of: newReminderEnabled) { _, enabled in
                            if enabled { NotificationService.requestAuthorizationInBackground() }
                        }
                    if newReminderEnabled {
                        DatePicker("Time", selection: $newReminderTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                }
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingAdd = false
                        newName = ""
                        newRepeatWeekdays = Set(1...7)
                        newReminderEnabled = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let weekdays = newRepeatWeekdays.sorted()
                        let reminder: Date? = newReminderEnabled ? newReminderTime : nil
                        try? viewModel.addHabit(
                            name: newName,
                            repeatWeekdays: weekdays.count == 7 ? [] : weekdays,
                            reminderTime: reminder
                        )
                        newName = ""
                        newRepeatWeekdays = Set(1...7)
                        newReminderEnabled = false
                        showingAdd = false
                    }
                    .disabled(newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func editHabitSheet(habit: Habit) -> some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Habit name", text: $editName)
                }
                Section("Repeat on") {
                    HabitWeekdayPicker(selectedWeekdays: $editRepeatWeekdays)
                }
                Section("Reminder") {
                    Toggle("Remind me", isOn: $editReminderEnabled)
                        .onChange(of: editReminderEnabled) { _, enabled in
                            if enabled { NotificationService.requestAuthorizationInBackground() }
                        }
                    if editReminderEnabled {
                        DatePicker("Time", selection: $editReminderTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                }
            }
            .navigationTitle("Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        editingHabit = nil
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let weekdays = editRepeatWeekdays.sorted()
                        let reminder: Date? = editReminderEnabled ? editReminderTime : nil
                        try? viewModel.updateHabit(
                            habit,
                            name: editName,
                            repeatWeekdays: weekdays.count == 7 ? [] : weekdays,
                            reminderTime: reminder
                        )
                        editingHabit = nil
                    }
                    .disabled(editName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                editName = habit.name
                editRepeatWeekdays = habit.repeatWeekdays.isEmpty ? Set(1...7) : Set(habit.repeatWeekdays)
                if let t = habit.reminderTime {
                    editReminderEnabled = true
                    editReminderTime = t
                } else {
                    editReminderEnabled = false
                    editReminderTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
                }
            }
        }
    }
}

#Preview {
    HabitListView()
        .modelContainer(for: [Habit.self, HabitCheckIn.self], inMemory: true)
}
