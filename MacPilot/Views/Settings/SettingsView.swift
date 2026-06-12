import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Lesson.sortOrder) private var lessons: [Lesson]
    @Query private var progressRecords: [UserProgress]
    @State private var showsResetConfirmation = false

    @AppStorage("appearanceMode") private var appearanceMode = AppearanceMode.system

    private var viewModel: SettingsViewModel {
        SettingsViewModel(lessons: lessons, progress: progressRecords.first)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                appearance
                learningData
                about
            }
            .padding(28)
            .frame(maxWidth: 820, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .navigationTitle("Settings")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Settings")
                .font(.system(size: 30, weight: .bold))

            Text("Appearance and local learning data.")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }

    private var appearance: some View {
        CardView(padding: 20) {
            VStack(alignment: .leading, spacing: 14) {
                Label("Appearance", systemImage: "paintbrush")
                    .font(.headline)

                Picker("Appearance", selection: $appearanceMode) {
                    ForEach(AppearanceMode.allCases) { mode in
                        Label(mode.rawValue, systemImage: mode.symbolName)
                            .tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()

                Text("System follows your Mac's appearance setting.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    private var learningData: some View {
        CardView(padding: 20) {
            VStack(alignment: .leading, spacing: 15) {
                Label("Learning data", systemImage: "internaldrive")
                    .font(.headline)

                HStack {
                    Label("\(viewModel.completedCount) completed lessons", systemImage: "checkmark.circle")

                    Spacer()

                    Label("Stored locally", systemImage: "lock")
                        .foregroundStyle(.secondary)
                        .help("All progress stays on this Mac. Nothing is uploaded.")
                }

                if let profileSummary = viewModel.profileSummary {
                    Label(profileSummary, systemImage: "person.crop.circle")
                        .foregroundStyle(.secondary)
                }

                Divider()

                HStack {
                    Button {
                        viewModel.showOnboardingAgain()
                    } label: {
                        Label("Show Onboarding Again", systemImage: "sparkles")
                    }
                    .buttonStyle(.bordered)

                    Button(role: .destructive) {
                        showsResetConfirmation = true
                    } label: {
                        Label("Reset Progress", systemImage: "arrow.counterclockwise")
                    }
                    .buttonStyle(.bordered)
                    .confirmationDialog(
                        "Reset all progress?",
                        isPresented: $showsResetConfirmation,
                        titleVisibility: .visible
                    ) {
                        Button("Reset Everything", role: .destructive) {
                            viewModel.resetLessonProgress(in: modelContext)
                        }
                    } message: {
                        Text("This erases all lesson completions, streaks, scheduled reviews, and achievements. It cannot be undone.")
                    }
                }
            }
        }
    }

    private var about: some View {
        CardView(padding: 20) {
            HStack(spacing: 16) {
                Image(systemName: "command")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(AppTheme.accentGradient, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .shadow(color: .blue.opacity(0.3), radius: 4, y: 2)

                VStack(alignment: .leading, spacing: 4) {
                    Text("MacPilot")
                        .font(.headline)

                    Text("Short, focused lessons that turn Windows muscle memory into Mac fluency.")
                        .font(.callout)
                        .foregroundStyle(.secondary)

                    Text("Version \(appVersion)")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }

                Spacer()
            }
        }
    }

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }
}
