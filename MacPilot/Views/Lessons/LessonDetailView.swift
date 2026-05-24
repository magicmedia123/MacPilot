import SwiftData
import SwiftUI

struct LessonDetailView: View {
    @Bindable var lesson: Lesson
    @Query private var progressRecords: [UserProgress]
    @State private var selectedQuizAnswer: String?
    @State private var showsCompletionCelebration = false

    private var sortedSteps: [LessonStep] {
        lesson.steps.sorted { $0.sortOrder < $1.sortOrder }
    }

    private var quizQuestion: String {
        lesson.quizQuestion ?? "Which Mac action matches this Windows habit?"
    }

    private var correctQuizAnswer: String {
        lesson.correctQuizAnswer ?? sortedSteps.first?.macAction ?? "Command"
    }

    private var quizAnswers: [String] {
        [
            correctQuizAnswer,
            lesson.incorrectQuizAnswerOne ?? sortedSteps.dropFirst().first?.macAction ?? "Control",
            lesson.incorrectQuizAnswerTwo ?? sortedSteps.first?.windowsEquivalent ?? "Alt"
        ]
        .uniqued()
        .sorted()
    }

    private var hasAnsweredQuizCorrectly: Bool {
        selectedQuizAnswer == correctQuizAnswer || lesson.isCompleted
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header
                stepList
                practiceCheck
                completionControl
            }
            .padding(28)
            .frame(maxWidth: 860, alignment: .leading)
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .navigationTitle(lesson.title)
        .alert("Lesson Complete", isPresented: $showsCompletionCelebration) {
            Button("Nice", role: .cancel) { }
        } message: {
            Text("Your daily goal and streak have been updated.")
        }
    }

    private var header: some View {
        CardView {
            HStack(alignment: .top, spacing: 18) {
                Image(systemName: lesson.symbolName)
                    .font(.system(size: 38, weight: .medium))
                    .foregroundStyle(.blue)
                    .frame(width: 62, height: 62)
                    .background(.blue.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Text(lesson.category.rawValue)
                        Text(lesson.difficulty.rawValue)
                        Text("\(lesson.estimatedMinutes) min")
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)

                    Text(lesson.title)
                        .font(.largeTitle.weight(.semibold))

                    Text(lesson.summary)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
        }
    }

    private var stepList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Practice steps")
                .font(.headline)

            ForEach(sortedSteps) { step in
                CardView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(step.title)
                            .font(.title3.weight(.semibold))

                        Text(step.detail)
                            .foregroundStyle(.secondary)

                        Divider()

                        Grid(alignment: .leading, horizontalSpacing: 18, verticalSpacing: 8) {
                            GridRow {
                                ShortcutLabel(title: "Windows", value: step.windowsEquivalent)
                                ShortcutLabel(title: "Mac", value: step.macAction)
                            }
                        }
                    }
                }
            }
        }
    }

    private var completionControl: some View {
        CardView {
            HStack(spacing: 14) {
                Image(systemName: lesson.isCompleted ? "checkmark.seal.fill" : "circle")
                    .font(.title)
                    .foregroundStyle(lesson.isCompleted ? .green : .secondary)

                VStack(alignment: .leading, spacing: 4) {
                    Text(lesson.isCompleted ? "Lesson complete" : "Ready to mark this lesson complete?")
                        .font(.headline)

                    Text(lesson.isCompleted ? "Nice work. This lesson is now counted in your progress." : "Answer the practice check, then mark the lesson complete.")
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if lesson.isCompleted {
                    Button {
                        toggleCompletion()
                    } label: {
                        Label("Mark Incomplete", systemImage: "arrow.uturn.backward")
                    }
                    .buttonStyle(BorderedButtonStyle())
                } else {
                    Button {
                        toggleCompletion()
                    } label: {
                        Label("Complete Lesson", systemImage: "checkmark")
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                    .disabled(!hasAnsweredQuizCorrectly)
                }
            }
        }
    }

    private var practiceCheck: some View {
        CardView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    Image(systemName: "questionmark.circle")
                        .foregroundStyle(.blue)

                    Text("Practice check")
                        .font(.headline)
                }

                Text(quizQuestion)
                    .font(.title3.weight(.semibold))

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(quizAnswers, id: \.self) { answer in
                        QuizAnswerButton(
                            answer: answer,
                            isSelected: selectedQuizAnswer == answer,
                            isCorrect: answer == correctQuizAnswer,
                            hasSelection: selectedQuizAnswer != nil
                        ) {
                            selectedQuizAnswer = answer
                        }
                    }
                }

                if let selectedQuizAnswer {
                    Label(
                        selectedQuizAnswer == correctQuizAnswer ? "Correct. You can complete this lesson." : "Try again. Look back at the Mac action above.",
                        systemImage: selectedQuizAnswer == correctQuizAnswer ? "checkmark.circle.fill" : "xmark.circle.fill"
                    )
                    .font(.callout.weight(.medium))
                    .foregroundStyle(selectedQuizAnswer == correctQuizAnswer ? .green : .red)
                }
            }
        }
    }

    private func toggleCompletion() {
        guard let progress = progressRecords.first else { return }

        if lesson.isCompleted {
            lesson.isCompleted = false
            lesson.completedAt = nil
            progress.removeLessonCompletion()
        } else {
            lesson.isCompleted = true
            lesson.completedAt = .now
            progress.recordLessonCompletion()
            showsCompletionCelebration = true
        }
    }
}

private struct QuizAnswerButton: View {
    let answer: String
    let isSelected: Bool
    let isCorrect: Bool
    let hasSelection: Bool
    let action: () -> Void

    private var borderColor: Color {
        if isSelected && isCorrect { return .green }
        if isSelected && !isCorrect { return .red }
        return .secondary.opacity(0.25)
    }

    var body: some View {
        Button(action: action) {
            HStack {
                Text(answer)
                    .font(.body.weight(.medium))

                Spacer()

                if isSelected {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(isCorrect ? .green : .red)
                } else if hasSelection && isCorrect {
                    Image(systemName: "checkmark.circle")
                        .foregroundStyle(.green)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.secondary.opacity(isSelected ? 0.16 : 0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(borderColor)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

private struct ShortcutLabel: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.system(.body, design: .rounded).weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
        }
    }
}
