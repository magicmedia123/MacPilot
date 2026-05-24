import Foundation
import SwiftData

struct SettingsViewModel {
    let lessons: [Lesson]
    let progress: UserProgress?

    var completedCount: Int {
        lessons.filter(\.isCompleted).count
    }

    @MainActor
    func resetLessonProgress() {
        lessons.forEach { lesson in
            lesson.isCompleted = false
            lesson.completedAt = nil
        }

        progress?.completedLessonCount = 0
        progress?.currentStreak = 0
        progress?.bestStreak = 0
        progress?.lastPracticeDate = nil
    }

    @MainActor
    func showOnboardingAgain() {
        progress?.hasCompletedOnboarding = false
    }
}
