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

    private var hasPassedPracticeCheck: Bool {
        hasCompletedKeyboardPractice || selectedQuizAnswer == correctQuizAnswer || lesson.isCompleted
    }

    private var expectedShortcut: CapturedShortcut? {
        CapturedShortcut(displayString: correctQuizAnswer)
    }

    private var canUseKeyboardPractice: Bool {
        expectedShortcut != nil
    }

    private var macFallbackIcon: String {
        lesson.category == .gestures ? "hand.draw" : "macwindow"
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
            .frame(maxWidth: 880, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .navigationTitle(lesson.title)
        .overlay(alignment: .top) {
            if showsCompletionToast {
                Label("Lesson Complete!", systemImage: "checkmark.seal.fill")
                    .font(.headline)
                    .foregroundStyle(.green)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(.regularMaterial, in: Capsule())
                    .overlay {
                        Capsule().strokeBorder(.green.opacity(0.3))
                    }
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
            resetPracticeState()
            lesson = newLesson
        }
    }

    // MARK: - Header

    private var header: some View {
        CardView(padding: 22, hoverLift: false) {
            HStack(alignment: .top, spacing: 18) {
                IconTile(systemImage: lesson.symbolName, tint: lesson.category.tint, size: 62, cornerRadius: 14)
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: 9) {
                    HStack(spacing: 7) {
                        MetaChip(text: lesson.category.shortName, systemImage: lesson.category.symbolName, tint: lesson.category.tint)
                        DifficultyBadge(difficulty: lesson.difficulty)
                        MetaChip(text: "\(lesson.estimatedMinutes) min", systemImage: "clock")

                        if lesson.isCompleted {
                            MetaChip(text: "Completed", systemImage: "checkmark.circle.fill", tint: .green)
                        }
                    }

                    Text(lesson.title)
                        .font(.system(size: 28, weight: .bold))

                    Text(lesson.summary)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
        }
    }

    // MARK: - Steps

    private var stepList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Practice steps")
                .font(.headline)

            ForEach(Array(sortedSteps.enumerated()), id: \.element.sortOrder) { index, step in
                stepCard(step, number: index + 1)
            }
        }
    }

    private func stepCard(_ step: LessonStep, number: Int) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: 13) {
                HStack(alignment: .firstTextBaseline, spacing: 11) {
                    Text("\(number)")
                        .font(.system(.callout, design: .rounded).weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .background(lesson.category.tint.gradient, in: Circle())

                    VStack(alignment: .leading, spacing: 5) {
                        Text(step.title)
                            .font(.title3.weight(.semibold))

                        Text(step.detail)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Divider()

                Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 10) {
                    GridRow {
                        HStack(spacing: 5) {
                            Circle().fill(.secondary).frame(width: 6, height: 6)
                            Text("Windows")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                        .gridColumnAlignment(.leading)

                        ShortcutDisplay(text: step.windowsEquivalent, style: .windows, fallbackIcon: "computermouse")
                    }

                    GridRow {
                        HStack(spacing: 5) {
                            Circle().fill(Color.accentColor).frame(width: 6, height: 6)
                            Text("Mac")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.accentColor)
                        }

                        ShortcutDisplay(text: step.macAction, style: .mac, fallbackIcon: macFallbackIcon)
                    }
                }
                .padding(.leading, 35)
            }
        }
    }

    // MARK: - Practice (quiz)

    private var practiceCheck: some View {
        PracticeSection(
            title: "Practice check",
            systemImage: hasPassedPracticeCheck ? "checkmark.circle.fill" : "questionmark.circle",
            tint: .green,
            isComplete: hasPassedPracticeCheck
        ) {
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
                        withAnimation(.easeOut(duration: 0.2)) {
                            selectedQuizAnswer = answer
                        }
                    }
                }
            }

            if let selectedQuizAnswer {
                Label(
                    selectedQuizAnswer == correctQuizAnswer
                        ? "Correct! You can complete this lesson."
                        : "Not quite — look back at the Mac action above.",
                    systemImage: selectedQuizAnswer == correctQuizAnswer ? "checkmark.circle.fill" : "xmark.circle.fill"
                )
                .font(.callout.weight(.medium))
                .foregroundStyle(selectedQuizAnswer == correctQuizAnswer ? .green : .red)
            }
        }
    }

    // MARK: - Practice (keyboard)

    private var keyboardPractice: some View {
        PracticeSection(
            title: "Keyboard practice",
            systemImage: hasCompletedKeyboardPractice ? "checkmark.circle.fill" : "keyboard",
            tint: .blue,
            isComplete: hasCompletedKeyboardPractice
        ) {
            HStack(spacing: 12) {
                Text("Press")
                    .font(.title3.weight(.semibold))

                ShortcutDisplay(text: correctQuizAnswer, style: .mac, large: true)

                Text("for real")
                    .font(.title3.weight(.semibold))
            }

            ShortcutCaptureWell(
                expected: expectedShortcut,
                captured: $capturedShortcut,
                isSuccessful: $hasCompletedKeyboardPractice
            )

            if !hasCompletedKeyboardPractice {
                HStack {
                    Text("Some system-wide shortcuts are handled by macOS before MacPilot can see them.")
                        .font(.caption)
                        .foregroundStyle(.tertiary)

                    Spacer()

                    Button {
                        withAnimation(.spring(duration: 0.35)) {
                            hasCompletedKeyboardPractice = true
                        }
                    } label: {
                        Label("I Practiced It", systemImage: "hand.thumbsup")
                    }
                    .buttonStyle(.bordered)
                    .help("Mark the practice as done if macOS intercepted the shortcut.")
                }
            }
        }
    }

    // MARK: - Completion

    private var completionControl: some View {
        CardView(padding: 20) {
            HStack(spacing: 14) {
                Image(systemName: lesson.isCompleted ? "checkmark.seal.fill" : "seal")
                    .font(.system(size: 30))
                    .foregroundStyle(lesson.isCompleted ? .green : .secondary)
                    .contentTransition(.symbolEffect(.replace))

                VStack(alignment: .leading, spacing: 4) {
                    Text(lesson.isCompleted ? "Lesson complete" : "Finish this lesson")
                        .font(.headline)

                    Text(lesson.isCompleted
                        ? "Nice work — it now counts toward your progress and spaced reviews."
                        : hasPassedPracticeCheck
                            ? "You passed the practice check. Mark it complete to keep your streak."
                            : "Pass the practice check above to unlock completion.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if lesson.isCompleted {
                    HStack(spacing: 10) {
                        Button {
                            toggleCompletion()
                        } label: {
                            Label("Mark Incomplete", systemImage: "arrow.uturn.backward")
                        }
                        .buttonStyle(.bordered)

                        if let next = nextLesson {
                            Button {
                                navigateToNext(next)
                            } label: {
                                Label("Next Lesson", systemImage: "arrow.forward")
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                } else {
                    Button {
                        toggleCompletion()
                    } label: {
                        Label("Complete Lesson", systemImage: "checkmark")
                            .padding(.horizontal, 4)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(!hasPassedPracticeCheck)
                }
            }
        }
    }

    // MARK: - Actions

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
        resetPracticeState()
        withAnimation(.easeInOut(duration: 0.3)) {
            lesson = next
        }
    }

    private func resetPracticeState() {
        capturedShortcut = nil
        hasCompletedKeyboardPractice = false
        selectedQuizAnswer = nil
        showsCompletionCelebration = false
        showsCompletionToast = false
    }
}

// MARK: - Practice section chrome

private struct PracticeSection<Content: View>: View {
    let title: String
    let systemImage: String
    let tint: Color
    let isComplete: Bool
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .foregroundStyle(isComplete ? .green : tint)
                    .contentTransition(.symbolEffect(.replace))

                Text(title)
                    .font(.headline)

                Spacer()

                if isComplete {
                    MetaChip(text: "Passed", systemImage: "checkmark", tint: .green)
                }
            }

            content
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            (isComplete ? Color.green : tint).opacity(0.07),
                            (isComplete ? Color.green : tint).opacity(0.02)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous)
                .strokeBorder((isComplete ? Color.green : tint).opacity(0.25), lineWidth: 1.5)
        )
        .animation(.easeOut(duration: 0.25), value: isComplete)
    }
}

