import SwiftData
import SwiftUI

struct AchievementsView: View {
    @Query(sort: \Achievement.id) private var achievements: [Achievement]
    @Query(sort: \Lesson.sortOrder) private var lessons: [Lesson]
    @Query private var progressRecords: [UserProgress]

    private var unlockedCount: Int {
        achievements.filter(\.isUnlocked).count
    }

    private var progressPercentage: Double {
        guard !achievements.isEmpty else { return 0 }
        return Double(unlockedCount) / Double(achievements.count)
    }

    private let columns = [
        GridItem(.adaptive(minimum: 220), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                summaryCard

                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(achievements) { achievement in
                        AchievementCard(
                            achievement: achievement,
                            progressHint: progressHint(for: achievement)
                        )
                    }
                }
            }
            .padding(28)
            .frame(maxWidth: 880, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .navigationTitle("Achievements")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Achievements")
                .font(.system(size: 30, weight: .bold))

            Text("Milestones on your way to Mac mastery.")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }

    private var summaryCard: some View {
        CardView(padding: 22, hoverLift: false) {
            HStack(spacing: 22) {
                ProgressRing(
                    progress: progressPercentage,
                    lineWidth: 10,
                    size: 76,
                    tint: .orange
                )

                VStack(alignment: .leading, spacing: 6) {
                    Text("\(unlockedCount) of \(achievements.count) badges unlocked")
                        .font(.headline)

                    Text(motivationalText)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
        }
    }

    private var motivationalText: String {
        let percent = progressPercentage
        if percent == 0 {
            return "Complete lessons to unlock your first badge."
        } else if percent < 0.5 {
            return "Off to a solid start — keep practicing daily."
        } else if percent < 1.0 {
            return "Over halfway there. You're becoming a power user."
        } else {
            return "Incredible — you're a certified Mac Pilot Master! 🏆"
        }
    }

    /// A short "how far to go" hint for locked badges.
    private func progressHint(for achievement: Achievement) -> String? {
        guard !achievement.isUnlocked else { return nil }

        let completed = lessons.filter(\.isCompleted).count
        let streak = progressRecords.first?.displayStreak ?? 0

        func lessonsToGo(_ target: Int) -> String {
            let remaining = max(0, target - completed)
            return "\(remaining) lesson\(remaining == 1 ? "" : "s") to go"
        }

        func streakToGo(_ target: Int) -> String {
            let remaining = max(0, target - streak)
            return "\(remaining) more day\(remaining == 1 ? "" : "s")"
        }

        switch achievement.id {
        case "first-shortcut": return lessonsToGo(1)
        case "comfort-zone": return lessonsToGo(5)
        case "halfway": return lessonsToGo(AchievementService.halfwayThreshold(totalLessons: lessons.count))
        case "master": return lessonsToGo(lessons.count)
        case "streak-3": return streakToGo(3)
        case "streak-7": return streakToGo(7)
        default: return nil
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    var progressHint: String?

    @State private var isHovered = false

    var body: some View {
        VStack(spacing: 14) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .stroke(
                        achievement.isUnlocked
                            ? AnyShapeStyle(gradientColor.opacity(0.2))
                            : AnyShapeStyle(Color.gray.opacity(0.1)),
                        lineWidth: 4
                    )
                    .frame(width: 76, height: 76)

                Circle()
                    .fill(
                        achievement.isUnlocked
                            ? AnyShapeStyle(LinearGradient(
                                colors: [gradientColor, gradientColor.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                              ))
                            : AnyShapeStyle(Color.gray.opacity(0.15))
                    )
                    .frame(width: 68, height: 68)
                    .shadow(
                        color: achievement.isUnlocked
                            ? gradientColor.opacity(isHovered ? 0.5 : 0.3)
                            : .clear,
                        radius: isHovered ? 8 : 4,
                        y: isHovered ? 4 : 2
                    )

                Image(systemName: achievement.symbolName)
                    .font(.system(size: 30, weight: .medium))
                    .foregroundStyle(achievement.isUnlocked ? .white : .secondary)
                    .frame(width: 68, height: 68)

                if !achievement.isUnlocked {
                    Circle()
                        .fill(.regularMaterial)
                        .frame(width: 22, height: 22)
                        .overlay {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.secondary)
                        }
                        .shadow(color: .black.opacity(0.1), radius: 2)
                }
            }
            .scaleEffect(isHovered && achievement.isUnlocked ? 1.08 : 1.0)
            .animation(.spring(duration: 0.3), value: isHovered)

            VStack(spacing: 5) {
                Text(achievement.title)
                    .font(.headline)
                    .foregroundStyle(achievement.isUnlocked ? .primary : .secondary)
                    .multilineTextAlignment(.center)

                Text(achievement.detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 34, alignment: .top)

                if achievement.isUnlocked, let date = achievement.unlockedAt {
                    MetaChip(
                        text: "Unlocked \(date.formatted(date: .abbreviated, time: .omitted))",
                        systemImage: "checkmark",
                        tint: gradientColor
                    )
                } else if let progressHint {
                    MetaChip(text: progressHint, systemImage: "hourglass", tint: .secondary)
                } else {
                    MetaChip(text: "Locked", systemImage: "lock", tint: .secondary)
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(
            .background.secondary,
            in: RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous)
                .strokeBorder(.separator.opacity(0.4))
        }
        .shadow(color: .black.opacity(isHovered ? 0.07 : 0.03), radius: isHovered ? 9 : 4, y: 2)
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.spring(duration: 0.3), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }

    private var gradientColor: Color {
        switch achievement.id {
        case "first-shortcut": return .blue
        case "comfort-zone": return .green
        case "halfway": return .orange
        case "master": return .purple
        case "streak-3": return .pink
        case "streak-7": return .red
        case "polymath": return .yellow
        default: return .blue
        }
    }
}
