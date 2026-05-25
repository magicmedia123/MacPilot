import Foundation

enum MockLessonData {
    static let lessons: [Lesson] = [

        // ──────────────────────────────────────────────
        // MARK: - Keyboard Shortcuts
        // ──────────────────────────────────────────────

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
            id: "shortcut-cut",
            title: "Cut with Command X",
            summary: "Learn how to cut text and move files using Mac shortcuts.",
            category: .shortcuts,
            difficulty: .beginner,
            estimatedMinutes: 3,
            symbolName: "scissors",
            sortOrder: 2,
            quizQuestion: "What is the Mac shortcut for cut?",
            correctQuizAnswer: "Command + X",
            incorrectQuizAnswerOne: "Control + X",
            incorrectQuizAnswerTwo: "Option + X",
            steps: [
                LessonStep(
                    title: "Cut text in a document",
                    detail: "Command + X removes the selected text and places it on the clipboard, just like Ctrl + X on Windows.",
                    windowsEquivalent: "Ctrl + X",
                    macAction: "Command + X",
                    sortOrder: 0
                ),
                LessonStep(
                    title: "Move files in Finder",
                    detail: "In Finder, copy a file with Command + C, then move it using Command + Option + V instead of a direct cut.",
                    windowsEquivalent: "Ctrl + X, then Ctrl + V",
                    macAction: "Command + C, then Command + Option + V",
                    sortOrder: 1
                )
            ]
        ),
        Lesson(
            id: "shortcut-undo-redo",
            title: "Undo and Redo",
            summary: "Quickly reverse or reapply your last actions on Mac.",
            category: .shortcuts,
            difficulty: .beginner,
            estimatedMinutes: 3,
            symbolName: "arrow.uturn.backward",
            sortOrder: 3,
            quizQuestion: "What is the Mac shortcut for undo?",
            correctQuizAnswer: "Command + Z",
            incorrectQuizAnswerOne: "Control + Z",
            incorrectQuizAnswerTwo: "Option + Z",
            steps: [
                LessonStep(
                    title: "Undo your last action",
                    detail: "Command + Z reverses the most recent change in nearly every Mac app.",
                    windowsEquivalent: "Ctrl + Z",
                    macAction: "Command + Z",
                    sortOrder: 0
                ),
                LessonStep(
                    title: "Redo an undone action",
                    detail: "If you undo too far, redo brings back the change you just reversed.",
                    windowsEquivalent: "Ctrl + Y",
                    macAction: "Command + Shift + Z",
                    sortOrder: 1
                )
            ]
        ),
        Lesson(
            id: "shortcut-select-all",
            title: "Select All with Command A",
            summary: "Select everything in a document, folder, or text field instantly.",
            category: .shortcuts,
            difficulty: .beginner,
            estimatedMinutes: 3,
            symbolName: "selection.pin.in.out",
            sortOrder: 4,
            quizQuestion: "What is the Mac shortcut for Select All?",
            correctQuizAnswer: "Command + A",
            incorrectQuizAnswerOne: "Control + A",
            incorrectQuizAnswerTwo: "Option + A",
            steps: [
                LessonStep(
                    title: "Select all text or items",
                    detail: "Command + A selects everything in the current context — all text in a document or all files in a Finder window.",
                    windowsEquivalent: "Ctrl + A",
                    macAction: "Command + A",
                    sortOrder: 0
                )
            ]
        ),
        Lesson(
            id: "shortcut-find",
            title: "Find with Command F",
            summary: "Search within documents and web pages using the Mac find shortcut.",
            category: .shortcuts,
            difficulty: .comfortable,
            estimatedMinutes: 4,
            symbolName: "doc.text.magnifyingglass",
            sortOrder: 5,
            quizQuestion: "What is the Mac shortcut to open Find?",
            correctQuizAnswer: "Command + F",
            incorrectQuizAnswerOne: "Control + F",
            incorrectQuizAnswerTwo: "Command + G",
            steps: [
                LessonStep(
                    title: "Open the Find bar",
                    detail: "Command + F opens a search bar in most apps, including browsers, text editors, and documents.",
                    windowsEquivalent: "Ctrl + F",
                    macAction: "Command + F",
                    sortOrder: 0
                ),
                LessonStep(
                    title: "Find the next match",
                    detail: "After searching, jump to the next result without clicking.",
                    windowsEquivalent: "F3 or Enter",
                    macAction: "Command + G",
                    sortOrder: 1
                ),
                LessonStep(
                    title: "Find and Replace",
                    detail: "Open Find and Replace to swap text throughout a document.",
                    windowsEquivalent: "Ctrl + H",
                    macAction: "Command + Option + F",
                    sortOrder: 2
                )
            ]
        ),
        Lesson(
            id: "shortcut-save",
            title: "Save with Command S",
            summary: "Save your work instantly using the Mac save shortcut.",
            category: .shortcuts,
            difficulty: .beginner,
            estimatedMinutes: 3,
            symbolName: "square.and.arrow.down",
            sortOrder: 6,
            quizQuestion: "What is the Mac shortcut for Save?",
            correctQuizAnswer: "Command + S",
            incorrectQuizAnswerOne: "Control + S",
            incorrectQuizAnswerTwo: "Option + S",
            steps: [
                LessonStep(
                    title: "Save the current file",
                    detail: "Command + S saves your document. Build the habit of pressing it frequently.",
                    windowsEquivalent: "Ctrl + S",
                    macAction: "Command + S",
                    sortOrder: 0
                ),
                LessonStep(
                    title: "Save As a new file",
                    detail: "Use Save As to create a copy of the current document with a new name or location.",
                    windowsEquivalent: "Ctrl + Shift + S or F12",
                    macAction: "Command + Shift + S",
                    sortOrder: 1
                )
            ]
        ),
        Lesson(
            id: "shortcut-close-quit",
            title: "Close and Quit",
            summary: "Learn the difference between closing a window and quitting an app on Mac.",
            category: .shortcuts,
            difficulty: .comfortable,
            estimatedMinutes: 4,
            symbolName: "xmark.circle",
            sortOrder: 7,
            quizQuestion: "What is the Mac shortcut to quit an app entirely?",
            correctQuizAnswer: "Command + Q",
            incorrectQuizAnswerOne: "Command + W",
            incorrectQuizAnswerTwo: "Option + Q",
            steps: [
                LessonStep(
                    title: "Close the current window",
                    detail: "Command + W closes the frontmost window or tab but keeps the app running in the background.",
                    windowsEquivalent: "Alt + F4 (closes window)",
                    macAction: "Command + W",
                    sortOrder: 0
                ),
                LessonStep(
                    title: "Quit the entire app",
                    detail: "On Mac, closing all windows does not quit the app. Use Command + Q to fully exit.",
                    windowsEquivalent: "Alt + F4 (closes app)",
                    macAction: "Command + Q",
                    sortOrder: 1
                ),
                LessonStep(
                    title: "Close a tab",
                    detail: "In browsers and tabbed editors, Command + W also closes the active tab.",
                    windowsEquivalent: "Ctrl + W",
                    macAction: "Command + W",
                    sortOrder: 2
                )
            ]
        ),

