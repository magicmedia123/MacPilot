import Foundation

struct LessonsViewModel {
    let lessons: [Lesson]
    let selectedCategory: LessonCategory?
    var searchText: String = ""

    var filteredLessons: [Lesson] {
        var result = lessons

        if let selectedCategory {
            result = result.filter { $0.category == selectedCategory }
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
                || $0.summary.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result
    }
}
