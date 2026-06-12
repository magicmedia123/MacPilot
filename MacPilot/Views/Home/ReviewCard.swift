import SwiftData
import SwiftUI

struct ReviewCard: View {
    @Query private var reviewItems: [ReviewItem]
    @Query private var lessons: [Lesson]

    @State private var showingReviewSession = false

    private var dueItems: [ReviewItem] {
        let today = Calendar.current.startOfDay(for: .now)
        return reviewItems.filter { item in
            Calendar.current.startOfDay(for: item.nextReviewDate) <= today
        }
    }

    private var nextUpcomingReview: Date? {
        let today = Calendar.current.startOfDay(for: .now)
        return reviewItems
            .map(\.nextReviewDate)
            .filter { Calendar.current.startOfDay(for: $0) > today }
            .min()
    }

    var body: some View {
        CardView(padding: 22) {
            HStack(alignment: .top, spacing: 16) {
                IconTile(
                    systemImage: "arrow.clockwise",
                    tint: dueItems.isEmpty ? .gray : .indigo,
                    size: 54,
                    cornerRadius: 12
                )

                VStack(alignment: .leading, spacing: 7) {
                    HStack(spacing: 6) {
                        Image(systemName: "brain.head.profile")
                            .font(.caption.weight(.semibold))
                        Text("Spaced repetition")
                            .font(.caption.weight(.bold))
                            .textCase(.uppercase)
                            .kerning(0.6)
                    }
                    .foregroundStyle(.indigo)

                    if dueItems.isEmpty {
                        Text("All caught up!")
                            .font(.title2.weight(.semibold))

                        if reviewItems.isEmpty {
                            Text("Complete lessons to start collecting shortcuts for review.")
                                .foregroundStyle(.secondary)
                        } else if let next = nextUpcomingReview {
                            Text("Next review \(next.formatted(.relative(presentation: .named))). Reviews are spaced out as your recall improves.")
                                .foregroundStyle(.secondary)
                        } else {
                            Text("Reviews are scheduled automatically as you complete lessons.")
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Text("\(dueItems.count) shortcut\(dueItems.count == 1 ? "" : "s") due for review")
                            .font(.title2.weight(.semibold))

                        Text("A quick recall session locks shortcuts into long-term memory.")
                            .foregroundStyle(.secondary)

                        Button {
                            showingReviewSession = true
                        } label: {
                            Label("Start Review", systemImage: "play.fill")
                                .padding(.horizontal, 4)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.indigo)
                        .padding(.top, 4)
                    }
                }

                Spacer()
            }
        }
        .sheet(isPresented: $showingReviewSession) {
            ReviewSessionView(dueItems: dueItems, lessons: lessons)
                .frame(width: 540, height: 470)
        }
    }
}

struct ReviewSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let dueItems: [ReviewItem]
    let lessons: [Lesson]

    @State private var currentIndex = 0
    @State private var revealAnswer = false
    @State private var showsCelebration = false

    private var currentItem: ReviewItem? {
        guard currentIndex < dueItems.count else { return nil }
        return dueItems[currentIndex]
    }

    private var currentLesson: Lesson? {
        guard let item = currentItem else { return nil }
        return lessons.first(where: { $0.id == item.lessonId })
    }

