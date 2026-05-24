import Foundation
import SwiftData

@Model
final class UserProgress {
    @Attribute(.unique) var id: String
    var hasCompletedOnboarding: Bool
    var completedLessonCount: Int
    var currentStreak: Int
    var bestStreak: Int
    var lastPracticeDate: Date?
    var createdAt: Date

    init(
        id: String = "primary-progress",
        hasCompletedOnboarding: Bool = false,
        completedLessonCount: Int = 0,
        currentStreak: Int = 0,
        bestStreak: Int = 0,
        lastPracticeDate: Date? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.completedLessonCount = completedLessonCount
        self.currentStreak = currentStreak
        self.bestStreak = bestStreak
        self.lastPracticeDate = lastPracticeDate
        self.createdAt = createdAt
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
    }

    func recordLessonCompletion() {
        completedLessonCount += 1
        updateStreak(for: .now)
    }

    func removeLessonCompletion() {
        completedLessonCount = max(0, completedLessonCount - 1)
    }

    private func updateStreak(for date: Date) {
        let calendar = Calendar.current

        guard let lastPracticeDate else {
            currentStreak = 1
            bestStreak = max(bestStreak, currentStreak)
            self.lastPracticeDate = date
            return
        }

        if calendar.isDate(lastPracticeDate, inSameDayAs: date) {
            return
        }

        if let yesterday = calendar.date(byAdding: .day, value: -1, to: date),
           calendar.isDate(lastPracticeDate, inSameDayAs: yesterday) {
            currentStreak += 1
        } else {
            currentStreak = 1
        }

        bestStreak = max(bestStreak, currentStreak)
        self.lastPracticeDate = date
    }
}
