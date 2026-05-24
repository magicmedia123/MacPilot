import Foundation
import SwiftData

enum SampleDataSeeder {
    @MainActor
    static func seedIfNeeded(in modelContext: ModelContext) {
        seedProgressIfNeeded(in: modelContext)
        seedLessonsIfNeeded(in: modelContext)
        addMissingLessonsIfNeeded(in: modelContext)
        updateLessonQuizzesIfNeeded(in: modelContext)
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
}
