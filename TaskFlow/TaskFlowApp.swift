//
//  TaskFlowApp.swift
//  TaskFlow
//
//  App entry: SwiftData container and root view.
//

import SwiftUI
import SwiftData
import UIKit

@main
struct TaskFlowApp: App {

    // MARK: - Properties

    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Task.self,
            Category.self,
            Tag.self,
            Habit.self,
            HabitCheckIn.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(sharedModelContainer)
    }
}

/// Applies appearance preference (System / Light / Dark) from Settings.
private struct RootView: View {

    // MARK: - Properties

    @AppStorage("appearanceMode") private var appearanceModeRaw = "System"

    private var colorScheme: ColorScheme? {
        switch appearanceModeRaw {
        case "Light": return .light
        case "Dark": return .dark
        default: return nil
        }
    }

    // MARK: - Body

    var body: some View {
        ContentView()
            .preferredColorScheme(colorScheme)
    }
}

private final class AppDelegate: NSObject, UIApplicationDelegate {

    // MARK: - Properties

    private let notificationDelegate = NotificationDelegate()

    // MARK: - UIApplicationDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = notificationDelegate
        NotificationService.registerCategories()
        return true
    }
}
