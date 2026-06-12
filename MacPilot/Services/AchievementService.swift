import Foundation
import SwiftData

struct AchievementService {
    /// Lesson-count thresholds derived from the catalog size so they stay
    /// correct as lessons are added or removed.
    static func halfwayThreshold(totalLessons: Int) -> Int {
        max(1, Int((Double(totalLessons) / 2).rounded()))
    }

    @MainActor
    static func checkAndUnlockAchievements(modelContext: ModelContext, lessons: [Lesson], progress: UserProgress) {
        let descriptor = FetchDescriptor<Achievement>()
        guard let achievements = try? modelContext.fetch(descriptor) else { return }

        let completedLessons = lessons.filter { $0.isCompleted }
        let completedCount = completedLessons.count
        let totalCount = lessons.count

        for achievement in achievements {
            if achievement.isUnlocked { continue }

            var shouldUnlock = false

            switch achievement.id {
            case "first-shortcut":
                shouldUnlock = completedCount >= 1
            case "comfort-zone":
                shouldUnlock = completedCount >= 5
            case "halfway":
                shouldUnlock = completedCount >= halfwayThreshold(totalLessons: totalCount)
            case "master":
                shouldUnlock = totalCount > 0 && completedCount >= totalCount
            case "streak-3":
                shouldUnlock = progress.currentStreak >= 3
            case "streak-7":
                shouldUnlock = progress.currentStreak >= 7
            case "polymath":
                // Three lessons completed within a single calendar day.
                let calendar = Calendar.current
                let grouped = Dictionary(grouping: completedLessons) { lesson in
                    calendar.startOfDay(for: lesson.completedAt ?? .distantPast)
                }
                shouldUnlock = grouped.values.contains { $0.count >= 3 }
            default:
                break
            }

            if shouldUnlock {
                achievement.isUnlocked = true
                achievement.unlockedAt = .now
            }
        }

        try? modelContext.save()
    }
}