        // ──────────────────────────────────────────────
        // MARK: - Touchpad Gestures
        // ──────────────────────────────────────────────

        Lesson(
            id: "gesture-two-finger-scroll",
            title: "Two-Finger Scrolling",
            summary: "Scroll through pages and documents using Mac trackpad gestures.",
            category: .gestures,
            difficulty: .beginner,
            estimatedMinutes: 3,
            symbolName: "hand.draw",
            sortOrder: 8,
            quizQuestion: "How do you scroll on a Mac trackpad?",
            correctQuizAnswer: "Slide two fingers up or down",
            incorrectQuizAnswerOne: "Slide one finger up or down",
            incorrectQuizAnswerTwo: "Click and drag the scroll bar",
            steps: [
                LessonStep(
                    title: "Scroll vertically",
                    detail: "Place two fingers on the trackpad and slide up or down to scroll through content.",
                    windowsEquivalent: "Mouse scroll wheel",
                    macAction: "Two-finger slide up or down",
                    sortOrder: 0
                ),
                LessonStep(
                    title: "Scroll horizontally",
                    detail: "Slide two fingers left or right to scroll horizontally in apps that support it, like spreadsheets or timelines.",
                    windowsEquivalent: "Shift + scroll wheel",
                    macAction: "Two-finger slide left or right",
                    sortOrder: 1
                )
            ]
        ),
        Lesson(
            id: "gesture-pinch-to-zoom",
            title: "Pinch to Zoom",
            summary: "Zoom in and out on images, maps, and web pages with a pinch gesture.",
            category: .gestures,
            difficulty: .beginner,
            estimatedMinutes: 3,
            symbolName: "arrow.up.left.and.arrow.down.right",
            sortOrder: 9,
            quizQuestion: "How do you zoom in on a Mac trackpad?",
            correctQuizAnswer: "Pinch two fingers apart",
            incorrectQuizAnswerOne: "Double-tap with two fingers",
            incorrectQuizAnswerTwo: "Press Command and scroll up",
            steps: [
                LessonStep(
                    title: "Zoom in",
                    detail: "Place two fingers on the trackpad and spread them apart to zoom in on content.",
                    windowsEquivalent: "Ctrl + scroll wheel up",
                    macAction: "Pinch two fingers apart",
                    sortOrder: 0
                ),
                LessonStep(
                    title: "Zoom out",
                    detail: "Pinch two fingers together on the trackpad to zoom out.",
                    windowsEquivalent: "Ctrl + scroll wheel down",
                    macAction: "Pinch two fingers together",
                    sortOrder: 1
                )
            ]
        ),
        Lesson(
            id: "gesture-two-finger-swipe-nav",
            title: "Two-Finger Swipe Navigation",
            summary: "Navigate back and forward in browsers and apps with swipe gestures.",
            category: .gestures,
            difficulty: .comfortable,
            estimatedMinutes: 4,
            symbolName: "hand.point.left",
            sortOrder: 10,
            quizQuestion: "How do you go back a page in Safari using the trackpad?",
            correctQuizAnswer: "Swipe two fingers from left to right",
            incorrectQuizAnswerOne: "Swipe three fingers to the left",
            incorrectQuizAnswerTwo: "Pinch with two fingers",
            steps: [
                LessonStep(
                    title: "Go back",
                    detail: "Swipe two fingers from left to right on the trackpad to go back in Safari, Finder, and many other apps.",
                    windowsEquivalent: "Alt + Left Arrow or Back button",
                    macAction: "Two-finger swipe from left to right",
                    sortOrder: 0
                ),
                LessonStep(
                    title: "Go forward",
                    detail: "Swipe two fingers from right to left to go forward to a page you navigated back from.",
                    windowsEquivalent: "Alt + Right Arrow or Forward button",
                    macAction: "Two-finger swipe from right to left",
                    sortOrder: 1
                )
            ]
        ),
        Lesson(
            id: "gesture-three-finger-swipe",
            title: "Three-Finger Swipe for Desktops",
            summary: "Switch between virtual desktops using a three-finger swipe.",
            category: .gestures,
            difficulty: .comfortable,
            estimatedMinutes: 4,
            symbolName: "rectangle.split.3x1",
            sortOrder: 11,
            quizQuestion: "How do you switch between desktops on a Mac trackpad?",
            correctQuizAnswer: "Swipe left or right with three fingers",
            incorrectQuizAnswerOne: "Swipe up with four fingers",
            incorrectQuizAnswerTwo: "Double-tap with three fingers",
            steps: [
                LessonStep(
                    title: "Switch to the next desktop",
                    detail: "Swipe three fingers to the left on the trackpad to move to the next virtual desktop or full-screen app.",
                    windowsEquivalent: "Ctrl + Win + Right Arrow",
                    macAction: "Three-finger swipe left",
                    sortOrder: 0
                ),
                LessonStep(
                    title: "Switch to the previous desktop",
                    detail: "Swipe three fingers to the right to return to the previous desktop.",
                    windowsEquivalent: "Ctrl + Win + Left Arrow",
                    macAction: "Three-finger swipe right",
                    sortOrder: 1
                )
            ]
        ),
        Lesson(
            id: "gesture-mission-control",
            title: "Mission Control Gesture",
            summary: "See all open windows and desktops with a trackpad swipe.",
            category: .gestures,
            difficulty: .advanced,
            estimatedMinutes: 5,
            symbolName: "square.3.layers.3d",
            sortOrder: 12,
            quizQuestion: "How do you open Mission Control with the trackpad?",
            correctQuizAnswer: "Swipe up with three fingers",
            incorrectQuizAnswerOne: "Swipe down with three fingers",
            incorrectQuizAnswerTwo: "Double-tap with four fingers",
            steps: [
                LessonStep(
                    title: "Open Mission Control",
                    detail: "Swipe up with three fingers to see all open windows, desktops, and full-screen apps at a glance.",
                    windowsEquivalent: "Win + Tab (Task View)",
                    macAction: "Three-finger swipe up",
                    sortOrder: 0
                ),
                LessonStep(
                    title: "Show the desktop",
                    detail: "Spread your thumb and three fingers apart on the trackpad to quickly reveal the desktop.",
                    windowsEquivalent: "Win + D",
                    macAction: "Spread thumb and three fingers apart",
                    sortOrder: 1
                ),
                LessonStep(
                    title: "App Exposé",
                    detail: "Swipe down with three fingers to see all open windows of the current app.",
                    windowsEquivalent: "No direct equivalent",
                    macAction: "Three-finger swipe down",
                    sortOrder: 2
                )
            ]
        ),
        Lesson(
            id: "gesture-smart-zoom-rotate",
            title: "Smart Zoom and Rotate",
            summary: "Double-tap to smart zoom and use rotation gestures like a pro.",
            category: .gestures,
            difficulty: .advanced,
            estimatedMinutes: 5,
            symbolName: "rotate.right",
            sortOrder: 13,
            quizQuestion: "How do you smart zoom on a Mac trackpad?",
            correctQuizAnswer: "Double-tap with two fingers",
            incorrectQuizAnswerOne: "Pinch with two fingers",
            incorrectQuizAnswerTwo: "Triple-tap with one finger",
            steps: [
                LessonStep(
                    title: "Smart Zoom",
                    detail: "Double-tap with two fingers on a web page or document to zoom into the content under the cursor, then double-tap again to zoom back out.",
                    windowsEquivalent: "Ctrl + scroll wheel or Ctrl + Plus",
                    macAction: "Double-tap with two fingers",
                    sortOrder: 0
                ),
                LessonStep(
                    title: "Rotate content",
                    detail: "Place two fingers on the trackpad and rotate them clockwise or counterclockwise. Works in Preview, Photos, and Maps.",
                    windowsEquivalent: "Rotate button in toolbar",
                    macAction: "Rotate two fingers on trackpad",
                    sortOrder: 1
                )
            ]
        ),

