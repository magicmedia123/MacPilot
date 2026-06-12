import SwiftData
import SwiftUI

enum SidebarItem: Int, CaseIterable, Identifiable {
    case home
    case lessons
    case cheatSheet
    case progress
    case achievements
    case settings

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .home: "Home"
        case .lessons: "Lessons"
        case .cheatSheet: "Cheat Sheet"
        case .progress: "Progress"
        case .achievements: "Achievements"
        case .settings: "Settings"
        }
    }

    var symbolName: String {
        switch self {
        case .home: "house.fill"
        case .lessons: "rectangle.stack.fill"
        case .cheatSheet: "command"
        case .progress: "chart.bar.fill"
        case .achievements: "trophy.fill"
        case .settings: "gearshape.fill"
        }
    }

    var tint: Color {
        switch self {
        case .home: .blue
        case .lessons: .indigo
        case .cheatSheet: .teal
        case .progress: .green
        case .achievements: .orange
        case .settings: .gray
        }
    }

    /// ⌘1 through ⌘6 — a shortcuts app should be navigable by shortcuts.
    var keyEquivalent: KeyEquivalent {
        KeyEquivalent(Character("\(rawValue + 1)"))
    }
}

/// App-wide navigation state. Shared so menu bar commands can drive it.
@Observable
final class AppRouter {
    static let shared = AppRouter()

    var selection: SidebarItem? = .home

    /// Set when another screen asks to open a specific lesson;
    /// LessonListView consumes it and pushes the detail view.
    var pendingLessonID: String?

    func openLesson(id: String) {
        pendingLessonID = id
        selection = .lessons
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var progressRecords: [UserProgress]
    @Query(sort: \Lesson.sortOrder) private var lessons: [Lesson]

    private let router = AppRouter.shared

    @State private var showsOnboarding = false
    @State private var onboardingProgress: UserProgress?

    private var completedCount: Int {
        lessons.filter(\.isCompleted).count
    }

    var body: some View {
        @Bindable var router = router

        NavigationSplitView {
            sidebar(selection: $router.selection)
        } detail: {
            detailView
        }
        .environment(router)
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
                    .frame(width: 600, height: 560)
            }
        }
    }

    private func sidebar(selection: Binding<SidebarItem?>) -> some View {
        List(selection: selection) {
            Section {
                ForEach(SidebarItem.allCases) { item in
                    NavigationLink(value: item) {
                        Label {
                            Text(item.title)
                                .padding(.leading, 2)
                        } icon: {
                            IconTile(systemImage: item.symbolName, tint: item.tint, size: 23, cornerRadius: 6)
                        }
                    }
                    .padding(.vertical, 1)
                }
            } header: {
                brandingHeader
            }
        }
        .listStyle(.sidebar)
        .navigationSplitViewColumnWidth(min: 200, ideal: 225, max: 280)
        .safeAreaInset(edge: .bottom) {
            sidebarFooter
        }
    }

    private var brandingHeader: some View {
        HStack(spacing: 10) {
            Image(systemName: "command")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(AppTheme.accentGradient, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                .shadow(color: .blue.opacity(0.3), radius: 3, y: 1)

            VStack(alignment: .leading, spacing: 1) {
                Text("MacPilot")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text("Windows → Mac")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.bottom, 10)
    }

    private var sidebarFooter: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Text("\(completedCount) of \(lessons.count) lessons")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)

                Spacer()

                if let progress = progressRecords.first, progress.displayStreak > 0 {
                    HStack(spacing: 3) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 10))
                        Text("\(progress.displayStreak)")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(.orange)
                }
            }

            ProgressView(value: lessons.isEmpty ? 0 : Double(completedCount) / Double(lessons.count))
                .tint(.blue)
                .controlSize(.small)
        }
        .padding(12)
        .background(.bar)
        .overlay(alignment: .top) {
            Divider()
        }
    }

    @ViewBuilder
    private var detailView: some View {
        switch router.selection {
        case .home, .none:
            HomeView()
        case .lessons:
            LessonListView()
        case .cheatSheet:
            CheatSheetView()
        case .progress:
            ProgressDashboardView()
        case .achievements:
            AchievementsView()
        case .settings:
            SettingsView()
        }
    }
}
