import SwiftData
import SwiftUI

struct HomeView: View {
    @Binding var selection: SidebarItem?
    @State private var isVisible = false
    @Query(sort: \Lesson.sortOrder) private var lessons: [Lesson]
    @Query private var progressRecords: [UserProgress]

    private var progress: UserProgress? {
        progressRecords.first
    }

    private var viewModel: DashboardViewModel {
        DashboardViewModel(lessons: lessons, progress: progress)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 16)

                metrics
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 16)
                    .animation(.easeOut(duration: 0.5).delay(0.1), value: isVisible)

                todaysPlan
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 16)
                    .animation(.easeOut(duration: 0.5).delay(0.2), value: isVisible)

                ReviewCard()
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 16)
                    .animation(.easeOut(duration: 0.5).delay(0.25), value: isVisible)

                continueLearning
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 16)
                    .animation(.easeOut(duration: 0.5).delay(0.3), value: isVisible)

                gettingStarted
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 16)
                    .animation(.easeOut(duration: 0.5).delay(0.4), value: isVisible)
            }
            .padding(28)
            .frame(maxWidth: 1040, alignment: .leading)
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .navigationTitle("Home")
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                isVisible = true
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(greeting)
                .font(.largeTitle.weight(.semibold))

            Text(viewModel.welcomeSubtitle)
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }

    private var metrics: some View {
        Grid(horizontalSpacing: 14, verticalSpacing: 14) {
            GridRow {
                MetricTile(
                    title: "Lessons completed",
                    value: "\(viewModel.completedLessons)/\(lessons.count)",
                    systemImage: "checkmark.circle",
                    tint: .green
                )

                MetricTile(
                    title: "Current streak",
                    value: "\(progress?.currentStreak ?? 0) days",
                    systemImage: "flame",
                    tint: .orange
                )

                MetricTile(
                    title: "Overall progress",
                    value: "\(Int(viewModel.completionRatio * 100))%",
                    systemImage: "chart.pie",
                    tint: .blue
                )
            }
        }
    }

    private var continueLearning: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Continue learning")
                            .font(.headline)

                        Text(viewModel.nextLesson?.title ?? "No lessons yet")
                            .font(.title2.weight(.semibold))

                        Text(viewModel.nextLesson?.summary ?? "New lessons will appear here.")
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: viewModel.nextLesson?.symbolName ?? "command")
                        .font(.system(size: 34, weight: .medium))
                        .foregroundStyle(.blue)
                }

                ProgressView(value: viewModel.completionRatio)
                    .tint(.blue)

                HStack {
                    Label(viewModel.dailyGoalText, systemImage: viewModel.completedToday ? "checkmark.seal.fill" : "target")
                        .font(.callout.weight(.medium))
                        .foregroundStyle(viewModel.completedToday ? .green : .secondary)

                    Spacer()
                }

                Label(viewModel.migrationSummary, systemImage: "person.crop.circle.badge.checkmark")
                    .font(.callout)
                    .foregroundStyle(.secondary)

                Button {
                    selection = .lessons
                } label: {
                    Label("Open Lessons", systemImage: "arrow.right.circle")
                }
                .buttonStyle(BorderedProminentButtonStyle())
            }
        }
    }

    private var todaysPlan: some View {
        CardView {
            HStack(alignment: .top, spacing: 18) {
                Image(systemName: viewModel.completedToday ? "checkmark.seal.fill" : "target")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(viewModel.completedToday ? .green : .blue)
                    .frame(width: 56, height: 56)
                    .background((viewModel.completedToday ? Color.green : Color.blue).opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

                VStack(alignment: .leading, spacing: 10) {
                    Text(viewModel.todayPlanTitle)
                        .font(.headline)

                    Text(viewModel.nextLesson?.title ?? "No lesson available")
                        .font(.title2.weight(.semibold))

                    Text(viewModel.recommendationReason)
                        .foregroundStyle(.secondary)

                    Label(viewModel.todayPlanStatus, systemImage: viewModel.completedToday ? "checkmark.circle" : "clock")
                        .font(.callout.weight(.medium))
                        .foregroundStyle(viewModel.completedToday ? .green : .secondary)
                }

                Spacer()

                Button {
                    selection = .lessons
                } label: {
                    Label("Start", systemImage: "play.circle")
                }
                .buttonStyle(BorderedProminentButtonStyle())
                .disabled(lessons.isEmpty)
            }
        }
    }

    private var gettingStarted: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Beginner path")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 260), spacing: 14)], spacing: 14) {
                HomeTip(
                    title: "Start with Command",
                    message: "Most Ctrl shortcuts become Command shortcuts on Mac.",
                    systemImage: "command"
                )

                HomeTip(
                    title: "Use the trackpad",
                    message: "Two and three finger gestures replace a lot of window management clicks.",
                    systemImage: "hand.tap"
                )

                HomeTip(
                    title: "Practice daily",
                    message: "Finishing one short lesson keeps your streak alive.",
                    systemImage: "calendar.badge.clock"
                )
            }
        }
    }
}

private struct HomeTip: View {
    let title: String
    let message: String
    let systemImage: String

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: systemImage)
                    .font(.title2)
                    .foregroundStyle(.blue)

                Text(title)
                    .font(.headline)

                Text(message)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .frame(minHeight: 112, alignment: .topLeading)
        }
    }
}
