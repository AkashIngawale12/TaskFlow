# TaskFlow

**TaskFlow** is an iOS task and habit tracker built with **SwiftUI**, **MVVM**, and **SwiftData**. Single-user, offline-first—all data stays on the device.

> **Built with Cursor AI only.** This project—from idea creation to the full codebase—was built entirely using Cursor AI; no manual coding was used. See [CURSOR_AI_BUILD.md](CURSOR_AI_BUILD.md) for the end-to-end workflow and prompts used so you can replicate the approach.

## Requirements

- Xcode 15+
- iOS 17+
- Swift 5.9+

## Features

### Tasks
- **Add/Edit**: Title (required), notes, due date/time, priority (Low / Medium / High), category, optional reminder (at due time or 5/15/30 min or 1 hr before), multiple tags
- **Filters**: All, Today, Overdue, Completed; filter by category (toolbar menu)
- **Actions**: Tap to view/edit, mark complete, delete; Save / Delete in edit screen
- **Reminders**: Local notifications with snooze (15 min, 1 hour, tomorrow 9am)

### Habits
- **Daily habits** with “done today” check-in and streak count
- **Repeat schedule**: Choose which weekdays (e.g. Mon, Wed, Fri) or every day
- **Reminders**: Optional daily reminder at a set time on scheduled days
- **Edit/Delete**: Context menu on each habit row

### Categories
- Create, edit, delete (e.g. Work, Personal, Health)
- **Color** and **SF Symbol icon** per category
- One category per task

### Tags
- Optional tags on tasks (e.g. #urgent, #waiting); many-to-many, multi-select in task edit
- Create new tags from the tag picker

### Insights
- **Today**: Completed today, overdue, due today
- **This week**: Completed count
- **Completed per day**: Chart (last 14 days) via Swift Charts
- **By category**: Productivity / completion rate per category

### Settings
- **Appearance**: System / Light / Dark (persisted, app-wide)
- **About**: App name, version, short description

### UI
- Tab bar: **Tasks** | **Habits** | **Insights** | **Categories** | **Settings**
- Dark-style cards, FAB for new task, filter chips, category badges
- Follows Apple HIG; theme in `TaskFlowTheme`

## Project structure

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

## Build & run (simulator)

1. Open `TaskFlow.xcodeproj` in Xcode.
2. Select an iOS Simulator (e.g. iPhone 16 Pro).
3. Choose the **TaskFlow** scheme.
4. Press **Run** (⌘R).

Or use **XcodeBuild MCP**: set session defaults (project path `TaskFlow.xcodeproj`, scheme **TaskFlow**, simulator e.g. iPhone 16 Pro), then run `build_run_sim`.

## Tests

- **TaskFlowTests**: Priority and TaskFilter unit tests.
- **TaskModelTests**: Task `isOverdue` / `isDueToday` with in-memory SwiftData.

Run in Xcode: **Product → Test** (⌘U).

## Conventions

- **One type per file**: One primary type per Swift file; filename matches type name (see `.cursor/rules/one-type-per-file.mdc`).
- **MARK comments**: Sections use `// MARK: -` for navigation in the jump bar (Properties, Body, Subviews, Public Methods, etc.).
- **SwiftData**: Task, Category, Tag, Habit, HabitCheckIn; task reminders and habit reminders scheduled via `NotificationService`.

## Version

- **Version**: 1.0  
- **Bundle ID**: com.taskflow.app
