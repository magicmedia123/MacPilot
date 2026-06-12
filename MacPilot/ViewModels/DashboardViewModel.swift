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

    var completedToday: Bool {
        guard let lastPracticeDate = progress?.lastPracticeDate else { return false }
        return Calendar.current.isDateInToday(lastPracticeDate)
    }

    var allLessonsCompleted: Bool {
        !lessons.isEmpty && lessons.allSatisfy(\.isCompleted)
    }

    var nextLesson: Lesson? {
        recommendation?.lesson
    }

    var recommendationReason: String {
        recommendation?.reason ?? "New lessons will appear here."
    }

    /// Picks the next lesson and the reason for picking it in one place,
    /// so the recommendation and its explanation can never disagree.
    /// Keep the matched strings in sync with the options offered in OnboardingView.
    var recommendation: (lesson: Lesson, reason: String)? {
        let incomplete = lessons
            .filter { !$0.isCompleted }
            .sorted { $0.sortOrder < $1.sortOrder }

        guard !incomplete.isEmpty else {
            // Everything is done; suggest revisiting the first lesson.
            if let first = lessons.sorted(by: { $0.sortOrder < $1.sortOrder }).first {
                return (first, "All lessons completed — revisit any lesson or run a review session to stay sharp.")
            }
            return nil
        }

        func firstIncomplete(withId id: String) -> Lesson? {
            incomplete.first { $0.id == id }
        }

        // 1. The goal the user picked during onboarding wins.
        switch progress?.learningGoal {
        case "Screenshots":
            if let lesson = firstIncomplete(withId: "shortcut-screenshots") {
                return (lesson, "Picked for you because you chose screenshots as your first focus.")
            }
        case "Find files and apps":
            if let lesson = firstIncomplete(withId: "shortcut-spotlight") {
                return (lesson, "Picked for you because Spotlight replaces Windows search habits.")
            }
        case "Switch apps faster":
            if let lesson = firstIncomplete(withId: "shortcut-app-switching") {
                return (lesson, "Picked for you because app switching is core Mac navigation.")
            }
        default:
            break
        }

        // 2. Then their Windows app background.
        let appsUsed = progress?.windowsAppsUsed ?? ""
        let appMatches: [(app: String, lessonId: String, reason: String)] = [
            ("File Explorer", "navigation-finder-basics", "Picked for you because Finder replaces your File Explorer habits."),
            ("Chrome", "gesture-two-finger-swipe-nav", "Picked for you because swipe navigation replaces browser back and forward buttons."),
            ("Photoshop", "gesture-pinch-to-zoom", "Picked for you because zoom gestures speed up visual work."),
            ("Teams", "shortcut-app-switching", "Picked for you because fast app switching helps when juggling chats and calls."),
            ("Office", "shortcut-save", "Picked for you because save shortcuts are a daily habit in office apps."),
            ("Outlook", "shortcut-save", "Picked for you because save shortcuts are a daily habit in office apps.")
        ]

        for match in appMatches where appsUsed.contains(match.app) {
            if let lesson = firstIncomplete(withId: match.lessonId) {
                return (lesson, match.reason)
            }
        }

        // 3. Then a lesson matching their comfort level.
        if let experience = progress?.macExperienceLevel {
            let targetDifficulty: LessonDifficulty = experience == "Comfortable" ? .comfortable : .beginner
            if let lesson = incomplete.first(where: { $0.difficulty == targetDifficulty }) {
                let reasonText = targetDifficulty == .beginner
                    ? "A friendly next step matched to your experience level."
                    : "Matched to your comfort level — ready for more than the basics."
                return (lesson, reasonText)
            }
        }

        // 4. Fall back to course order.
        if let lesson = incomplete.first {
            return (lesson, "The next step on your learning path.")
        }

        return nil
    }

    var dailyGoalText: String {
        completedToday ? "Daily goal complete" : "Complete 1 lesson today"
    }

    var welcomeSubtitle: String {
        guard let experience = progress?.macExperienceLevel else {
            return "Turn your Windows muscle memory into Mac confidence."
        }

        switch experience {
        case "Brand new":
            return "Starting fresh on Mac — we'll begin with the essentials."
        case "Some basics":
            return "Building on the Mac basics you already know."
        case "Comfortable":
            return "Sharpening your Mac skills beyond the basics."
        default:
            return "Turn your Windows muscle memory into Mac confidence."
        }
    }
}
