import SwiftData
import SwiftUI

struct LessonListView: View {
    @Environment(AppRouter.self) private var router
    @Query(sort: \Lesson.sortOrder) private var lessons: [Lesson]

    @State private var selectedCategory: LessonCategory?
    @State private var selectedDifficulty: LessonDifficulty?
    @State private var hideCompleted = false
    @State private var searchText = ""
    @State private var path: [Lesson] = []

    private var viewModel: LessonsViewModel {
        LessonsViewModel(
            lessons: lessons,
            selectedCategory: selectedCategory,
            selectedDifficulty: selectedDifficulty,
            hideCompleted: hideCompleted,
            searchText: searchText
        )
    }

    private var hasActiveRefinements: Bool {
        selectedDifficulty != nil || hideCompleted
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                categoryFilter

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 22, pinnedViews: []) {
                        if viewModel.filteredLessons.isEmpty {
                            EmptyStateView(
                                title: "No lessons match",
                                message: "Try a different search, category, or filter.",
                                systemImage: "line.3.horizontal.decrease.circle"
                            )
                        } else {
                            ForEach(viewModel.visibleCategories) { category in
                                categorySection(category)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                    .frame(maxWidth: 940, alignment: .leading)
                    .frame(maxWidth: .infinity)
                }
            }
            .background(Color(nsColor: .windowBackgroundColor))
            .navigationTitle("Lessons")
            .navigationDestination(for: Lesson.self) { lesson in
                LessonDetailView(lesson: lesson)
            }
            .searchable(text: $searchText, prompt: "Search lessons")
            .toolbar {
                ToolbarItem {
                    refinementMenu
                }
            }
        }
        .onAppear(perform: consumePendingLesson)
        .onChange(of: router.pendingLessonID) {
            consumePendingLesson()
        }
    }

    /// Other screens (Home, Cheat Sheet) request a lesson through the router;
    /// this pushes it onto the navigation stack.
    private func consumePendingLesson() {
        guard let id = router.pendingLessonID,
              let lesson = lessons.first(where: { $0.id == id }) else {
            return
        }

        router.pendingLessonID = nil
        path = [lesson]
    }

    // MARK: - Filters

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    title: "All",
                    count: viewModel.count(for: nil),
                    tint: .blue,
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }

                ForEach(LessonCategory.allCases) { category in
                    FilterChip(
                        title: category.shortName,
                        systemImage: category.symbolName,
                        count: viewModel.count(for: category),
                        tint: category.tint,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = selectedCategory == category ? nil : category
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 11)
        }
        .background(.bar)
        .overlay(alignment: .bottom) {
            Divider()
        }
    }

    private var refinementMenu: some View {
        Menu {
            Picker("Difficulty", selection: $selectedDifficulty) {
                Text("Any Difficulty").tag(LessonDifficulty?.none)
                ForEach(LessonDifficulty.allCases) { difficulty in
                    Label(difficulty.rawValue, systemImage: difficulty.symbolName)
                        .tag(LessonDifficulty?.some(difficulty))
                }
            }
            .pickerStyle(.inline)

            Divider()

            Toggle("Hide Completed", isOn: $hideCompleted)

            if hasActiveRefinements {
                Divider()

                Button("Clear Filters") {
                    selectedDifficulty = nil
                    hideCompleted = false
                }
            }
        } label: {
            Label("Filter", systemImage: hasActiveRefinements
                ? "line.3.horizontal.decrease.circle.fill"
                : "line.3.horizontal.decrease.circle")
        }
        .help("Filter lessons by difficulty or completion")
    }

    // MARK: - Sections

    private func categorySection(_ category: LessonCategory) -> some View {
        VStack(alignment: .leading, spacing: 11) {
            categoryHeader(category)

            ForEach(viewModel.filteredLessons(in: category)) { lesson in
                NavigationLink(value: lesson) {
                    LessonRow(lesson: lesson)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func categoryHeader(_ category: LessonCategory) -> some View {
        let summary = viewModel.completionSummary(for: category)

        return HStack(spacing: 10) {
            IconTile(systemImage: category.symbolName, tint: category.tint, size: 26, cornerRadius: 7)

            Text(category.rawValue)
                .font(.title3.weight(.semibold))

            Text("\(summary.completed) of \(summary.total)")
                .font(.callout)
                .foregroundStyle(.secondary)

            Spacer()

            ProgressView(value: summary.total == 0 ? 0 : Double(summary.completed) / Double(summary.total))
                .tint(category.tint)
                .controlSize(.small)
                .frame(width: 90)
        }
    }
}

// MARK: - Row

private struct LessonRow: View {
    let lesson: Lesson
    @State private var isHovered = false

    private var primaryMacAction: String? {
        lesson.steps.sorted { $0.sortOrder < $1.sortOrder }.first?.macAction
    }

    var body: some View {
        HStack(spacing: 14) {
            IconTile(systemImage: lesson.symbolName, tint: lesson.category.tint, size: 42, cornerRadius: 10)
                .overlay(alignment: .topTrailing) {
                    if lesson.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.white, .green)
                            .background(Circle().fill(.background))
                            .offset(x: 5, y: -5)
                    }
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(lesson.title)
                    .font(.headline)

                Text(lesson.summary)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    DifficultyBadge(difficulty: lesson.difficulty)

                    MetaChip(text: "\(lesson.estimatedMinutes) min", systemImage: "clock")

                    let stepCount = lesson.steps.count
                    MetaChip(text: "\(stepCount) step\(stepCount == 1 ? "" : "s")", systemImage: "list.bullet")
                }
            }

            Spacer(minLength: 12)

            // Tease the shortcut on the row itself, but only when it renders as keycaps.
            if let action = primaryMacAction,
               ShortcutParser.keycapGroups(from: action, style: .mac) != nil {
                ShortcutDisplay(text: action, style: .mac)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(
            isHovered ? AnyShapeStyle(.background.secondary) : AnyShapeStyle(.background.secondary.opacity(0.55)),
            in: RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous)
                .strokeBorder(.separator.opacity(isHovered ? 0.7 : 0.4))
        }
        .shadow(color: .black.opacity(isHovered ? 0.06 : 0.02), radius: isHovered ? 7 : 3, y: 2)
        .animation(.easeOut(duration: 0.16), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Filter chip

private struct FilterChip: View {
    let title: String
    var systemImage: String?
    var count: Int?
    var tint: Color = .blue
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 10, weight: .semibold))
                }

                Text(title)
                    .font(.callout.weight(.medium))

                if let count {
                    Text("\(count)")
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1.5)
                        .background(
                            isSelected ? AnyShapeStyle(.white.opacity(0.25)) : AnyShapeStyle(tint.opacity(0.16)),
                            in: Capsule()
                        )
                        .foregroundStyle(isSelected ? .white : tint)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
        .foregroundStyle(isSelected ? .white : .primary)
        .background(isSelected ? AnyShapeStyle(tint) : AnyShapeStyle(.quaternary.opacity(0.7)), in: Capsule())
        .animation(.easeOut(duration: 0.15), value: isSelected)
    }
}
