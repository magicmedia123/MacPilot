import SwiftData
import SwiftUI

enum SidebarItem: Hashable {
    case home
    case lessons
    case progress
    case achievements
    case settings
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var progressRecords: [UserProgress]
    @State private var selection: SidebarItem? = .home
    @State private var showsOnboarding = false
    @State private var onboardingProgress: UserProgress?

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                NavigationLink(value: SidebarItem.home) {
                    Label("Home", systemImage: "house")
                }

                NavigationLink(value: SidebarItem.lessons) {
                    Label("Lessons", systemImage: "rectangle.stack")
                }

                NavigationLink(value: SidebarItem.progress) {
                    Label("Progress", systemImage: "chart.bar")
                }

                NavigationLink(value: SidebarItem.achievements) {
                    Label("Achievements", systemImage: "trophy")
                }

                NavigationLink(value: SidebarItem.settings) {
                    Label("Settings", systemImage: "gearshape")
                }
            }
            .navigationTitle("MacPilot")
            .listStyle(.sidebar)
        } detail: {
            switch selection {
            case .home:
                HomeView(selection: $selection)
            case .lessons:
                LessonListView()
            case .progress:
                ProgressDashboardView()
            case .achievements:
                AchievementsView()
            case .settings:
                SettingsView()
            case .none:
                HomeView(selection: $selection)
            }
        }
        .task {
            SampleDataSeeder.seedIfNeeded(in: modelContext)

            // Fetch directly after seeding so first launch can present onboarding immediately.
            let descriptor = FetchDescriptor<UserProgress>()
            if let progress = try? modelContext.fetch(descriptor).first {
                onboardingProgress = progress
                showsOnboarding = !progress.hasCompletedOnboarding
            }
        }
        .sheet(isPresented: $showsOnboarding) {
            if let progress = onboardingProgress ?? progressRecords.first {
                OnboardingView(progress: progress)
                    .frame(width: 560, height: 520)
            }
        }
    }
}
