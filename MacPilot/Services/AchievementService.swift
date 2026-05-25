import Foundation
import SwiftData

struct AchievementService {
    @MainActor
    static func checkAndUnlockAchievements(modelContext: ModelContext, lessons: [Lesson], progress: UserProgress) {
        let descriptor = FetchDescriptor<Achievement>()
        guard let achievements = try? modelContext.fetch(descriptor) else { return }
        
        let completedLessons = lessons.filter { $0.isCompleted }
        let completedCount = completedLessons.count
        
        for achievement in achievements {
            if achievement.isUnlocked { continue }
            
            var shouldUnlock = false
            
            switch achievement.id {
            case "first-shortcut":
                shouldUnlock = completedCount >= 1
            case "comfort-zone":
                shouldUnlock = completedCount >= 5
            case "halfway":
                shouldUnlock = completedCount >= 12
            case "master":
                shouldUnlock = completedCount >= 25
            case "streak-3":
                shouldUnlock = progress.currentStreak >= 3
            case "streak-7":
                shouldUnlock = progress.currentStreak >= 7
            case "polymath":
                // 3 lessons completed in a single day
                // Group completed lessons by day and find if any day has >= 3 completions
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
                print("🏆 Unlocked Achievement: \(achievement.title)!")
            }
        }
        
        try? modelContext.save()
    }
}
