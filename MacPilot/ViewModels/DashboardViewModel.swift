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

    var todayPlanTitle: String {
        completedToday ? "Keep the streak warm" : "Today's plan"
    }

    var todayPlanStatus: String {
        completedToday ? "You already completed today's goal." : "Finish one short lesson to keep momentum."
    }

    var completedToday: Bool {
        guard let lastPracticeDate = progress?.lastPracticeDate else { return false }
        return Calendar.current.isDateInToday(lastPracticeDate)
    }

    var nextLesson: Lesson? {
        // If there's an incomplete lesson matching their learning goal, recommend that first.
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
        
        // Recommend based on Windows apps background
        let appsUsed = progress?.windowsAppsUsed ?? ""
        if appsUsed.contains("VS Code") || appsUsed.contains("Sublime") {
            if let targetLesson = lessons.first(where: { $0.id == "shortcut-text-power" && !$0.isCompleted }) {
                return targetLesson
            }
        }
        
        if appsUsed.contains("Excel") || appsUsed.contains("Word") {
            if let targetLesson = lessons.first(where: { $0.id == "shortcut-select-all" && !$0.isCompleted }) {
                return targetLesson
            }
        }

        // Filter incomplete lessons by their experience level
        let incompleteLessons = lessons.filter { !$0.isCompleted }
        if let experience = progress?.macExperienceLevel {
            let targetDifficulty: LessonDifficulty
            if experience.contains("Beginner") {
                targetDifficulty = .beginner
            } else if experience.contains("Comfortable") {
                targetDifficulty = .comfortable
            } else {
                targetDifficulty = .advanced
            }
            
            if let match = incompleteLessons.first(where: { $0.difficulty == targetDifficulty }) {
                return match
            }
        }

        return incompleteLessons.first ?? lessons.first
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

    var recommendationReason: String {
        guard let next = nextLesson else {
            return "Recommended as a quick everyday shortcut habit."
        }
        
        if next.isCompleted {
            return "All lessons completed! Try reviewing this lesson to practice."
        }
        
        if progress?.learningGoal == "Screenshots" && next.id == "shortcut-screenshots" {
            return "Recommended because you chose screenshots as your first focus."
        }
        if progress?.learningGoal == "Find files and apps" && next.id == "shortcut-spotlight" {
            return "Recommended because Spotlight helps replace Windows search habits."
        }
        if progress?.learningGoal == "Switch apps faster" && next.id == "shortcut-app-switching" {
            return "Recommended because app switching is core Mac navigation."
        }
        
        let appsUsed = progress?.windowsAppsUsed ?? ""
        if (appsUsed.contains("VS Code") || appsUsed.contains("Sublime")) && next.id == "shortcut-text-power" {
            return "Recommended because advanced text selection is vital for developers migrating from Windows."
        }
        if (appsUsed.contains("Excel") || appsUsed.contains("Word")) && next.id == "shortcut-select-all" {
            return "Recommended because this shortcut is a daily standard in office apps."
        }
        
        if let experience = progress?.macExperienceLevel {
            if experience.contains("Beginner") && next.difficulty == .beginner {
                return "Recommended for your Beginner experience level to build core confidence."
            }
            if experience.contains("Advanced") && next.difficulty == .advanced {
                return "Recommended because you have advanced computer experience and are ready for power features."
            }
        }
        
        return "Recommended for your current learning path."
    }
}
