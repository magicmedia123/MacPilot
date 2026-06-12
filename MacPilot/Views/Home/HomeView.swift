import SwiftData
import SwiftUI

struct HomeView: View {
    @Environment(AppRouter.self) private var router
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

    /// Days on which the user practiced, derived from lesson completions
    /// and the recorded last practice date.
    private var practicedDays: Set<Date> {
        let calendar = Calendar.current
        var days = Set(lessons.compactMap { lesson in
            lesson.completedAt.map { calendar.startOfDay(for: $0) }
        })
        if let lastPractice = progress?.lastPracticeDate {
            days.insert(calendar.startOfDay(for: lastPractice))
        }
        return days
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                hero
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 16)

                upNext
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 16)
                    .animation(.easeOut(duration: 0.5).delay(0.1), value: isVisible)

                ReviewCard()
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 16)
                    .animation(.easeOut(duration: 0.5).delay(0.2), value: isVisible)

                gettingStarted
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 16)
                    .animation(.easeOut(duration: 0.5).delay(0.3), value: isVisible)
            }
            .padding(28)
            .frame(maxWidth: 1040, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .navigationTitle("Home")
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                isVisible = true
            }
        }
    }

    // MARK: - Hero

    private var hero: some View {
        CardView(padding: 24, hoverLift: false) {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(greeting) 👋")
                            .font(.system(size: 30, weight: .bold))

                        Text(viewModel.welcomeSubtitle)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    ProgressRing(
                        progress: viewModel.completionRatio,
                        lineWidth: 9,
                        size: 78,
                        tint: .blue
                    )
                }

                HStack(spacing: 10) {
                    HeroStat(
                        value: "\(viewModel.completedLessons)",
                        label: "lessons done",
                        systemImage: "checkmark.circle.fill",
                        tint: .green
                    )

                    HeroStat(
                        value: "\(progress?.displayStreak ?? 0)",
                        label: "day streak",
                        systemImage: "flame.fill",
                        tint: .orange
                    )

                    HeroStat(
                        value: "\(progress?.bestStreak ?? 0)",
                        label: "best streak",
                        systemImage: "rosette",
                        tint: .purple
                    )

                    Spacer()

                    WeekActivityStrip(practicedDays: practicedDays)
                }
            }
        }
    }

    // MARK: - Up next

    @ViewBuilder
    private var upNext: some View {
        if viewModel.allLessonsCompleted {
            allDoneCard
        } else if let lesson = viewModel.nextLesson {
            upNextCard(for: lesson)
        }
    }

    private func upNextCard(for lesson: Lesson) -> some View {
        CardView(padding: 22) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.caption.weight(.semibold))
                    Text("Up next")
                        .font(.caption.weight(.bold))
                        .textCase(.uppercase)
                        .kerning(0.6)
                }
                .foregroundStyle(Color.accentColor)

                HStack(alignment: .top, spacing: 16) {
                    IconTile(systemImage: lesson.symbolName, tint: lesson.category.tint, size: 54, cornerRadius: 12)

                    VStack(alignment: .leading, spacing: 7) {
                        Text(lesson.title)
                            .font(.title2.weight(.semibold))

                        Text(lesson.summary)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 7) {
                            MetaChip(text: lesson.category.shortName, systemImage: lesson.category.symbolName, tint: lesson.category.tint)
                            DifficultyBadge(difficulty: lesson.difficulty)
                            MetaChip(text: "\(lesson.estimatedMinutes) min", systemImage: "clock")
                        }
                    }

                    Spacer()

                    if let firstStep = lesson.steps.sorted(by: { $0.sortOrder < $1.sortOrder }).first,
                       ShortcutParser.keycapGroups(from: firstStep.macAction, style: .mac) != nil {
                        ShortcutDisplay(text: firstStep.macAction, style: .mac)
                            .padding(.top, 4)
                    }
                }

                Label(viewModel.recommendationReason, systemImage: "lightbulb")
                    .font(.callout)
                    .foregroundStyle(.secondary)

                Divider()

                HStack {
                    Button {
                        router.openLesson(id: lesson.id)
                    } label: {
                        Label("Start Lesson", systemImage: "play.fill")
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Spacer()

                    Label(
                        viewModel.dailyGoalText,
                        systemImage: viewModel.completedToday ? "checkmark.seal.fill" : "target"
                    )
                    .font(.callout.weight(.medium))
                    .foregroundStyle(viewModel.completedToday ? .green : .secondary)
                }
            }
        }
    }

    private var allDoneCard: some View {
        CardView(padding: 22) {
            HStack(spacing: 18) {
                IconTile(systemImage: "trophy.fill", tint: .orange, size: 54, cornerRadius: 12)

                VStack(alignment: .leading, spacing: 6) {
                    Text("You've completed every lesson! 🎉")
                        .font(.title2.weight(.semibold))

                    Text("Keep your Mac muscle memory sharp with spaced repetition reviews, or browse the cheat sheet anytime.")
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    router.selection = .cheatSheet
                } label: {
                    Label("Cheat Sheet", systemImage: "command")
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
    }

    // MARK: - Tips

    private var gettingStarted: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tips for switchers")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 260), spacing: 14)], spacing: 14) {
                HomeTip(
                    title: "Start with Command",
                    message: "Most Ctrl shortcuts become Command shortcuts on Mac — your fingers already know the patterns.",
                    systemImage: "command",
                    tint: .blue
                )

                HomeTip(
                    title: "Trust the trackpad",
                    message: "Two and three finger gestures replace a lot of window management clicks.",
                    systemImage: "hand.draw.fill",
                    tint: .teal
                )

                HomeTip(
                    title: "Practice daily",
                    message: "Finishing one short lesson keeps your streak alive and builds real muscle memory.",
                    systemImage: "flame.fill",
                    tint: .orange
                )
            }
        }
    }
}