    var body: some View {
        VStack(spacing: 18) {
            if showsCelebration {
                celebrationView
            } else if let lesson = currentLesson, let item = currentItem {
                sessionHeader

                Spacer(minLength: 0)

                recallCard(lesson: lesson)

                Spacer(minLength: 0)

                if revealAnswer {
                    recallButtons(item: item)
                } else {
                    Button {
                        withAnimation(.spring(duration: 0.35)) { revealAnswer = true }
                    } label: {
                        Label("Reveal Mac Shortcut", systemImage: "eye")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                    }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.space, modifiers: [])
                }
            } else {
                noItemsView
            }
        }
        .padding(28)
        .background(Color(nsColor: .windowBackgroundColor))
        .overlay {
            if showsCelebration {
                ConfettiView(isActive: $showsCelebration)
            }
        }
    }

    private var sessionHeader: some View {
        VStack(spacing: 9) {
            HStack {
                Label("Review Session", systemImage: "brain.head.profile")
                    .font(.headline)

                Spacer()

                Text("\(currentIndex + 1) of \(dueItems.count)")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
                .help("End session")
            }

            ProgressView(value: Double(currentIndex), total: Double(max(dueItems.count, 1)))
                .tint(.indigo)
        }
    }

    private func recallCard(lesson: Lesson) -> some View {
        VStack(spacing: 22) {
            IconTile(systemImage: lesson.symbolName, tint: lesson.category.tint, size: 52, cornerRadius: 12)

            VStack(spacing: 9) {
                Text("Your old Windows habit")
                    .font(.caption.weight(.bold))
                    .textCase(.uppercase)
                    .kerning(0.5)
                    .foregroundStyle(.secondary)

                ShortcutDisplay(
                    text: lesson.steps.sorted { $0.sortOrder < $1.sortOrder }.first?.windowsEquivalent ?? "—",
                    style: .windows,
                    fallbackIcon: "computermouse"
                )
            }

            if revealAnswer {
                VStack(spacing: 9) {
                    Text("The Mac way")
                        .font(.caption.weight(.bold))
                        .textCase(.uppercase)
                        .kerning(0.5)
                        .foregroundStyle(Color.accentColor)

                    ShortcutDisplay(
                        text: lesson.steps.sorted { $0.sortOrder < $1.sortOrder }.first?.macAction ?? "—",
                        style: .mac,
                        fallbackIcon: lesson.category == .gestures ? "hand.draw" : "macwindow",
                        large: true
                    )
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                Text("Can you remember the Mac equivalent?")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(26)
        .frame(maxWidth: .infinity)
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(.separator.opacity(0.4))
        }
    }

    private func recallButtons(item: ReviewItem) -> some View {
        VStack(spacing: 10) {
            Text("How well did you remember?")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                RecallButton(title: "Forgot", systemImage: "xmark", tint: .red) {
                    advance(item: item, quality: 1)
                }
                RecallButton(title: "Hard", systemImage: "tortoise", tint: .orange) {
                    advance(item: item, quality: 3)
                }
                RecallButton(title: "Good", systemImage: "checkmark", tint: .green) {
                    advance(item: item, quality: 4)
                }
                RecallButton(title: "Easy", systemImage: "hare", tint: .blue) {
                    advance(item: item, quality: 5)
                }
            }
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private func advance(item: ReviewItem, quality: Int) {
        item.updateRecall(quality: quality)
        try? modelContext.save()

        if currentIndex + 1 < dueItems.count {
            withAnimation {
                revealAnswer = false
                currentIndex += 1
            }
        } else {
            withAnimation {
                showsCelebration = true
            }
        }
    }

    private var celebrationView: some View {
        VStack(spacing: 22) {
            Spacer()

            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)

            VStack(spacing: 8) {
                Text("Session complete!")
                    .font(.title.weight(.bold))

                Text("You reviewed \(dueItems.count) shortcut\(dueItems.count == 1 ? "" : "s"). Each one is rescheduled based on how well you remembered it.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("Done")
                    .frame(width: 130)
            }
            .buttonStyle(.borderedProminent)
            .keyboardShortcut(.defaultAction)
        }
    }

    private var noItemsView: some View {
        VStack(spacing: 16) {
            EmptyStateView(
                title: "Nothing due right now",
                message: "Reviews appear here as their schedule comes up.",
                systemImage: "checkmark.circle"
            )

            Button("Close") {
                dismiss()
            }
            .buttonStyle(.bordered)
        }
    }
}

private struct RecallButton: View {
    let title: String
    let systemImage: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: systemImage)
                    .font(.system(size: 14, weight: .semibold))

                Text(title)
                    .font(.callout.weight(.medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 9)
            .foregroundStyle(tint)
            .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .strokeBorder(tint.opacity(0.3))
            }
        }
        .buttonStyle(.plain)
    }
}
