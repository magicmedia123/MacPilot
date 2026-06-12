import SwiftData
import SwiftUI

struct ProgressDashboardView: View {
    @Query(sort: \Lesson.sortOrder) private var lessons: [Lesson]
    @Query private var progressRecords: [UserProgress]
    @State private var animateProgress = false

    private var progress: UserProgress? {
        progressRecords.first
    }

    private var viewModel: ProgressViewModel {
        ProgressViewModel(lessons: lessons, progress: progress)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                summaryGrid
                categoryBreakdown
                recentCompletions
            }
            .padding(28)
            .frame(maxWidth: 1040, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .navigationTitle("Progress")
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                animateProgress = true
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Progress")
                .font(.system(size: 30, weight: .bold))

            Text("Track your lessons, streaks, and growing Mac fluency.")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }

    private var summaryGrid: some View {
        Grid(horizontalSpacing: 14, verticalSpacing: 14) {
            GridRow {
                MetricTile(
                    title: "Lessons completed",
                    value: "\(viewModel.completedLessons.count)",
                    systemImage: "checkmark.circle.fill",
                    tint: .green
                )

                MetricTile(
                    title: "Current streak",
                    value: "\(progress?.displayStreak ?? 0) day\((progress?.displayStreak ?? 0) == 1 ? "" : "s")",
                    systemImage: "flame.fill",
                    tint: .orange
                )

                MetricTile(
                    title: "Best streak",
                    value: "\(progress?.bestStreak ?? 0) day\((progress?.bestStreak ?? 0) == 1 ? "" : "s")",
                    systemImage: "rosette",
                    tint: .purple
                )
            }
        }
    }

    private var categoryBreakdown: some View {
        CardView(padding: 22) {
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 16) {
                    ProgressRing(
                        progress: viewModel.completionRatio,
                        lineWidth: 8,
                        size: 64,
                        tint: .blue
                    )

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Overall progress")
                            .font(.headline)

                        Text("\(viewModel.completedLessons.count) of \(lessons.count) lessons completed")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }

                Divider()

                ForEach(LessonCategory.allCases) { category in
                    CategoryProgressRow(
                        category: category,
                        completed: viewModel.completedCount(for: category),
                        total: viewModel.totalCount(for: category),
                        animate: animateProgress
                    )
                }
            }
        }
    }

    private var recentCompletions: some View {
        CardView(padding: 22) {
            VStack(alignment: .leading, spacing: 14) {
                Text("Recently completed")
                    .font(.headline)

                if viewModel.completedLessons.isEmpty {
                    HStack(spacing: 10) {
                        Image(systemName: "sparkles")
                            .foregroundStyle(.tertiary)

                        Text("Complete your first lesson to start building momentum.")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    let recent = viewModel.completedLessons
                        .sorted { ($0.completedAt ?? .distantPast) > ($1.completedAt ?? .distantPast) }
                        .prefix(8)

                    ForEach(Array(recent)) { lesson in
                        HStack(spacing: 12) {
                            IconTile(systemImage: lesson.symbolName, tint: lesson.category.tint, size: 30, cornerRadius: 7)

                            VStack(alignment: .leading, spacing: 1) {
                                Text(lesson.title)
                                    .font(.body.weight(.medium))

                                Text(lesson.category.shortName)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if let completedAt = lesson.completedAt {
                                Text(completedAt.formatted(.relative(presentation: .named)))
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
    }
}

private struct CategoryProgressRow: View {
    let category: LessonCategory
    let completed: Int
    let total: Int
    var animate: Bool = true

    private var ratio: Double {
        guard total > 0 else { return 0 }
        return Double(completed) / Double(total)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 9) {
                IconTile(systemImage: category.symbolName, tint: category.tint, size: 22, cornerRadius: 6)

                Text(category.rawValue)
                    .font(.callout.weight(.medium))

                Spacer()

                Text("\(completed)/\(total)")
                    .font(.callout.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: animate ? ratio : 0)
                .tint(category.tint)
        }
    }
}