// MARK: - Components

private struct HeroStat: View {
    let value: String
    let label: String
    let systemImage: String
    let tint: Color

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: systemImage)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(tint)

            Text(value)
                .font(.system(.body, design: .rounded).weight(.bold))
                .contentTransition(.numericText())

            Text(label)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 7)
        .background(tint.opacity(0.1), in: Capsule())
    }
}

/// The last seven days as small day markers, filled when the user practiced.
private struct WeekActivityStrip: View {
    let practicedDays: Set<Date>

    private var days: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        return (0..<7).reversed().compactMap {
            calendar.date(byAdding: .day, value: -$0, to: today)
        }
    }

    var body: some View {
        HStack(spacing: 7) {
            ForEach(days, id: \.self) { day in
                let practiced = practicedDays.contains(day)
                let isToday = Calendar.current.isDateInToday(day)

                VStack(spacing: 4) {
                    Text(day, format: .dateTime.weekday(.narrow))
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(isToday ? Color.accentColor : Color.secondary)

                    ZStack {
                        Circle()
                            .fill(practiced ? AnyShapeStyle(Color.green) : AnyShapeStyle(.quaternary))
                            .frame(width: 19, height: 19)

                        if practiced {
                            Image(systemName: "checkmark")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                    .overlay {
                        if isToday {
                            Circle()
                                .strokeBorder(Color.accentColor, lineWidth: 1.5)
                                .frame(width: 25, height: 25)
                        }
                    }
                }
            }
        }
        .help("Your practice activity over the last 7 days")
    }
}

private struct HomeTip: View {
    let title: String
    let message: String
    let systemImage: String
    let tint: Color

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 10) {
                IconTile(systemImage: systemImage, tint: tint, size: 34, cornerRadius: 8)

                Text(title)
                    .font(.headline)

                Text(message)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(minHeight: 118, alignment: .topLeading)
        }
    }
}
