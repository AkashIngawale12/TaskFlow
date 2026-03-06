# 🚀 TaskFlow

**TaskFlow** is an iOS task and habit tracker built with **SwiftUI**, **MVVM**, and **SwiftData**. Single-user, offline-first - all data stays on the device.

## Requirements

- Xcode 15+
- iOS 17+
- Swift 5.9+

## 📱 Screen Shots:

<p align="center">
  <img src="https://github.com/user-attachments/assets/900c9008-6a82-4871-86e4-1afdeaf34734" width="200" />
  <img src="https://github.com/user-attachments/assets/20f5ed51-63a9-4ee6-99a3-6d1ceedf44bf" width="200" />
  <img src="https://github.com/user-attachments/assets/81abe6a6-1c09-4e20-8886-8ee2a35dc61b" width="200" />
  <img src="https://github.com/user-attachments/assets/2894ddd0-d823-444f-8969-ddd3689c952e" width="200" />
  <img src="https://github.com/user-attachments/assets/7bde83a1-4d51-4298-ab30-5be9f274a4ea" width="200" />
  <img src="https://github.com/user-attachments/assets/a92db15d-3cb1-4e49-adab-ee4809eeab81" width="200" />
  <img src="https://github.com/user-attachments/assets/f5aeda37-7de5-4b64-9a41-d529d79f5fc3" width="200" />
  <img src="https://github.com/user-attachments/assets/6b2b2ce0-b7f6-435a-85c1-920c31ef7e88" width="200" />
  <img src="https://github.com/user-attachments/assets/72ae6d3e-d838-45d9-913b-854a985aab19" width="200" />
  <img src="https://github.com/user-attachments/assets/f18b6b3d-9d91-44f4-a4b3-b134f0ab932d" width="200" />
  <img src="https://github.com/user-attachments/assets/1f928737-0644-4e33-8503-99cf7b5756b8" width="200" />
  <img src="https://github.com/user-attachments/assets/87678921-279e-42f8-acd0-0bec0eb2d35d" width="200" />
  <img src="https://github.com/user-attachments/assets/8f85833b-c1c6-4508-a410-cd09b0329a5f" width="200" />
  <img src="https://github.com/user-attachments/assets/6048cf59-224c-4d2c-84fd-bb74758463a2" width="200" />
  <img src="https://github.com/user-attachments/assets/dd62f744-8f56-432a-b320-e5bf29c4c460" width="200" />
</p>

## ✨ Features

### ✅ Tasks
- **Add/Edit**: Title (required), notes, due date/time, priority (Low / Medium / High), category, optional reminder (at due time or 5/15/30 min or 1 hr before), multiple tags
- **Filters**: All, Today, Overdue, Completed; filter by category (toolbar menu)
- **Actions**: Tap to view/edit, mark complete, delete; Save / Delete in edit screen
- **Reminders**: Local notifications with snooze (15 min, 1 hour, tomorrow 9am)

### 📅 Habits
- **Daily habits** with “done today” check-in and streak count
- **Repeat schedule**: Choose which weekdays (e.g. Mon, Wed, Fri) or every day
- **Reminders**: Optional daily reminder at a set time on scheduled days
- **Edit/Delete**: Context menu on each habit row

### 🗂 Categories
- Create, edit, delete (e.g. Work, Personal, Health)
- **Color** and **SF Symbol icon** per category
- One category per task

### 🏷 Tags
- Optional tags on tasks (e.g. #urgent, #waiting); many-to-many, multi-select in task edit
- Create new tags from the tag picker

### 📊 Insights
- **Today**: Completed today, overdue, due today
- **This week**: Completed count
- **Completed per day**: Chart (last 14 days) via Swift Charts
- **By category**: Productivity / completion rate per category

### ⚙️ Settings
- **Appearance**: System / Light / Dark (persisted, app-wide)
- **About**: App name, version, short description

### 🖌 UI
- Tab bar: **Tasks** | **Habits** | **Insights** | **Categories** | **Settings**
- Dark-style cards, FAB for new task, filter chips, category badges
- Follows Apple HIG; theme in `TaskFlowTheme`

## 🏗 Project structure

```
TaskFlow/
├── TaskFlowApp.swift          # App entry, SwiftData container, RootView, AppDelegate
├── ContentView.swift          # Tab view (Tasks, Habits, Insights, Categories, Settings)
├── App/
│   └── NotificationDelegate.swift   # Foreground presentation, snooze action handling
├── Models/
│   ├── Task.swift
│   ├── Category.swift
│   ├── Priority.swift
│   ├── Tag.swift
│   ├── Habit.swift             # + HabitCheckIn
│   └── HabitStreak.swift       # Streak / isDoneToday helpers
├── ViewModels/
│   ├── TaskFilter.swift
│   ├── TaskListViewModel.swift
│   ├── TaskEditViewModel.swift
│   ├── CategoryListViewModel.swift
│   ├── HabitListViewModel.swift
├── Views/
│   ├── TaskListView.swift
│   ├── TaskRowView.swift
│   ├── TaskEditView.swift
│   ├── CategoryListView.swift
│   ├── HabitListView.swift
│   ├── HabitRowView.swift
│   ├── HabitWeekdayPicker.swift
│   ├── InsightsView.swift
│   ├── SettingsView.swift
│   └── TagsMultiSelectView.swift
├── UI/
│   ├── TaskFlowTheme.swift    # Colors, category badges, preset hexes
│   └── FlowLayout.swift       # Wrapping layout for tag chips
├── Services/
│   └── NotificationService.swift   # Task/habit reminders, snooze, categories
├── Assets.xcassets/
└── Info.plist

TaskFlowTests/
├── TaskFlowTests.swift
└── TaskModelTests.swift
```

## 🚀 Build & run (simulator)

1. Open `TaskFlow.xcodeproj` in Xcode.
2. Select an iOS Simulator (e.g. iPhone 16 Pro).
3. Choose the **TaskFlow** scheme.
4. Press **Run** (⌘R).

Or use **XcodeBuild MCP**: set session defaults (project path `TaskFlow.xcodeproj`, scheme **TaskFlow**, simulator e.g. iPhone 16 Pro), then run `build_run_sim`.

## 🧪 Tests

- **TaskFlowTests**: Priority and TaskFilter unit tests.
- **TaskModelTests**: Task `isOverdue` / `isDueToday` with in-memory SwiftData.

Run in Xcode: **Product → Test** (⌘U).

## 📝 Conventions

- **One type per file**: One primary type per Swift file; filename matches type name (see `.cursor/rules/one-type-per-file.mdc`).
- **MARK comments**: Sections use `// MARK: -` for navigation in the jump bar (Properties, Body, Subviews, Public Methods, etc.).
- **SwiftData**: Task, Category, Tag, Habit, HabitCheckIn; task reminders and habit reminders scheduled via `NotificationService`.

##  📦 Version

- **Version**: 1.0  
- **Bundle ID**: com.taskflow.app
