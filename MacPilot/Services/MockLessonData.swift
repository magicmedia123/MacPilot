import Foundation

enum MockLessonData {
    static let lessons: [Lesson] = [
        Lesson(
            id: "shortcut-copy",
            title: "Copy with Command C",
            summary: "Replace Ctrl + C with the Mac copy shortcut.",
            category: .shortcuts,
            difficulty: .beginner,
            estimatedMinutes: 3,
            symbolName: "doc.on.doc",
            sortOrder: 0,
            quizQuestion: "What is the Mac shortcut for copy?",
            correctQuizAnswer: "Command + C",
            incorrectQuizAnswerOne: "Control + C",
            incorrectQuizAnswerTwo: "Option + C",
            steps: [
                LessonStep(
                    title: "Copy selected content",
                    detail: "On Mac, Command usually replaces Ctrl for common editing shortcuts.",
                    windowsEquivalent: "Ctrl + C",
                    macAction: "Command + C",
                    sortOrder: 0
                )
            ]
        ),
        Lesson(
            id: "shortcut-paste",
            title: "Paste with Command V",
            summary: "Paste copied text, files, or images with the Mac shortcut.",
            category: .shortcuts,
            difficulty: .beginner,
            estimatedMinutes: 3,
            symbolName: "doc.on.clipboard",
            sortOrder: 1,
            quizQuestion: "What is the Mac shortcut for paste?",
            correctQuizAnswer: "Command + V",
            incorrectQuizAnswerOne: "Control + V",
            incorrectQuizAnswerTwo: "Option + V",
            steps: [
                LessonStep(
                    title: "Paste copied content",
                    detail: "Command + V works in most Mac apps, text fields, folders, and documents.",
                    windowsEquivalent: "Ctrl + V",
                    macAction: "Command + V",
                    sortOrder: 0
                )
            ]
        ),
        Lesson(
            id: "shortcut-app-switching",
            title: "Switch Apps with Command Tab",
            summary: "Move quickly between open Mac apps.",
            category: .navigation,
            difficulty: .beginner,
            estimatedMinutes: 4,
            symbolName: "rectangle.2.swap",
            sortOrder: 2,
            quizQuestion: "What is the Mac shortcut for switching between open apps?",
            correctQuizAnswer: "Command + Tab",
            incorrectQuizAnswerOne: "Option + Tab",
            incorrectQuizAnswerTwo: "Control + Tab",
            steps: [
                LessonStep(
                    title: "Switch between apps",
                    detail: "Command + Tab cycles through applications. Hold Command and tap Tab to keep moving.",
                    windowsEquivalent: "Alt + Tab",
                    macAction: "Command + Tab",
                    sortOrder: 0
                ),
                LessonStep(
                    title: "Switch windows in one app",
                    detail: "If an app has multiple windows open, use the backtick shortcut to cycle within that app.",
                    windowsEquivalent: "Alt + Tab between windows",
                    macAction: "Command + `",
                    sortOrder: 1
                )
            ]
        ),
        Lesson(
            id: "shortcut-spotlight",
            title: "Open Spotlight Search",
            summary: "Launch apps, find files, and calculate from one search box.",
            category: .productivity,
            difficulty: .beginner,
            estimatedMinutes: 4,
            symbolName: "magnifyingglass",
            sortOrder: 3,
            quizQuestion: "What shortcut opens Spotlight Search?",
            correctQuizAnswer: "Command + Space",
            incorrectQuizAnswerOne: "Command + Return",
            incorrectQuizAnswerTwo: "Option + Space",
            steps: [
                LessonStep(
                    title: "Open Spotlight",
                    detail: "Spotlight is often the fastest way to open apps or find a recent file.",
                    windowsEquivalent: "Windows key, then type",
                    macAction: "Command + Space",
                    sortOrder: 0
                ),
                LessonStep(
                    title: "Search or calculate",
                    detail: "Type an app name, file name, or simple math expression, then press Return.",
                    windowsEquivalent: "Start menu search",
                    macAction: "Command + Space, then type",
                    sortOrder: 1
                )
            ]
        ),
        Lesson(
            id: "shortcut-screenshots",
            title: "Take Screenshots",
            summary: "Capture the screen, a selected area, or open screenshot tools.",
            category: .productivity,
            difficulty: .comfortable,
            estimatedMinutes: 5,
            symbolName: "camera.viewfinder",
            sortOrder: 4,
            quizQuestion: "What shortcut opens the Mac screenshot toolbar?",
            correctQuizAnswer: "Command + Shift + 5",
            incorrectQuizAnswerOne: "Command + Shift + 3",
            incorrectQuizAnswerTwo: "Control + Print Screen",
            steps: [
                LessonStep(
                    title: "Capture the whole screen",
                    detail: "Use this when you want an instant full-screen screenshot.",
                    windowsEquivalent: "Print Screen",
                    macAction: "Command + Shift + 3",
                    sortOrder: 0
                ),
                LessonStep(
                    title: "Capture a selected area",
                    detail: "Drag across the area you want to capture.",
                    windowsEquivalent: "Windows + Shift + S",
                    macAction: "Command + Shift + 4",
                    sortOrder: 1
                ),
                LessonStep(
                    title: "Open screenshot controls",
                    detail: "Use the toolbar when you want more options, including screen recording.",
                    windowsEquivalent: "Snipping Tool",
                    macAction: "Command + Shift + 5",
                    sortOrder: 2
                )
            ]
        )
    ]
}