        // ──────────────────────────────────────────────
        // MARK: - Mac Navigation
        // ──────────────────────────────────────────────

        Lesson(
            id: "shortcut-app-switching",
            title: "Switch Apps with Command Tab",
            summary: "Move quickly between open Mac apps.",
            category: .navigation,
            difficulty: .beginner,
            estimatedMinutes: 4,
            symbolName: "rectangle.2.swap",
            sortOrder: 14,
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
            id: "navigation-finder-basics",
            title: "Finder Basics",
            summary: "Navigate the Mac file system using Finder, the Mac equivalent of File Explorer.",
            category: .navigation,
            difficulty: .beginner,
            estimatedMinutes: 5,
            symbolName: "folder",
            sortOrder: 15,
            quizQuestion: "What is the Mac shortcut to open a new Finder window?",
            correctQuizAnswer: "Command + N (in Finder)",
            incorrectQuizAnswerOne: "Command + F",
            incorrectQuizAnswerTwo: "Command + E",
            steps: [
                LessonStep(
                    title: "Open a new Finder window",
                    detail: "Click the Finder icon in the Dock, or press Command + N while Finder is active to open a new window.",
                    windowsEquivalent: "Win + E (File Explorer)",
                    macAction: "Click Finder in Dock or Command + N",
                    sortOrder: 0
                ),
                LessonStep(
                    title: "Navigate with the path bar",
                    detail: "Enable the path bar at the bottom of Finder to see your current location and click any folder in the path to jump there.",
                    windowsEquivalent: "Address bar in File Explorer",
                    macAction: "View → Show Path Bar (Option + Command + P)",
                    sortOrder: 1
                ),
                LessonStep(
                    title: "Go to a folder by path",
                    detail: "Jump directly to any folder by typing its path, such as ~/Documents or /Applications.",
                    windowsEquivalent: "Type path in address bar",
                    macAction: "Command + Shift + G",
                    sortOrder: 2
                ),
                LessonStep(
                    title: "Switch Finder views",
                    detail: "Finder offers Icon, List, Column, and Gallery views. Column view is great for browsing nested folders.",
                    windowsEquivalent: "View options in File Explorer",
                    macAction: "Command + 1 (Icon), 2 (List), 3 (Column), 4 (Gallery)",
                    sortOrder: 3
                )
            ]
        ),
        Lesson(
            id: "navigation-quick-look",
            title: "Quick Look with Space Bar",
            summary: "Preview files instantly without opening an app using Quick Look.",
            category: .navigation,
            difficulty: .beginner,
            estimatedMinutes: 3,
            symbolName: "eye",
            sortOrder: 16,
            quizQuestion: "How do you preview a file in Finder without opening it?",
            correctQuizAnswer: "Select the file and press Space",
            incorrectQuizAnswerOne: "Double-click the file",
            incorrectQuizAnswerTwo: "Right-click and choose Preview",
            steps: [
                LessonStep(
                    title: "Preview a file",
                    detail: "Select any file in Finder and press Space to instantly preview it — images, PDFs, videos, text files, and more.",
                    windowsEquivalent: "No direct equivalent (must open file)",
                    macAction: "Select file, then press Space",
                    sortOrder: 0
                ),
                LessonStep(
                    title: "Close Quick Look",
                    detail: "Press Space again or press Escape to dismiss the Quick Look preview.",
                    windowsEquivalent: "Close the opened app",
                    macAction: "Press Space or Escape",
                    sortOrder: 1
                )
            ]
        ),
        Lesson(
            id: "navigation-dock",
            title: "Dock Navigation",
            summary: "Use the Dock to launch, switch, and manage your favorite Mac apps.",
            category: .navigation,
            difficulty: .comfortable,
            estimatedMinutes: 5,
            symbolName: "dock.rectangle",
            sortOrder: 17,
            quizQuestion: "How can you see all open windows for a Dock app?",
            correctQuizAnswer: "Right-click or Control-click the app icon",
            incorrectQuizAnswerOne: "Double-click the app icon",
            incorrectQuizAnswerTwo: "Option-click the app icon",
            steps: [
                LessonStep(
                    title: "Launch and switch apps",
                    detail: "Click any app icon in the Dock to launch or switch to it. A small dot under an icon means the app is running.",
                    windowsEquivalent: "Click app on Taskbar",
                    macAction: "Click app icon in the Dock",
                    sortOrder: 0
                ),
                LessonStep(
                    title: "View app options",
                    detail: "Right-click or Control-click a Dock icon to see recent files, open windows, and options to quit the app.",
                    windowsEquivalent: "Right-click Taskbar icon",
                    macAction: "Right-click or Control-click Dock icon",
                    sortOrder: 1
                ),
                LessonStep(
                    title: "Add or remove Dock items",
                    detail: "Drag an app to the Dock to add it, or drag it out and release to remove it. The app is not deleted.",
                    windowsEquivalent: "Pin/unpin from Taskbar",
                    macAction: "Drag app to/from the Dock",
                    sortOrder: 2
                )
            ]
        ),
        Lesson(
            id: "navigation-mission-control-spaces",
            title: "Mission Control and Spaces",
            summary: "Organize your workflow with multiple desktops and Mission Control.",
            category: .navigation,
            difficulty: .advanced,
            estimatedMinutes: 6,
            symbolName: "rectangle.3.group",
            sortOrder: 18,
            quizQuestion: "What keyboard shortcut opens Mission Control?",
            correctQuizAnswer: "Control + Up Arrow",
            incorrectQuizAnswerOne: "Command + Up Arrow",
            incorrectQuizAnswerTwo: "Option + Up Arrow",
            steps: [
                LessonStep(
                    title: "Open Mission Control",
                    detail: "Mission Control shows all open windows, desktops, and full-screen apps in one view.",
                    windowsEquivalent: "Win + Tab (Task View)",
                    macAction: "Control + Up Arrow or F3",
                    sortOrder: 0
                ),
                LessonStep(
                    title: "Create a new desktop",
                    detail: "In Mission Control, hover at the top-right and click the + button to add a new desktop Space.",
                    windowsEquivalent: "Win + Tab → New Desktop",
                    macAction: "Open Mission Control, click + in top-right",
                    sortOrder: 1
                ),
                LessonStep(
                    title: "Move windows between Spaces",
                    detail: "In Mission Control, drag a window to a different desktop at the top of the screen.",
                    windowsEquivalent: "Win + Tab → drag window to desktop",
                    macAction: "Drag window to another Space in Mission Control",
                    sortOrder: 2
                ),
                LessonStep(
                    title: "Switch between Spaces",
                    detail: "Use keyboard shortcuts to move between desktops without Mission Control.",
                    windowsEquivalent: "Ctrl + Win + Arrow keys",
                    macAction: "Control + Left/Right Arrow",
                    sortOrder: 3
                )
            ]
        ),
        Lesson(
            id: "navigation-launchpad",
            title: "Launchpad and App Management",
            summary: "Find, organize, and delete apps using Launchpad on Mac.",
            category: .navigation,
            difficulty: .comfortable,
            estimatedMinutes: 4,
            symbolName: "square.grid.3x3",
            sortOrder: 19,
            quizQuestion: "How do you open Launchpad from the keyboard?",
            correctQuizAnswer: "Press F4 or pinch with thumb and three fingers",
            incorrectQuizAnswerOne: "Press Command + L",
            incorrectQuizAnswerTwo: "Press Command + Space",
            steps: [
                LessonStep(
                    title: "Open Launchpad",
                    detail: "Launchpad shows all your installed apps in a full-screen grid, similar to the Windows Start menu app list.",
                    windowsEquivalent: "Start menu → All Apps",
                    macAction: "Click Launchpad in Dock, press F4, or pinch with thumb and three fingers",
                    sortOrder: 0
                ),
                LessonStep(
                    title: "Search for an app",
                    detail: "Start typing an app name while Launchpad is open to filter and find it quickly.",
                    windowsEquivalent: "Start menu → type app name",
                    macAction: "Open Launchpad, then type app name",
                    sortOrder: 1
                ),
                LessonStep(
                    title: "Delete an app from Launchpad",
                    detail: "Click and hold an app icon until it jiggles, then click the X to delete apps installed from the App Store.",
                    windowsEquivalent: "Settings → Apps → Uninstall",
                    macAction: "Hold Option in Launchpad, click X on app",
                    sortOrder: 2
                )
            ]
        ),

