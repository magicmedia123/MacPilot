import Foundation

struct ProgressViewModel {
    let lessons: [Lesson]
    let progress: UserProgress?

    var completedLessons: [Lesson] {
        lessons.filter(\.isCompleted)
    }

    var completionRatio: Double {
        guard !lessons.isEmpty else { return 0 }
        return Double(completedLessons.count) / Double(lessons.count)
    }

    func completedCount(for category: LessonCategory) -> Int {
        lessons.filter { $0.category == category && $0.isCompleted }.count
    }

    func totalCount(for category: LessonCategory) -> Int {
        lessons.filter { $0.category == category }.count
    }
}
