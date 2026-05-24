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
        if progress?.learningGoal == "Screenshots",
           let screenshotLesson = lessons.first(where: { $0.id == "shortcut-screenshots" && !$0.isCompleted }) {
            return screenshotLesson
        }

        if progress?.learningGoal == "Find files and apps",
           let spotlightLesson = lessons.first(where: { $0.id == "shortcut-spotlight" && !$0.isCompleted }) {
            return spotlightLesson
        }

        if progress?.learningGoal == "Switch apps faster",
           let switchingLesson = lessons.first(where: { $0.id == "shortcut-app-switching" && !$0.isCompleted }) {
            return switchingLesson
        }

        return lessons.first { !$0.isCompleted } ?? lessons.first
    }

    var welcomeSubtitle: String {
        guard let experience = progress?.macExperienceLevel else {
            return "A calm practice space for turning Windows muscle memory into Mac confidence."
        }

        return "Personalized for a \(experience.lowercased()) Mac learner moving from Windows."
    }

    var migrationSummary: String {
        let apps = progress?.windowsAppsUsed ?? "Windows apps"
        let goal = progress?.learningGoal ?? "Mac shortcuts"
        return "Focus: \(goal). Windows background: \(apps)."
    }
}