// MARK: - Capture well

/// The interactive area that listens for the real keyboard shortcut.
/// Click to focus; it shows its state (idle / listening / wrong / success) inline.
private struct ShortcutCaptureWell: View {
    let expected: CapturedShortcut?
    @Binding var captured: CapturedShortcut?
    @Binding var isSuccessful: Bool

    @State private var isFocused = false

    var body: some View {
        ZStack {
            KeyboardShortcutCaptureView(
                onShortcut: { shortcut in
                    captured = shortcut
                    if shortcut == expected {
                        withAnimation(.spring(duration: 0.35)) {
                            isSuccessful = true
                        }
                    }
                },
                onFocusChange: { focused in
                    withAnimation(.easeOut(duration: 0.18)) {
                        isFocused = focused
                    }
                }
            )

            statusContent
                .allowsHitTesting(false)
        }
        .frame(height: 86)
        .background(wellBackground, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(
                    borderColor,
                    style: StrokeStyle(lineWidth: isFocused || isSuccessful ? 2 : 1.5, dash: isSuccessful || isFocused ? [] : [6, 4])
                )
        }
    }

    @ViewBuilder
    private var statusContent: some View {
        if isSuccessful {
            Label("Nailed it! That's the Mac way.", systemImage: "checkmark.circle.fill")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.green)
        } else if let captured {
            VStack(spacing: 6) {
                HStack(spacing: 7) {
                    Text("You pressed")
                        .foregroundStyle(.secondary)
                    Text(captured.displayText)
                        .font(.system(.title3, design: .rounded).weight(.bold))
                        .foregroundStyle(.red)
                }
                Text("Try again — check the keys above.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        } else if isFocused {
            VStack(spacing: 6) {
                Image(systemName: "ear")
                    .font(.title2)
                    .foregroundStyle(Color.accentColor)
                Text("Listening — press the shortcut now")
                    .font(.callout.weight(.medium))
                    .foregroundStyle(Color.accentColor)
            }
        } else {
            VStack(spacing: 6) {
                Image(systemName: "cursorarrow.click")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                Text("Click here, then press the shortcut")
                    .font(.callout.weight(.medium))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var wellBackground: Color {
        if isSuccessful { return .green.opacity(0.08) }
        if captured != nil && !isSuccessful { return .red.opacity(0.05) }
        return Color(nsColor: .controlBackgroundColor)
    }

    private var borderColor: Color {
        if isSuccessful { return .green.opacity(0.6) }
        if captured != nil { return .red.opacity(0.45) }
        if isFocused { return .accentColor.opacity(0.7) }
        return .secondary.opacity(0.35)
    }
}

// MARK: - Shortcut capture plumbing

struct CapturedShortcut: Equatable {
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

        // Reject "keys" that are really descriptions ("scroll wheel up").
        guard keyPart.count == 1 || keyPart.normalizedShortcutKey != keyPart.lowercased() || ["space", "tab"].contains(keyPart.lowercased()) else {
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

enum ShortcutModifier: Hashable {
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
    let onFocusChange: (Bool) -> Void

    func makeNSView(context: Context) -> ShortcutCaptureNSView {
        let view = ShortcutCaptureNSView()
        view.onShortcut = onShortcut
        view.onFocusChange = onFocusChange
        return view
    }

    func updateNSView(_ nsView: ShortcutCaptureNSView, context: Context) {
        nsView.onShortcut = onShortcut
        nsView.onFocusChange = onFocusChange
    }
}

private final class ShortcutCaptureNSView: NSView {
    var onShortcut: ((CapturedShortcut) -> Void)?
    var onFocusChange: ((Bool) -> Void)?

    override var acceptsFirstResponder: Bool {
        true
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        // Grab focus once when the practice area appears so the user can
        // try the shortcut immediately; afterwards focus moves naturally.
        window?.makeFirstResponder(self)
    }

    override func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(self)
    }

    override func becomeFirstResponder() -> Bool {
        onFocusChange?(true)
        return super.becomeFirstResponder()
    }

    override func resignFirstResponder() -> Bool {
        onFocusChange?(false)
        return super.resignFirstResponder()
    }

    override func keyDown(with event: NSEvent) {
        handle(event)
    }

    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        // Swallow key equivalents while practicing so trying ⌘W or ⌘Q
        // exercises the muscle memory instead of closing the app.
        guard window?.firstResponder === self else {
            return false
        }
        handle(event)
        return true
    }

    private func handle(_ event: NSEvent) {
        guard let shortcut = CapturedShortcut(event: event) else {
            return
        }

        onShortcut?(shortcut)
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

// MARK: - Quiz answer

private struct QuizAnswerButton: View {
    let answer: String
    let isSelected: Bool
    let isCorrect: Bool
    let hasSelection: Bool
    let action: () -> Void

    @State private var isHovered = false

    private var borderColor: Color {
        if isSelected && isCorrect { return .green }
        if isSelected && !isCorrect { return .red }
        if isHovered { return .secondary.opacity(0.5) }
        return .secondary.opacity(0.25)
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: radioSymbol)
                    .foregroundStyle(radioColor)

                Text(answer)
                    .font(.body.weight(.medium))

                Spacer()

                if hasSelection && isCorrect && !isSelected {
                    Text("Correct answer")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .background(
                Color.secondary.opacity(isSelected ? 0.14 : isHovered ? 0.1 : 0.06),
                in: RoundedRectangle(cornerRadius: 9, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: isSelected ? 1.5 : 1)
            }
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }

    private var radioSymbol: String {
        if isSelected {
            return isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill"
        }
        if hasSelection && isCorrect {
            return "checkmark.circle"
        }
        return "circle"
    }

    private var radioColor: Color {
        if isSelected {
            return isCorrect ? .green : .red
        }
        if hasSelection && isCorrect {
            return .green
        }
        return .secondary
    }
}

// MARK: - Helpers

private extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

extension String {
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
}
