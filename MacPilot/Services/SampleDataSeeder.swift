import Foundation
import SwiftData

enum SampleDataSeeder {
    @MainActor
    static func seedIfNeeded(in modelContext: ModelContext) {
        seedProgressIfNeeded(in: modelContext)
        seedLessonsIfNeeded(in: modelContext)
        addMissingLessonsIfNeeded(in: modelContext)
        updateLessonQuizzesIfNeeded(in: modelContext)
        seedAchievementsIfNeeded(in: modelContext)
    }

    @MainActor
    private static func seedProgressIfNeeded(in modelContext: ModelContext) {
        let descriptor = FetchDescriptor<UserProgress>()

        guard (try? modelContext.fetch(descriptor).isEmpty) == true else {
            return
        }

        modelContext.insert(UserProgress())
    }

    @MainActor
    private static func seedLessonsIfNeeded(in modelContext: ModelContext) {
        let descriptor = FetchDescriptor<Lesson>()

        guard (try? modelContext.fetch(descriptor).isEmpty) == true else {
            return
        }

        // Mock lessons are inserted once, then SwiftData becomes the source of truth.
        MockLessonData.lessons.forEach { modelContext.insert($0) }
    }

    @MainActor
    private static func addMissingLessonsIfNeeded(in modelContext: ModelContext) {
        let descriptor = FetchDescriptor<Lesson>()
        guard let savedLessons = try? modelContext.fetch(descriptor) else {
            return
        }

        let savedIDs = Set(savedLessons.map(\.id))
        MockLessonData.lessons
            .filter { !savedIDs.contains($0.id) }
            .forEach { modelContext.insert($0) }
    }

    @MainActor
    private static func updateLessonQuizzesIfNeeded(in modelContext: ModelContext) {
        let descriptor = FetchDescriptor<Lesson>()
        guard let savedLessons = try? modelContext.fetch(descriptor) else {
            return
        }

        // Existing local users keep their progress while receiving refreshed lesson metadata.
        for lesson in savedLessons {
            guard let mockLesson = MockLessonData.lessons.first(where: { $0.id == lesson.id }) else {
                continue
            }

            lesson.title = mockLesson.title
            lesson.summary = mockLesson.summary
            lesson.categoryRawValue = mockLesson.categoryRawValue
            lesson.difficultyRawValue = mockLesson.difficultyRawValue
            lesson.estimatedMinutes = mockLesson.estimatedMinutes
            lesson.symbolName = mockLesson.symbolName
            lesson.sortOrder = mockLesson.sortOrder
            lesson.quizQuestion = mockLesson.quizQuestion
            lesson.correctQuizAnswer = mockLesson.correctQuizAnswer
            lesson.incorrectQuizAnswerOne = mockLesson.incorrectQuizAnswerOne
            lesson.incorrectQuizAnswerTwo = mockLesson.incorrectQuizAnswerTwo
        }
    }

    /// Achievement definitions derive their lesson-count copy from the catalog,
    /// so the text stays accurate as lessons are added.
    private static var achievementDefinitions: [(id: String, title: String, detail: String, symbolName: String)] {
        let totalLessons = MockLessonData.lessons.count
        let halfway = AchievementService.halfwayThreshold(totalLessons: totalLessons)

        return [
            ("first-shortcut", "First Step", "Complete your first lesson.", "trophy"),
            ("comfort-zone", "Getting Comfortable", "Complete 5 lessons.", "sparkles"),
            ("halfway", "Halfway There", "Complete \(halfway) lessons.", "gauge.with.needle"),
            ("master", "Mac Pilot Master", "Complete all \(totalLessons) lessons.", "crown"),
            ("streak-3", "Consistency Kid", "Achieve a 3-day learning streak.", "flame"),
            ("streak-7", "Weekly Warrior", "Achieve a 7-day learning streak.", "bolt"),
            ("polymath", "Fast Learner", "Complete 3 lessons in a single day.", "speedometer")
        ]
    }

    @MainActor
    private static func seedAchievementsIfNeeded(in modelContext: ModelContext) {
        let descriptor = FetchDescriptor<Achievement>()
        guard let saved = try? modelContext.fetch(descriptor) else {
            return
        }

        let savedById = Dictionary(uniqueKeysWithValues: saved.map { ($0.id, $0) })

        for definition in achievementDefinitions {
            if let existing = savedById[definition.id] {
                // Existing users keep their unlock state but get refreshed copy.
                existing.title = definition.title
                existing.detail = definition.detail
                existing.symbolName = definition.symbolName
            } else {
                modelContext.insert(
                    Achievement(
                        id: definition.id,
                        title: definition.title,
                        detail: definition.detail,
                        symbolName: definition.symbolName
                    )
                )
            }
        }
    }
}
