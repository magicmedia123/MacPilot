import Foundation
import SwiftData

enum LessonCategory: String, CaseIterable, Identifiable {
    case shortcuts = "Keyboard Shortcuts"
    case gestures = "Touchpad Gestures"
    case navigation = "Mac Navigation"
    case productivity = "Productivity"

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .shortcuts: "command"
        case .gestures: "hand.tap"
        case .navigation: "macwindow"
        case .productivity: "sparkles"
        }
    }
}

enum LessonDifficulty: String, CaseIterable, Identifiable {
    case beginner = "Beginner"
    case comfortable = "Comfortable"
    case advanced = "Advanced"

    var id: String { rawValue }
}

@Model
final class LessonStep {
    var title: String
    var detail: String
    var windowsEquivalent: String
    var macAction: String
    var sortOrder: Int

    init(
        title: String,
        detail: String,
        windowsEquivalent: String,
        macAction: String,
        sortOrder: Int
    ) {
        self.title = title
        self.detail = detail
        self.windowsEquivalent = windowsEquivalent
        self.macAction = macAction
        self.sortOrder = sortOrder
    }
}

@Model
final class Lesson {
    @Attribute(.unique) var id: String
    var title: String
    var summary: String
    var categoryRawValue: String
    var difficultyRawValue: String
    var estimatedMinutes: Int
    var symbolName: String
    var sortOrder: Int
    var isCompleted: Bool
    var completedAt: Date?
    var quizQuestion: String?
    var correctQuizAnswer: String?
    var incorrectQuizAnswerOne: String?
    var incorrectQuizAnswerTwo: String?

    // SwiftData persists related steps with the lesson so each lesson owns its own checklist.
    @Relationship(deleteRule: .cascade) var steps: [LessonStep]

    var category: LessonCategory {
        get { LessonCategory(rawValue: categoryRawValue) ?? .shortcuts }
        set { categoryRawValue = newValue.rawValue }
    }

    var difficulty: LessonDifficulty {
        get { LessonDifficulty(rawValue: difficultyRawValue) ?? .beginner }
        set { difficultyRawValue = newValue.rawValue }
    }

    init(
        id: String,
        title: String,
        summary: String,
        category: LessonCategory,
        difficulty: LessonDifficulty,
        estimatedMinutes: Int,
        symbolName: String,
        sortOrder: Int,
        isCompleted: Bool = false,
        completedAt: Date? = nil,
        quizQuestion: String? = nil,
        correctQuizAnswer: String? = nil,
        incorrectQuizAnswerOne: String? = nil,
        incorrectQuizAnswerTwo: String? = nil,
        steps: [LessonStep]
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.categoryRawValue = category.rawValue
        self.difficultyRawValue = difficulty.rawValue
        self.estimatedMinutes = estimatedMinutes
        self.symbolName = symbolName
        self.sortOrder = sortOrder
        self.isCompleted = isCompleted
        self.completedAt = completedAt
        self.quizQuestion = quizQuestion
        self.correctQuizAnswer = correctQuizAnswer
        self.incorrectQuizAnswerOne = incorrectQuizAnswerOne
        self.incorrectQuizAnswerTwo = incorrectQuizAnswerTwo
        self.steps = steps
    }
}
