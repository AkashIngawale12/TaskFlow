//
//  SettingsView.swift
//  TaskFlow
//
//  Settings: appearance, about, and app info.
//

import SwiftUI

enum AppearanceMode: String, CaseIterable, Identifiable {

    // MARK: - Cases

    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

struct SettingsView: View {

    // MARK: - Properties

    @AppStorage("appearanceMode") private var appearanceModeRaw = AppearanceMode.system.rawValue

    private var appearanceMode: AppearanceMode {
        get { AppearanceMode(rawValue: appearanceModeRaw) ?? .system }
        nonmutating set { appearanceModeRaw = newValue.rawValue }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    sectionHeader("Appearance")
                    appearanceSection

                    sectionHeader("About")
                    aboutSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .scrollContentBackground(.hidden)
            .background(TaskFlowTheme.background)
            .navigationTitle("Settings")
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

    private var appearanceSection: some View {
        VStack(spacing: 0) {
            ForEach(AppearanceMode.allCases) { mode in
                Button {
                    appearanceModeRaw = mode.rawValue
                } label: {
                    HStack {
                        Text(mode.rawValue)
                            .foregroundStyle(TaskFlowTheme.label)
                        Spacer()
                        if appearanceMode.id == mode.id {
                            Image(systemName: "checkmark")
                                .foregroundStyle(TaskFlowTheme.accent)
                                .fontWeight(.medium)
                        }
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(TaskFlowTheme.secondaryBackground)
                }
                .buttonStyle(.plain)
                if mode != AppearanceMode.allCases.last {
                    Divider()
                        .background(TaskFlowTheme.secondaryBackground)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Version")
                    .foregroundStyle(TaskFlowTheme.secondaryLabel)
                Spacer()
                Text(appVersion)
                    .foregroundStyle(TaskFlowTheme.label)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(TaskFlowTheme.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Text("TaskFlow is a simple task and habit tracker. All data stays on your device.")
                .font(.footnote)
                .foregroundStyle(TaskFlowTheme.secondaryLabel)
                .padding(.top, 4)
        }
    }

    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(v) (\(b))"
    }
}

#Preview {
    SettingsView()
}
