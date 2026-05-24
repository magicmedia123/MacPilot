import Foundation

struct LessonsViewModel {
    let lessons: [Lesson]
    let selectedCategory: LessonCategory?

    var filteredLessons: [Lesson] {
        guard let selectedCategory else { return lessons }
        return lessons.filter { $0.category == selectedCategory }
    }
}
