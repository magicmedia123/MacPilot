import Foundation

struct DashboardViewModel {
    let lessons: [Lesson]
    let progress: UserProgress?

    var completedLessons: Int {
        lessons.filter(\.isCompleted).count
    }

    var completionRatio: Double {
        guard !lessons.isEmpty else { return 0 }
        return Double(completedLessons) / Double(lessons.count)
    }

    var dailyGoalText: String {
        completedToday ? "Daily goal complete" : "Complete 1 lesson today"
    }

    var completedToday: Bool {
        guard let lastPracticeDate = progress?.lastPracticeDate else { return false }
        return Calendar.current.isDateInToday(lastPracticeDate)
    }

    var nextLesson: Lesson? {
        lessons.first { !$0.isCompleted } ?? lessons.first
    }
}
