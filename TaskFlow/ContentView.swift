//
//  ContentView.swift
//  TaskFlow
//
//  Root tab: Tasks list and Categories.
//

import SwiftUI
import SwiftData

struct ContentView: View {

    // MARK: - State

    @State private var selectedTab = 0

    // MARK: - Body

    var body: some View {
        TabView(selection: $selectedTab) {
            TaskListView()
                .tabItem {
                    Label("Tasks", systemImage: "checklist")
                }
                .tag(0)

            HabitListView()
                .tabItem {
                    Label("Habits", systemImage: "repeat")
                }
                .tag(1)

            InsightsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.bar")
                }
                .tag(2)

            CategoryListView()
                .tabItem {
                    Label("Categories", systemImage: "folder")
                }
                .tag(3)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(4)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Task.self, Category.self, Tag.self, Habit.self, HabitCheckIn.self], inMemory: true)
}
