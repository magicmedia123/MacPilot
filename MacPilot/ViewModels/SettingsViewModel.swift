import Foundation
import SwiftData

struct SettingsViewModel {
    let lessons: [Lesson]
    let progress: UserProgress?

    var completedCount: Int {
        lessons.filter(\.isCompleted).count
    }

    var profileSummary: String? {
        guard let experience = progress?.macExperienceLevel,
              let apps = progress?.windowsAppsUsed,
              let goal = progress?.learningGoal else {
            return nil
        }

        return "\(experience) Mac learner. Focus: \(goal). Apps: \(apps)."
    }

    /// Resets every piece of learning state: lesson completions, streaks,
    /// scheduled reviews, and unlocked achievements.
    @MainActor
    func resetLessonProgress(in modelContext: ModelContext) {
        lessons.forEach { lesson in
            lesson.isCompleted = false
            lesson.completedAt = nil
        }

        progress?.completedLessonCount = 0
        progress?.currentStreak = 0
        progress?.bestStreak = 0
        progress?.lastPracticeDate = nil

        if let reviewItems = try? modelContext.fetch(FetchDescriptor<ReviewItem>()) {
            reviewItems.forEach { modelContext.delete($0) }
        }

        if let achievements = try? modelContext.fetch(FetchDescriptor<Achievement>()) {
            achievements.forEach {
                $0.isUnlocked = false
                $0.unlockedAt = nil
            }
        }

        try? modelContext.save()
    }

    @MainActor
    func showOnboardingAgain() {
        progress?.hasCompletedOnboarding = false
    }
}
