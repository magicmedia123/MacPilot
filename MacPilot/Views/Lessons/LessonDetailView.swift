import AppKit
import SwiftData
import SwiftUI

struct LessonDetailView: View {
    let initialLesson: Lesson
    @State private var lesson: Lesson
    
    @Environment(\.modelContext) private var modelContext
    @Query private var lessons: [Lesson]
    @Query private var progressRecords: [UserProgress]
    
    init(lesson: Lesson) {
        self.initialLesson = lesson
        self._lesson = State(initialValue: lesson)
    }
    @State private var selectedQuizAnswer: String?
    @State private var capturedShortcut: CapturedShortcut?
    @State private var hasCompletedKeyboardPractice = false
    @State private var showsCompletionCelebration = false
    @State private var showsCompletionToast = false

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
        hasCompletedKeyboardPractice || selectedQuizAnswer == correctQuizAnswer || lesson.isCompleted
    }

    private var expectedShortcut: CapturedShortcut? {
        CapturedShortcut(displayString: correctQuizAnswer)
    }

    private var canUseKeyboardPractice: Bool {
        expectedShortcut != nil
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header
                stepList
                if canUseKeyboardPractice {
                    keyboardPractice
                } else {
                    practiceCheck
                }
                completionControl
            }
            .padding(28)
            .frame(maxWidth: 860, alignment: .leading)
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .navigationTitle(lesson.title)
        .overlay(alignment: .top) {
            if showsCompletionToast {
                HStack(spacing: 8) {
                    Text("🎉 Lesson Complete!")
                        .font(.headline)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.regularMaterial, in: Capsule())
                .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
                .padding(.top, 12)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .overlay {
            ConfettiView(isActive: $showsCompletionCelebration)
        }
        .onChange(of: showsCompletionCelebration) { _, active in
            if active {
                withAnimation(.spring(duration: 0.4)) {
                    showsCompletionToast = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeIn(duration: 0.3)) {
                        showsCompletionToast = false
                    }
                }
            }
        }
        .onChange(of: initialLesson) { _, newLesson in
            lesson = newLesson
            capturedShortcut = nil
            hasCompletedKeyboardPractice = false
            selectedQuizAnswer = nil
            showsCompletionCelebration = false
            showsCompletionToast = false
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

                    Text(lesson.isCompleted ? "Nice work. This lesson is now counted in your progress." : "Complete the practice check, then mark the lesson complete.")
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if lesson.isCompleted {
                    HStack(spacing: 12) {
                        Button {
                            toggleCompletion()
                        } label: {
                            Label("Mark Incomplete", systemImage: "arrow.uturn.backward")
                        }
                        .buttonStyle(BorderedButtonStyle())
                        
                        if let next = nextLesson {
                            Button {
                                navigateToNext(next)
                            } label: {
                                Label("Next Lesson", systemImage: "arrow.forward.circle.fill")
                            }
                            .buttonStyle(BorderedProminentButtonStyle())
                        }
                    }
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

    private var keyboardPractice: some View {
        CardView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    Image(systemName: hasCompletedKeyboardPractice ? "checkmark.circle.fill" : "keyboard")
                        .foregroundStyle(hasCompletedKeyboardPractice ? .green : .blue)

                    Text("Keyboard practice")
                        .font(.headline)
                }

                Text("Press the Mac shortcut")
                    .font(.title3.weight(.semibold))

                HStack(spacing: 12) {
                    ShortcutKeyCaps(displayText: correctQuizAnswer)

                    Spacer()

                    if let capturedShortcut {
                        Text("You pressed \(capturedShortcut.displayText)")
                            .font(.callout.weight(.medium))
                            .foregroundStyle(hasCompletedKeyboardPractice ? .green : .red)
                    } else {
                        Text("Waiting for input")
                            .font(.callout.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                }

                KeyboardShortcutCaptureView { shortcut in
                    capturedShortcut = shortcut
                    hasCompletedKeyboardPractice = shortcut == expectedShortcut
                }
                .frame(height: 78)

                Label(
                    keyboardPracticeMessage,
                    systemImage: hasCompletedKeyboardPractice ? "checkmark.circle.fill" : "info.circle"
                )
                .font(.callout.weight(.medium))
                .foregroundStyle(hasCompletedKeyboardPractice ? .green : .secondary)

                if !hasCompletedKeyboardPractice {
                    Button {
                        hasCompletedKeyboardPractice = true
                    } label: {
                        Label("I Practiced This Shortcut", systemImage: "hand.tap")
                    }
                    .buttonStyle(BorderedButtonStyle())
                    .help("Some macOS system shortcuts are handled before MacPilot can detect them.")
                }
            }
        }
    }

    private var keyboardPracticeMessage: String {
        if hasCompletedKeyboardPractice {
            return "Correct. You can complete this lesson."
        }

        if capturedShortcut != nil {
            return "Try again, or use the practice confirmation if macOS handled the shortcut."
        }

        return "Click the practice box, then press \(correctQuizAnswer)."
    }

    private func toggleCompletion() {
        guard let progress = progressRecords.first else { return }

        if lesson.isCompleted {
            lesson.isCompleted = false
            lesson.completedAt = nil
            progress.removeLessonCompletion()
            
            let lessonId = lesson.id
            if let reviewItems = try? modelContext.fetch(FetchDescriptor<ReviewItem>()),
               let item = reviewItems.first(where: { $0.lessonId == lessonId }) {
                modelContext.delete(item)
            }
        } else {
            lesson.isCompleted = true
            lesson.completedAt = .now
            progress.recordLessonCompletion()
            showsCompletionCelebration = true
            
            let lessonId = lesson.id
            if let reviewItems = try? modelContext.fetch(FetchDescriptor<ReviewItem>()),
               !reviewItems.contains(where: { $0.lessonId == lessonId }) {
                let reviewItem = ReviewItem(lessonId: lessonId)
                modelContext.insert(reviewItem)
            }
            
            AchievementService.checkAndUnlockAchievements(modelContext: modelContext, lessons: lessons, progress: progress)
        }
    }

    private var nextLesson: Lesson? {
        let sorted = lessons.sorted { $0.sortOrder < $1.sortOrder }
        if let currentIndex = sorted.firstIndex(where: { $0.id == lesson.id }) {
            let subsequent = sorted[currentIndex...]
            if let next = subsequent.first(where: { $0.id != lesson.id && !$0.isCompleted }) {
                return next
            }
            let antecedent = sorted[..<currentIndex]
            if let next = antecedent.first(where: { !$0.isCompleted }) {
                return next
            }
        }
        return nil
    }

    private func navigateToNext(_ next: Lesson) {
        capturedShortcut = nil
        hasCompletedKeyboardPractice = false
        selectedQuizAnswer = nil
        showsCompletionCelebration = false
        showsCompletionToast = false
        
        withAnimation(.easeInOut(duration: 0.3)) {
            lesson = next
        }
    }
}

private struct CapturedShortcut: Equatable {
    let key: String
    let modifiers: Set<ShortcutModifier>

    init(key: String, modifiers: Set<ShortcutModifier>) {
        self.key = key.lowercased()
        self.modifiers = modifiers
    }

    init?(displayString: String) {
        let parts = displayString
            .components(separatedBy: "+")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard let keyPart = parts.last else {
            return nil
        }

        var modifiers = Set<ShortcutModifier>()

        for part in parts.dropLast() {
            switch part.lowercased() {
            case "command", "cmd", "⌘":
                modifiers.insert(.command)
            case "shift", "⇧":
                modifiers.insert(.shift)
            case "option", "alt", "⌥":
                modifiers.insert(.option)
            case "control", "ctrl", "⌃":
                modifiers.insert(.control)
            default:
                continue
            }
        }

        guard !modifiers.isEmpty else {
            return nil
        }

        self.init(key: keyPart.normalizedShortcutKey, modifiers: modifiers)
    }

    var displayText: String {
        let modifierText = ShortcutModifier.displayOrder
            .filter { modifiers.contains($0) }
            .map(\.displayText)
            .joined(separator: "")

        return "\(modifierText)\(key.displayShortcutKey)"
    }
}

private enum ShortcutModifier: Hashable {
    case command
    case shift
    case option
    case control

    static let displayOrder: [ShortcutModifier] = [.control, .option, .shift, .command]

    var displayText: String {
        switch self {
        case .command: return "⌘"
        case .shift: return "⇧"
        case .option: return "⌥"
        case .control: return "⌃"
        }
    }
}

private struct KeyboardShortcutCaptureView: NSViewRepresentable {
    let onShortcut: (CapturedShortcut) -> Void

    func makeNSView(context: Context) -> ShortcutCaptureNSView {
        let view = ShortcutCaptureNSView()
        view.onShortcut = onShortcut
        return view
    }

    func updateNSView(_ nsView: ShortcutCaptureNSView, context: Context) {
        nsView.onShortcut = onShortcut

        DispatchQueue.main.async {
            nsView.window?.makeFirstResponder(nsView)
        }
    }
}

private final class ShortcutCaptureNSView: NSView {
    var onShortcut: ((CapturedShortcut) -> Void)?

    override var acceptsFirstResponder: Bool {
        true
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        window?.makeFirstResponder(self)
    }

    override func keyDown(with event: NSEvent) {
        handle(event)
    }

    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        handle(event)
        return true
    }

    private func handle(_ event: NSEvent) {
        guard let shortcut = CapturedShortcut(event: event) else {
            return
        }

        onShortcut?(shortcut)
    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.controlBackgroundColor.setFill()
        NSBezierPath(roundedRect: bounds, xRadius: 8, yRadius: 8).fill()
    }
}

