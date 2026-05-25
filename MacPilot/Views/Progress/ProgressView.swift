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
            VStack(alignment: .leading, spacing: 22) {
                header
                summaryGrid
                categoryBreakdown
                recentCompletions
            }
            .padding(28)
            .frame(maxWidth: 1040, alignment: .leading)
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
        VStack(alignment: .leading, spacing: 8) {
            Text("Progress")
                .font(.largeTitle.weight(.semibold))

            Text("Track your lessons, streak, and growing Mac fluency.")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }

    private var summaryGrid: some View {
        Grid(horizontalSpacing: 14, verticalSpacing: 14) {
            GridRow {
                MetricTile(
                    title: "Completed",
                    value: "\(viewModel.completedLessons.count)",
                    systemImage: "checkmark.circle",
                    tint: .green
                )

                MetricTile(
                    title: "Current streak",
                    value: "\(progress?.currentStreak ?? 0)",
                    systemImage: "flame",
                    tint: .orange
                )

                MetricTile(
                    title: "Best streak",
                    value: "\(progress?.bestStreak ?? 0)",
                    systemImage: "rosette",
                    tint: .purple
                )
            }
        }
    }

    private var categoryBreakdown: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Learning progress")
                        .font(.headline)

                    Spacer()

                    Text("\(Int(viewModel.completionRatio * 100))%")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }

                ProgressView(value: animateProgress ? viewModel.completionRatio : 0)
                    .tint(.blue)

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
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Recently completed")
                    .font(.headline)

                if viewModel.completedLessons.isEmpty {
                    Text("Complete your first lesson to start building momentum.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.completedLessons.sorted { ($0.completedAt ?? .distantPast) > ($1.completedAt ?? .distantPast) }) { lesson in
                        HStack {
                            Label(lesson.title, systemImage: "checkmark.circle.fill")
                                .foregroundStyle(.green)

                            Spacer()

                            if let completedAt = lesson.completedAt {
                                Text(completedAt, style: .date)
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
            HStack {
                Label(category.rawValue, systemImage: category.symbolName)

                Spacer()

                Text("\(completed)/\(total)")
                    .foregroundStyle(.secondary)
            }
            .font(.callout)

            ProgressView(value: animate ? ratio : 0)
                .tint(.blue)
        }
    }
}
