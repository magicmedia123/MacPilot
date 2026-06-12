import Foundation

struct LessonsViewModel {
    let lessons: [Lesson]
    let selectedCategory: LessonCategory?
    var selectedDifficulty: LessonDifficulty?
    var hideCompleted: Bool = false
    var searchText: String = ""

    var filteredLessons: [Lesson] {
        var result = lessons

        if let selectedCategory {
            result = result.filter { $0.category == selectedCategory }
        }

        if let selectedDifficulty {
            result = result.filter { $0.difficulty == selectedDifficulty }
        }

        if hideCompleted {
            result = result.filter { !$0.isCompleted }
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
                || $0.summary.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result
    }

    /// Categories that still have lessons after filtering, in declaration order.
    var visibleCategories: [LessonCategory] {
        LessonCategory.allCases.filter { category in
            filteredLessons.contains { $0.category == category }
        }
    }

    func filteredLessons(in category: LessonCategory) -> [Lesson] {
        filteredLessons.filter { $0.category == category }
    }

    /// Unfiltered completion counts, used for category section headers.
    func completionSummary(for category: LessonCategory) -> (completed: Int, total: Int) {
        let categoryLessons = lessons.filter { $0.category == category }
        return (categoryLessons.filter(\.isCompleted).count, categoryLessons.count)
    }

    func count(for category: LessonCategory?) -> Int {
        guard let category else { return lessons.count }
        return lessons.filter { $0.category == category }.count
    }
}