        // ──────────────────────────────────────────────
        // MARK: - Productivity
        // ──────────────────────────────────────────────

        Lesson(
            id: "shortcut-spotlight",
            title: "Open Spotlight Search",
            summary: "Launch apps, find files, and calculate from one search box.",
            category: .productivity,
            difficulty: .beginner,
            estimatedMinutes: 4,
            symbolName: "magnifyingglass",
            sortOrder: 20,
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
            sortOrder: 21,
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
        ),
        Lesson(
            id: "productivity-split-view",
            title: "Split View Window Management",
            summary: "Snap two apps side by side using Mac's built-in Split View.",
            category: .productivity,
            difficulty: .comfortable,
            estimatedMinutes: 5,
            symbolName: "rectangle.split.2x1",
            sortOrder: 22,
            quizQuestion: "How do you enter Split View on Mac?",
            correctQuizAnswer: "Hover over the green window button and choose a tile option",
            incorrectQuizAnswerOne: "Press Command + Left Arrow",
            incorrectQuizAnswerTwo: "Drag a window to the top of the screen",
            steps: [
                LessonStep(
                    title: "Enter Split View",
                    detail: "Hover your cursor over the green full-screen button in the top-left corner of a window. Choose 'Tile Window to Left of Screen' or 'Tile Window to Right of Screen.'",
                    windowsEquivalent: "Win + Left/Right Arrow",
                    macAction: "Hover green button → Tile to Left/Right",
                    sortOrder: 0
                ),
                LessonStep(
                    title: "Choose the second app",
                    detail: "After tiling the first app, your other open windows appear on the opposite side. Click one to fill the remaining half.",
                    windowsEquivalent: "Snap another window to the other side",
                    macAction: "Click a window on the opposite side",
                    sortOrder: 1
                ),
                LessonStep(
                    title: "Adjust and exit Split View",
                    detail: "Drag the divider between the two apps to resize them. Move your cursor to the top to reveal the menu bar and window buttons.",
                    windowsEquivalent: "Drag divider or press Win + Up",
                    macAction: "Drag divider to resize; hover top for controls",
                    sortOrder: 2
                )
            ]
        ),
        Lesson(
            id: "productivity-text-editing",
            title: "Text Editing Power Shortcuts",
            summary: "Master advanced text selection and cursor movement unique to macOS.",
            category: .productivity,
            difficulty: .advanced,
            estimatedMinutes: 6,
            symbolName: "text.cursor",
            sortOrder: 23,
            quizQuestion: "What shortcut moves the cursor to the beginning of a line on Mac?",
            correctQuizAnswer: "Command + Left Arrow",
            incorrectQuizAnswerOne: "Home key",
            incorrectQuizAnswerTwo: "Control + Left Arrow",
            steps: [
                LessonStep(
                    title: "Jump to line start or end",
                    detail: "On Mac, the Home and End keys may behave differently. Use Command + Arrow keys for reliable line navigation.",
                    windowsEquivalent: "Home / End keys",
                    macAction: "Command + Left Arrow (start) / Command + Right Arrow (end)",
                    sortOrder: 0
                ),
                LessonStep(
                    title: "Jump to document start or end",
                    detail: "Quickly move to the very top or bottom of your document.",
                    windowsEquivalent: "Ctrl + Home / Ctrl + End",
                    macAction: "Command + Up Arrow (top) / Command + Down Arrow (bottom)",
                    sortOrder: 1
                ),
                LessonStep(
                    title: "Move word by word",
                    detail: "Jump the cursor one word at a time for faster navigation through text.",
                    windowsEquivalent: "Ctrl + Left/Right Arrow",
                    macAction: "Option + Left/Right Arrow",
                    sortOrder: 2
                ),
                LessonStep(
                    title: "Delete a whole word",
                    detail: "Delete the entire word behind the cursor in one keystroke instead of pressing Backspace repeatedly.",
                    windowsEquivalent: "Ctrl + Backspace",
                    macAction: "Option + Delete",
                    sortOrder: 3
                )
            ]
        ),
        Lesson(
            id: "productivity-dictation-emoji",
            title: "Dictation and Emoji Picker",
            summary: "Use your voice to type text and quickly insert emoji on Mac.",
            category: .productivity,
            difficulty: .advanced,
            estimatedMinutes: 5,
            symbolName: "face.smiling",
            sortOrder: 24,
            quizQuestion: "What shortcut opens the Emoji and Symbols picker on Mac?",
            correctQuizAnswer: "Command + Control + Space",
            incorrectQuizAnswerOne: "Command + E",
            incorrectQuizAnswerTwo: "Fn + E",
            steps: [
                LessonStep(
                    title: "Open the Emoji picker",
                    detail: "Insert emoji, special characters, and symbols into any text field.",
                    windowsEquivalent: "Win + . (period)",
                    macAction: "Command + Control + Space or Fn/Globe key",
                    sortOrder: 0
                ),
                LessonStep(
                    title: "Search for an emoji",
                    detail: "Type a keyword in the search field at the top of the picker, such as 'thumbs up' or 'fire.'",
                    windowsEquivalent: "Win + . then type keyword",
                    macAction: "Open picker, type keyword in search",
                    sortOrder: 1
                ),
                LessonStep(
                    title: "Start Dictation",
                    detail: "Press the Dictation shortcut and start speaking. Your voice is converted to text in real time.",
                    windowsEquivalent: "Win + H",
                    macAction: "Press Fn (Globe) key twice or enable in System Settings → Keyboard",
                    sortOrder: 2
                )
            ]
        )
    ]
}
