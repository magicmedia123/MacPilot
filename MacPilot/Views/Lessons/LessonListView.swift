import SwiftData
import SwiftUI

struct LessonListView: View {
    @Query(sort: \Lesson.sortOrder) private var lessons: [Lesson]
    @State private var selectedCategory: LessonCategory?
    @State private var searchText = ""

    private var viewModel: LessonsViewModel {
        LessonsViewModel(lessons: lessons, selectedCategory: selectedCategory, searchText: searchText)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                categoryFilter

                List(viewModel.filteredLessons) { lesson in
                    NavigationLink {
                        LessonDetailView(lesson: lesson)
                    } label: {
                        LessonRow(lesson: lesson)
                    }
                    .padding(.vertical, 6)
                }
                .listStyle(.inset)
            }
            .navigationTitle("Lessons")
            .searchable(text: $searchText, prompt: "Search lessons")
        }
    }

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterButton(title: "All", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }

                ForEach(LessonCategory.allCases) { category in
                    FilterButton(
                        title: category.rawValue,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
        }
        .background(.bar)
    }
}

private struct LessonRow: View {
    let lesson: Lesson

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: lesson.isCompleted ? "checkmark.circle.fill" : lesson.symbolName)
                .font(.title2)
                .foregroundStyle(lesson.isCompleted ? .green : .blue)
                .frame(width: 38, height: 38)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 5) {
                Text(lesson.title)
                    .font(.headline)

                Text(lesson.summary)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    Text(lesson.category.rawValue)
                    Text("\(lesson.estimatedMinutes) min")
                    Text(lesson.difficulty.rawValue)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
    }
}

private struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.callout.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
        }
        .buttonStyle(PlainButtonStyle())
        .foregroundStyle(isSelected ? .white : .primary)
        .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.12), in: Capsule())
    }
}
