import SwiftData
import SwiftUI

struct SettingsView: View {
    @Query(sort: \Lesson.sortOrder) private var lessons: [Lesson]
    @Query private var progressRecords: [UserProgress]

    private var viewModel: SettingsViewModel {
        SettingsViewModel(lessons: lessons, progress: progressRecords.first)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header
                learningData
                about
            }
            .padding(28)
            .frame(maxWidth: 820, alignment: .leading)
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .navigationTitle("Settings")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Settings")
                .font(.largeTitle.weight(.semibold))

            Text("Manage your local MacPilot learning data.")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }

    private var learningData: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Learning data")
                    .font(.headline)

                HStack {
                    Label("\(viewModel.completedCount) completed lessons", systemImage: "checkmark.circle")
                    Spacer()
                    Label("Stored locally", systemImage: "lock")
                        .foregroundStyle(.secondary)
                }

                Divider()

                HStack {
                    Button {
                        viewModel.showOnboardingAgain()
                    } label: {
                        Label("Show Onboarding Again", systemImage: "sparkles")
                    }
                    .buttonStyle(BorderedButtonStyle())

                    Button(role: .destructive) {
                        viewModel.resetLessonProgress()
                    } label: {
                        Label("Reset Progress", systemImage: "arrow.counterclockwise")
                    }
                    .buttonStyle(BorderedButtonStyle())
                }
            }
        }
    }

    private var about: some View {
        CardView {
            VStack(alignment: .leading, spacing: 10) {
                Text("About MacPilot")
                    .font(.headline)

                Text("MacPilot helps Windows users build Mac muscle memory through short, focused lessons.")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
