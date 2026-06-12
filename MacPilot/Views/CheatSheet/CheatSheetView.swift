import AppKit
import SwiftData
import SwiftUI

/// A quick-reference table of every Windows → Mac mapping in the course.
/// This is the screen switchers keep open in their first weeks on a Mac.
struct CheatSheetView: View {
    @Environment(AppRouter.self) private var router
    @Query(sort: \Lesson.sortOrder) private var lessons: [Lesson]

    @State private var searchText = ""
    @State private var selectedCategory: LessonCategory?
    @State private var learnedOnly = false

    private struct Entry: Identifiable {
        let id: String
        let title: String
        let detail: String
        let windows: String
        let mac: String
        let lesson: Lesson
    }

    private var allEntries: [Entry] {
        lessons.flatMap { lesson in
            lesson.steps
                .sorted { $0.sortOrder < $1.sortOrder }
                .map { step in
                    Entry(
                        id: "\(lesson.id)-\(step.sortOrder)",
                        title: step.title,
                        detail: step.detail,
                        windows: step.windowsEquivalent,
                        mac: step.macAction,
                        lesson: lesson
                    )
                }
        }
    }

    private var filteredEntries: [Entry] {
        allEntries.filter { entry in
            if let selectedCategory, entry.lesson.category != selectedCategory {
                return false
            }

            if learnedOnly && !entry.lesson.isCompleted {
                return false
            }

            if !searchText.isEmpty {
                let haystack = [entry.title, entry.windows, entry.mac, entry.lesson.title]
                guard haystack.contains(where: { $0.localizedCaseInsensitiveContains(searchText) }) else {
                    return false
                }
            }

            return true
        }
    }

    private var visibleCategories: [LessonCategory] {
        LessonCategory.allCases.filter { category in
            filteredEntries.contains { $0.lesson.category == category }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                categoryFilter

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        header

                        if filteredEntries.isEmpty {
                            EmptyStateView(
                                title: learnedOnly ? "Nothing learned yet" : "No shortcuts match",
                                message: learnedOnly
                                    ? "Complete lessons to collect shortcuts here, or turn off the Learned filter."
                                    : "Try a different search term or category.",
                                systemImage: learnedOnly ? "graduationcap" : "magnifyingglass"
                            )
                        } else {
                            ForEach(visibleCategories) { category in
                                section(for: category)
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
            .navigationTitle("Cheat Sheet")
            .searchable(text: $searchText, prompt: "Search shortcuts")
            .toolbar {
                ToolbarItem {
                    Toggle(isOn: $learnedOnly) {
                        Label("Learned Only", systemImage: learnedOnly ? "graduationcap.fill" : "graduationcap")
                    }
                    .help("Show only shortcuts from lessons you've completed")
                }
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Every shortcut, side by side")
                    .font(.title2.weight(.semibold))

                Text("Your Windows habits on the left, the Mac way on the right. Click a row to open its lesson, or right-click to copy.")
                    .foregroundStyle(.secondary)
            }

            Spacer()

            MetaChip(
                text: "\(filteredEntries.count) shortcut\(filteredEntries.count == 1 ? "" : "s")",
                systemImage: "command",
                tint: .blue
            )
            .padding(.top, 4)
        }
    }

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                CheatSheetFilterChip(title: "All", tint: .blue, isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }

                ForEach(LessonCategory.allCases) { category in
                    CheatSheetFilterChip(
                        title: category.shortName,
                        systemImage: category.symbolName,
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

    private func section(for category: LessonCategory) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 9) {
                IconTile(systemImage: category.symbolName, tint: category.tint, size: 24, cornerRadius: 6)

                Text(category.rawValue)
                    .font(.headline)
            }

            VStack(spacing: 6) {
                ForEach(filteredEntries.filter { $0.lesson.category == category }) { entry in
                    CheatSheetRow(
                        title: entry.title,
                        detail: entry.detail,
                        windows: entry.windows,
                        mac: entry.mac,
                        isLearned: entry.lesson.isCompleted,
                        macFallbackIcon: category == .gestures ? "hand.draw" : "macwindow"
                    ) {
                        router.openLesson(id: entry.lesson.id)
                    }
                }
            }
        }
    }
}

private struct CheatSheetRow: View {
    let title: String
    let detail: String
    let windows: String
    let mac: String
    let isLearned: Bool
    let macFallbackIcon: String
    let openLesson: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: openLesson) {
            HStack(spacing: 14) {
                Image(systemName: isLearned ? "checkmark.circle.fill" : "circle.dotted")
                    .font(.system(size: 15))
                    .foregroundStyle(isLearned ? AnyShapeStyle(.green) : AnyShapeStyle(.quaternary))
                    .help(isLearned ? "You've learned this one" : "Not learned yet")

                Text(title)
                    .font(.body.weight(.medium))
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)

                ShortcutDisplay(text: windows, style: .windows, fallbackIcon: "computermouse")
                    .frame(maxWidth: 230, alignment: .trailing)

                Image(systemName: "arrow.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.tertiary)

                ShortcutDisplay(text: mac, style: .mac, fallbackIcon: macFallbackIcon)
                    .frame(maxWidth: 260, alignment: .leading)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                isHovered ? AnyShapeStyle(.background.secondary) : AnyShapeStyle(.background.secondary.opacity(0.5)),
                in: RoundedRectangle(cornerRadius: 10, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(.separator.opacity(isHovered ? 0.6 : 0.35))
            }
        }
        .buttonStyle(.plain)
        .help(detail)
        .contextMenu {
            Button("Copy Mac Shortcut") {
                copyToPasteboard(mac)
            }
            Button("Copy Windows Equivalent") {
                copyToPasteboard(windows)
            }
        }
        .animation(.easeOut(duration: 0.15), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }

    private func copyToPasteboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}

private struct CheatSheetFilterChip: View {
    let title: String
    var systemImage: String?
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
