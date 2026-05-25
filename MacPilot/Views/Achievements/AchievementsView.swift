import SwiftData
import SwiftUI

struct AchievementsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Achievement.id) private var achievements: [Achievement]

    private var unlockedCount: Int {
        achievements.filter(\.isUnlocked).count
    }

    private var progressPercentage: Double {
        guard !achievements.isEmpty else { return 0 }
        return Double(unlockedCount) / Double(achievements.count)
    }

    private let columns = [
        GridItem(.adaptive(minimum: 220), spacing: 20)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                
                summaryCard
                
                Text("Your Badges")
                    .font(.title2.weight(.semibold))
                    .padding(.top, 8)
                
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(achievements) { achievement in
                        AchievementCard(achievement: achievement)
                    }
                }
            }
            .padding(28)
            .frame(maxWidth: 820, alignment: .leading)
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .navigationTitle("Achievements")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Achievements")
                .font(.largeTitle.weight(.semibold))

            Text("Track your milestones as you build Mac muscle memory.")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }

    private var summaryCard: some View {
        CardView {
            HStack(spacing: 24) {
                ProgressRing(
                    progress: progressPercentage,
                    lineWidth: 12,
                    size: 80,
                    tint: Color.accentColor
                )
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Milestone Progress")
                        .font(.headline)
                    
                    Text("\(unlockedCount) of \(achievements.count) badges unlocked")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text(motivationalText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .italic()
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
        }
    }
    
    private var motivationalText: String {
        let percent = progressPercentage
        if percent == 0 {
            return "Complete lessons to unlock your first badge!"
        } else if percent < 0.5 {
            return "Off to a solid start! Keep practicing daily."
        } else if percent < 1.0 {
            return "Over halfway there! You're becoming a power user."
        } else {
            return "Absolutely incredible! You are a certified Mac Pilot Master! 🏆"
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    @State private var isHovered = false

    var body: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .bottomTrailing) {
                // Outer ring
                Circle()
                    .stroke(
                        achievement.isUnlocked
                            ? AnyShapeStyle(gradientColor.opacity(0.2))
                            : AnyShapeStyle(Color.gray.opacity(0.1)),
                        lineWidth: 4
                    )
                    .frame(width: 76, height: 76)
                
                // Badge circle
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
                
                // Symbol icon
                Image(systemName: achievement.symbolName)
                    .font(.system(size: 30, weight: .medium))
                    .foregroundStyle(achievement.isUnlocked ? .white : .secondary)
                    .frame(width: 68, height: 68)
                
                // Lock overlay if locked
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
                        .transition(.scale)
                }
            }
            .scaleEffect(isHovered && achievement.isUnlocked ? 1.08 : 1.0)
            .animation(.spring(duration: 0.3), value: isHovered)
            
            VStack(spacing: 6) {
                Text(achievement.title)
                    .font(.headline)
                    .foregroundStyle(achievement.isUnlocked ? .primary : .secondary)
                    .multilineTextAlignment(.center)
                
                Text(achievement.detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 36, alignment: .top)
                
                if achievement.isUnlocked, let date = achievement.unlockedAt {
                    Text("Unlocked \(date.formatted(date: .abbreviated, time: .omitted))")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color.accentColor)
                        .padding(.top, 4)
                } else {
                    Text("Locked")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(nsColor: .controlBackgroundColor))
                .shadow(
                    color: .black.opacity(isHovered ? 0.08 : 0.04),
                    radius: isHovered ? 12 : 6,
                    y: isHovered ? 6 : 3
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
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