private extension CapturedShortcut {
    init?(event: NSEvent) {
        guard let characters = event.charactersIgnoringModifiers, !characters.isEmpty else {
            return nil
        }

        var modifiers = Set<ShortcutModifier>()
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

        if flags.contains(.command) { modifiers.insert(.command) }
        if flags.contains(.shift) { modifiers.insert(.shift) }
        if flags.contains(.option) { modifiers.insert(.option) }
        if flags.contains(.control) { modifiers.insert(.control) }

        guard !modifiers.isEmpty else {
            return nil
        }

        self.init(key: characters.normalizedShortcutKey, modifiers: modifiers)
    }
}

private struct ShortcutKeyCaps: View {
    let displayText: String

    private var parts: [String] {
        displayText
            .components(separatedBy: "+")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    var body: some View {
        HStack(spacing: 6) {
            ForEach(parts, id: \.self) { part in
                Text(part.shortcutSymbolText)
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
            }
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

private extension String {
    var normalizedShortcutKey: String {
        switch lowercased() {
        case "space", " ":
            return "space"
        case "\t":
            return "tab"
        case "`", "grave":
            return "`"
        default:
            return lowercased()
        }
    }

    var displayShortcutKey: String {
        switch normalizedShortcutKey {
        case "space":
            return "Space"
        case "tab":
            return "Tab"
        default:
            return uppercased()
        }
    }

    var shortcutSymbolText: String {
        switch lowercased() {
        case "command", "cmd":
            return "⌘"
        case "shift":
            return "⇧"
        case "option", "alt":
            return "⌥"
        case "control", "ctrl":
            return "⌃"
        case "space":
            return "Space"
        default:
            return self
        }
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
